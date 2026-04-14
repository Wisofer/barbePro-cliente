import 'dart:async';
import 'package:dio/dio.dart';
import '../../services/storage/token_storage.dart';
import '../../services/api/api_config.dart';

typedef RefreshResult = ({
  String accessToken,
  String refreshToken,
  Map<String, dynamic>? responseData
});

/// Interceptor que refresca el token ante 401 y notifica el cuerpo del refresh (user/subscription).
class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor(
    this._tokenStorage, {
    this.onRefreshSuccess,
  });

  final TokenStorage _tokenStorage;
  final void Function(Map<String, dynamic>? responseData)? onRefreshSuccess;

  final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: ApiConfig.defaultHeaders,
    ),
  );

  Dio? _originalDio;
  bool _isRefreshing = false;
  final List<({RequestOptions options, Completer<Response> completer})> _failedQueue = [];

  void setOriginalDio(Dio dio) {
    _originalDio = dio;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/refresh')) {
      if (_isRefreshing) {
        final completer = Completer<Response>();
        _failedQueue.add((options: err.requestOptions, completer: completer));

        try {
          final response = await completer.future;
          handler.resolve(response);
        } catch (e) {
          handler.reject(err);
        }
        return;
      }

      _isRefreshing = true;

      try {
        final result = await _refreshToken();

        if (result != null) {
          await _tokenStorage.saveTokens(
            result.accessToken,
            result.refreshToken,
          );
          onRefreshSuccess?.call(result.responseData);

          final dioToUse = _originalDio ?? _refreshDio;
          for (var item in _failedQueue) {
            item.options.headers['Authorization'] = 'Bearer ${result.accessToken}';
            try {
              final response = await dioToUse.fetch(item.options);
              item.completer.complete(response);
            } catch (e) {
              item.completer.completeError(e);
            }
          }
          _failedQueue.clear();

          err.requestOptions.headers['Authorization'] = 'Bearer ${result.accessToken}';
          final response = await dioToUse.fetch(err.requestOptions);
          handler.resolve(response);
        } else {
          await _clearTokensAndReject(err, handler);
        }
      } catch (e) {
        await _clearTokensAndReject(err, handler);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }

  Future<RefreshResult?> _refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
        final newToken = data['token'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newToken != null && newToken.isNotEmpty) {
          return (
            accessToken: newToken,
            refreshToken: newRefreshToken ?? newToken,
            responseData: data,
          );
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _clearTokensAndReject(
    DioException originalError,
    ErrorInterceptorHandler handler,
  ) async {
    await _tokenStorage.clear();

    for (var item in _failedQueue) {
      item.completer.completeError(originalError);
    }
    _failedQueue.clear();

    handler.reject(originalError);
  }
}

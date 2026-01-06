import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:system_movil/services/api/api_config.dart';
import 'package:system_movil/services/storage/token_storage.dart';
import 'package:system_movil/providers/network/error_interceptor.dart';
import 'package:system_movil/providers/network/token_refresh_interceptor.dart';

/// Provides a singleton TokenStorage (secure storage for access/refresh tokens)
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

/// Provides a configured Dio client with base URL, timeouts and an interceptor
/// that injects the Authorization header from TokenStorage when available.
final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: ApiConfig.defaultHeaders,
    ),
  );

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      try {
        final access = await tokenStorage.getAccessToken();
        if (access != null && access.isNotEmpty) {
          // Asegurar que el header esté en el formato correcto
          options.headers['Authorization'] = 'Bearer $access';
          // Asegurar que Accept esté configurado para JSON
          options.headers['Accept'] = 'application/json';
          options.headers['Content-Type'] = 'application/json';
          
          print('🔑 [Dio] Token agregado a request: ${options.uri}');
          print('🔑 [Dio] Method: ${options.method}');
          print('🔑 [Dio] Token (primeros 20 chars): ${access.substring(0, access.length > 20 ? 20 : access.length)}...');
          print('🔑 [Dio] Header Authorization: Bearer ${access.substring(0, access.length > 30 ? 30 : access.length)}...');
          print('🔑 [Dio] Headers enviados: ${options.headers}');
        } else {
          options.headers.remove('Authorization');
          print('⚠️ [Dio] No hay token disponible para: ${options.uri}');
        }
      } catch (e) {
        print('❌ [Dio] Error al obtener token: $e');
        // Ignore read errors; proceed without Authorization
      }
      handler.next(options);
    },
    onResponse: (response, handler) {
      // Verificar si la respuesta es HTML en lugar de JSON
      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        print('⚠️ [Dio] Respuesta HTML recibida en lugar de JSON para: ${response.requestOptions.uri}');
        print('⚠️ [Dio] Status code: ${response.statusCode}');
        print('⚠️ [Dio] Headers de respuesta: ${response.headers}');
        print('⚠️ [Dio] Request headers enviados: ${response.requestOptions.headers}');
        print('⚠️ [Dio] Esto generalmente indica que el token no es válido o expiró');
        print('⚠️ [Dio] Primeros 200 chars de la respuesta: ${(response.data as String).substring(0, (response.data as String).length > 200 ? 200 : (response.data as String).length)}');
        return handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            message: 'El servidor devolvió HTML en lugar de JSON. Posible sesión expirada.',
          ),
        );
      }
      handler.next(response);
    },
  ));
  
  // Interceptor de refresh de tokens (maneja automáticamente los 401)
  final tokenRefreshInterceptor = TokenRefreshInterceptor(tokenStorage);
  tokenRefreshInterceptor.setOriginalDio(dio);
  dio.interceptors.add(tokenRefreshInterceptor);
  
  // Interceptor de errores (debe ir al final)
  dio.interceptors.add(ErrorInterceptor());

  return dio;
});

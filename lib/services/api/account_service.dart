import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/account_deletion.dart';
import '../../providers/providers.dart';

class AccountService {
  AccountService(this._dio);

  final Dio _dio;

  /// GET /api/account/deletion
  Future<AccountDeletionStatusResponse> getDeletionStatus() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/account/deletion');
      final data = response.data;
      if (data == null) {
        throw Exception('Respuesta vacía');
      }
      return AccountDeletionStatusResponse.fromJson(data);
    } on DioException catch (e) {
      final msg = _messageFromDio(e);
      throw Exception(msg ?? 'No se pudo obtener el estado de la cuenta');
    }
  }

  /// POST /api/account/deletion/request — 204 sin cuerpo
  Future<void> requestDeletion() async {
    try {
      final response = await _dio.post('/account/deletion/request');
      final code = response.statusCode;
      if (code != 204 && code != 200) {
        throw Exception('Respuesta inesperada del servidor');
      }
    } on DioException catch (e) {
      final msg = _messageFromDio(e);
      throw Exception(msg ?? 'No se pudo programar la eliminación de la cuenta');
    }
  }

  /// POST /api/account/deletion/cancel — 204 sin cuerpo
  Future<void> cancelDeletion() async {
    try {
      final response = await _dio.post('/account/deletion/cancel');
      final code = response.statusCode;
      if (code != 204 && code != 200) {
        throw Exception('Respuesta inesperada del servidor');
      }
    } on DioException catch (e) {
      final msg = _messageFromDio(e);
      throw Exception(msg ?? 'No se pudo cancelar la eliminación');
    }
  }

  String? _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return null;
  }
}

final accountServiceProvider = Provider<AccountService>((ref) {
  final dio = ref.watch(dioProvider);
  return AccountService(dio);
});

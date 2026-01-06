import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/help_support.dart';
import '../../providers/providers.dart';

class HelpSupportService {
  final Dio _dio;

  HelpSupportService(this._dio);

  Future<HelpSupportDto> getHelpSupport() async {
    try {
      print('🌐 [HelpSupportService] GET /barber/help-support');
      final response = await _dio.get('/barber/help-support');
      print('✅ [HelpSupportService] Help support response status: ${response.statusCode}');
      
      // Validar que la respuesta sea JSON
      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'El servidor devolvió HTML. Posible sesión expirada o token inválido.',
        );
      }
      
      print('📦 [HelpSupportService] Help support data type: ${response.data.runtimeType}');
      return HelpSupportDto.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [HelpSupportService] Error en help support: ${e.response?.statusCode}');
      if (e.response?.data is String && (e.response!.data as String).contains('<!DOCTYPE')) {
        print('❌ [HelpSupportService] El servidor devolvió HTML - sesión probablemente expirada');
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      }
      print('📋 [HelpSupportService] Error data: ${e.response?.data}');
      print('📋 [HelpSupportService] Error message: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ [HelpSupportService] Error inesperado en help support: $e');
      rethrow;
    }
  }
}

final helpSupportServiceProvider = Provider<HelpSupportService>((ref) {
  final dio = ref.watch(dioProvider);
  return HelpSupportService(dio);
});


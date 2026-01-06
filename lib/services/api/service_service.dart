import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/service.dart';
import '../../providers/providers.dart';

class ServiceService {
  final Dio _dio;

  ServiceService(this._dio);

  Future<List<ServiceDto>> getServices() async {
    try {
      print('🌐 [ServiceService] GET /barber/services');
      final response = await _dio.get('/barber/services');
      print('✅ [ServiceService] Services response status: ${response.statusCode}');
      
      // Validar que la respuesta sea JSON
      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'El servidor devolvió HTML. Posible sesión expirada o token inválido.',
        );
      }
      
      print('📦 [ServiceService] Services data type: ${response.data.runtimeType}');
      if (response.data is! List) {
        throw Exception('Respuesta inesperada: se esperaba una lista pero se recibió ${response.data.runtimeType}');
      }
      print('📦 [ServiceService] Services count: ${(response.data as List).length}');
      return (response.data as List)
          .map((json) => ServiceDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      print('❌ [ServiceService] Error en services: ${e.response?.statusCode}');
      if (e.response?.data is String && (e.response!.data as String).contains('<!DOCTYPE')) {
        print('❌ [ServiceService] El servidor devolvió HTML - sesión probablemente expirada');
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      }
      print('📋 [ServiceService] Error data: ${e.response?.data}');
      print('📋 [ServiceService] Error message: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ [ServiceService] Error inesperado en services: $e');
      rethrow;
    }
  }

  Future<ServiceDto> createService({
    required String name,
    required double price,
    int? durationMinutes,
  }) async {
    try {
      print('🌐 [ServiceService] POST /barber/services');
      final data = <String, dynamic>{
        'name': name,
        'price': price,
      };
      if (durationMinutes != null) {
        data['durationMinutes'] = durationMinutes;
      }
      print('📦 [ServiceService] Sending data: $data');
      final response = await _dio.post(
        '/barber/services',
        data: data,
      );
      print('✅ [ServiceService] Service created, status: ${response.statusCode}');
      return ServiceDto.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [ServiceService] Error al crear servicio: ${e.response?.statusCode}');
      print('📋 [ServiceService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [ServiceService] Error inesperado al crear servicio: $e');
      rethrow;
    }
  }

  Future<ServiceDto> updateService({
    required int id,
    String? name,
    double? price,
    int? durationMinutes,
    bool? isActive,
  }) async {
    try {
      print('🌐 [ServiceService] PUT /barber/services/$id');
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (price != null) body['price'] = price;
      if (durationMinutes != null) body['durationMinutes'] = durationMinutes;
      if (isActive != null) body['isActive'] = isActive;

      print('📦 [ServiceService] Sending data: $body');
      final response = await _dio.put(
        '/barber/services/$id',
        data: body,
      );
      print('✅ [ServiceService] Service updated, status: ${response.statusCode}');
      return ServiceDto.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [ServiceService] Error al actualizar servicio: ${e.response?.statusCode}');
      print('📋 [ServiceService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [ServiceService] Error inesperado al actualizar servicio: $e');
      rethrow;
    }
  }

  Future<void> deleteService(int id) async {
    try {
      print('🌐 [ServiceService] DELETE /barber/services/$id');
      await _dio.delete('/barber/services/$id');
      print('✅ [ServiceService] Service deleted');
    } on DioException catch (e) {
      print('❌ [ServiceService] Error al eliminar servicio: ${e.response?.statusCode}');
      print('📋 [ServiceService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [ServiceService] Error inesperado al eliminar servicio: $e');
      rethrow;
    }
  }
}

final serviceServiceProvider = Provider<ServiceService>((ref) {
  final dio = ref.watch(dioProvider);
  return ServiceService(dio);
});


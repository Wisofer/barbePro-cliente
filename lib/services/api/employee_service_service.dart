import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/service.dart';
import '../../providers/providers.dart';

/// Servicio para que los empleados puedan ver servicios (solo lectura)
class EmployeeServiceService {
  final Dio _dio;

  EmployeeServiceService(this._dio);

  /// Obtener todos los servicios del barbero dueño (solo lectura para empleados)
  Future<List<ServiceDto>> getServices() async {
    try {
      print('🌐 [EmployeeServiceService] GET /employee/services');
      final response = await _dio.get('/employee/services');
      print('✅ [EmployeeServiceService] Services response status: ${response.statusCode}');
      
      // Validar que la respuesta sea JSON
      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'El servidor devolvió HTML. Posible sesión expirada o token inválido.',
        );
      }
      
      print('📦 [EmployeeServiceService] Services data type: ${response.data.runtimeType}');
      if (response.data is! List) {
        throw Exception('Respuesta inesperada: se esperaba una lista pero se recibió ${response.data.runtimeType}');
      }
      print('📦 [EmployeeServiceService] Services count: ${(response.data as List).length}');
      return (response.data as List)
          .map((json) => ServiceDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      print('❌ [EmployeeServiceService] Error en services: ${e.response?.statusCode}');
      if (e.response?.data is String && (e.response!.data as String).contains('<!DOCTYPE')) {
        print('❌ [EmployeeServiceService] El servidor devolvió HTML - sesión probablemente expirada');
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      }
      print('📋 [EmployeeServiceService] Error data: ${e.response?.data}');
      print('📋 [EmployeeServiceService] Error message: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ [EmployeeServiceService] Error inesperado en services: $e');
      rethrow;
    }
  }

  /// Obtener un servicio específico por ID (solo lectura para empleados)
  Future<ServiceDto> getService(int id) async {
    try {
      print('🌐 [EmployeeServiceService] GET /employee/services/$id');
      final response = await _dio.get('/employee/services/$id');
      print('✅ [EmployeeServiceService] Service response status: ${response.statusCode}');
      
      // Validar que la respuesta sea JSON
      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'El servidor devolvió HTML. Posible sesión expirada o token inválido.',
        );
      }
      
      return ServiceDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ [EmployeeServiceService] Error al obtener servicio: ${e.response?.statusCode}');
      print('📋 [EmployeeServiceService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [EmployeeServiceService] Error inesperado al obtener servicio: $e');
      rethrow;
    }
  }
}

final employeeServiceServiceProvider = Provider<EmployeeServiceService>((ref) {
  final dio = ref.watch(dioProvider);
  return EmployeeServiceService(dio);
});


import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/appointment.dart';
import '../../providers/providers.dart';
import '../../providers/auth_provider.dart';
import '../demo/mock_appointment_service.dart';

class EmployeeAppointmentService {
  final Dio _dio;

  EmployeeAppointmentService(this._dio);

  /// Obtener citas del trabajador autenticado
  Future<List<AppointmentDto>> getAppointments({
    String? date,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) queryParams['date'] = date;
      if (status != null) queryParams['status'] = status;

      print('🌐 [EmployeeAppointmentService] GET /employee/appointments?${queryParams.toString()}');
      final response = await _dio.get(
        '/employee/appointments',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      print('✅ [EmployeeAppointmentService] Appointments response status: ${response.statusCode}');
      
      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'El servidor devolvió HTML. Posible sesión expirada o token inválido.',
        );
      }
      
      if (response.data is! List) {
        throw Exception('Respuesta inesperada: se esperaba una lista pero se recibió ${response.data.runtimeType}');
      }
      
      return (response.data as List)
          .map((json) => AppointmentDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      
      if (statusCode == 404) {
        print('⚠️ [EmployeeAppointmentService] 404 - No hay citas disponibles');
        return [];
      }
      
      print('❌ [EmployeeAppointmentService] Error en appointments: $statusCode');
      rethrow;
    } catch (e) {
      print('❌ [EmployeeAppointmentService] Error inesperado: $e');
      rethrow;
    }
  }

  /// Crear cita manual (trabajador)
  Future<AppointmentDto> createAppointment({
    List<int>? serviceIds,
    required String clientName,
    required String clientPhone,
    required String date,
    required String time,
  }) async {
    try {
      final body = <String, dynamic>{
        'clientName': clientName,
        'clientPhone': clientPhone,
        'date': date,
        'time': time,
      };
      
      if (serviceIds != null && serviceIds.isNotEmpty) {
        body['serviceIds'] = serviceIds;
      }

      print('🌐 [EmployeeAppointmentService] POST /employee/appointments');
      print('📦 [EmployeeAppointmentService] Sending data: $body');
      final response = await _dio.post(
        '/employee/appointments',
        data: body,
      );
      print('✅ [EmployeeAppointmentService] Appointment created, status: ${response.statusCode}');
      
      return AppointmentDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ [EmployeeAppointmentService] Error al crear cita: ${e.response?.statusCode}');
      print('📋 [EmployeeAppointmentService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [EmployeeAppointmentService] Error inesperado: $e');
      rethrow;
    }
  }

  /// Obtener una cita específica
  Future<AppointmentDto> getAppointment(int id) async {
    try {
      print('🌐 [EmployeeAppointmentService] GET /employee/appointments/$id');
      final response = await _dio.get('/employee/appointments/$id');
      print('✅ [EmployeeAppointmentService] Appointment retrieved, status: ${response.statusCode}');
      
      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'El servidor devolvió HTML. Posible sesión expirada o token inválido.',
        );
      }
      
      return AppointmentDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ [EmployeeAppointmentService] Error al obtener cita: ${e.response?.statusCode}');
      print('📋 [EmployeeAppointmentService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [EmployeeAppointmentService] Error inesperado: $e');
      rethrow;
    }
  }

  /// Actualizar cita (aceptar, completar, modificar)
  Future<AppointmentDto> updateAppointment({
    required int id,
    String? status,
    String? date,
    String? time,
    String? clientName,
    String? clientPhone,
    List<int>? serviceIds,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (status != null) body['status'] = status;
      if (date != null) body['date'] = date;
      if (time != null) body['time'] = time;
      if (clientName != null) body['clientName'] = clientName;
      if (clientPhone != null) body['clientPhone'] = clientPhone;
      if (serviceIds != null && serviceIds.isNotEmpty) {
        body['serviceIds'] = serviceIds;
      }

      print('🌐 [EmployeeAppointmentService] PUT /employee/appointments/$id');
      print('📦 [EmployeeAppointmentService] Body: $body');
      final response = await _dio.put(
        '/employee/appointments/$id',
        data: body,
      );
      print('✅ [EmployeeAppointmentService] Appointment updated, status: ${response.statusCode}');
      
      return AppointmentDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ [EmployeeAppointmentService] Error al actualizar cita: ${e.response?.statusCode}');
      print('📋 [EmployeeAppointmentService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [EmployeeAppointmentService] Error inesperado: $e');
      rethrow;
    }
  }

  /// Obtener historial completo de citas (sin filtros de fecha)
  Future<List<AppointmentDto>> getHistory() async {
    try {
      print('🌐 [EmployeeAppointmentService] GET /employee/appointments/history');
      final response = await _dio.get('/employee/appointments/history');
      print('✅ [EmployeeAppointmentService] History response status: ${response.statusCode}');
      
      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'El servidor devolvió HTML. Posible sesión expirada o token inválido.',
        );
      }
      
      if (response.data is! List) {
        throw Exception('Respuesta inesperada: se esperaba una lista pero se recibió ${response.data.runtimeType}');
      }
      
      print('📦 [EmployeeAppointmentService] History count: ${(response.data as List).length}');
      
      return (response.data as List)
          .map((json) => AppointmentDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      
      if (statusCode == 404) {
        print('⚠️ [EmployeeAppointmentService] 404 - No hay historial disponible');
        return [];
      }
      
      print('❌ [EmployeeAppointmentService] Error en history: $statusCode');
      rethrow;
    } catch (e) {
      print('❌ [EmployeeAppointmentService] Error inesperado en history: $e');
      rethrow;
    }
  }
}

final employeeAppointmentServiceProvider = Provider<dynamic>((ref) {
  final authState = ref.watch(authNotifierProvider);
  
  // Si está en modo demo, usar servicio mock
  if (authState.isDemoMode) {
    return MockAppointmentService();
  }
  
  final dio = ref.watch(dioProvider);
  return EmployeeAppointmentService(dio);
});


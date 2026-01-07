import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/appointment.dart';
import '../../providers/providers.dart';

class AppointmentService {
  final Dio _dio;

  AppointmentService(this._dio);

  Future<List<AppointmentDto>> getAppointments({
    String? date,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) queryParams['date'] = date;
      if (status != null) queryParams['status'] = status;

      print('🌐 [AppointmentService] GET /barber/appointments?${queryParams.toString()}');
      final response = await _dio.get(
        '/barber/appointments',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      print('✅ [AppointmentService] Appointments response status: ${response.statusCode}');
      
      // Validar que la respuesta sea JSON
      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'El servidor devolvió HTML. Posible sesión expirada o token inválido.',
        );
      }
      
      print('📦 [AppointmentService] Appointments data type: ${response.data.runtimeType}');
      if (response.data is! List) {
        throw Exception('Respuesta inesperada: se esperaba una lista pero se recibió ${response.data.runtimeType}');
      }
      print('📦 [AppointmentService] Appointments count: ${(response.data as List).length}');
      
      // Log del primer elemento para debugging
      if ((response.data as List).isNotEmpty) {
        print('📋 [AppointmentService] Primer elemento: ${(response.data as List).first}');
      }
      
      return (response.data as List)
          .map((json) {
            try {
              return AppointmentDto.fromJson(json);
            } catch (e) {
              print('❌ [AppointmentService] Error al parsear cita: $e');
              print('📋 [AppointmentService] JSON problemático: $json');
              rethrow;
            }
          })
          .toList();
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      
      // Si es 404, probablemente no hay citas, retornar lista vacía
      if (statusCode == 404) {
        print('⚠️ [AppointmentService] 404 - No hay citas disponibles o endpoint no encontrado');
        print('📋 [AppointmentService] Retornando lista vacía');
        return [];
      }
      
      print('❌ [AppointmentService] Error en appointments: $statusCode');
      if (e.response?.data is String && (e.response!.data as String).contains('<!DOCTYPE')) {
        print('❌ [AppointmentService] El servidor devolvió HTML - sesión probablemente expirada');
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      }
      print('📋 [AppointmentService] Error data: ${e.response?.data}');
      print('📋 [AppointmentService] Error message: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ [AppointmentService] Error inesperado en appointments: $e');
      rethrow;
    }
  }

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
        'status': 'Confirmed', // Las citas creadas manualmente por el barbero se crean directamente como confirmadas
      };
      
      // Solo incluir serviceIds si se proporciona y no está vacío
      if (serviceIds != null && serviceIds.isNotEmpty) {
        body['serviceIds'] = serviceIds;
      }
      
      print('🌐 [AppointmentService] POST /barber/appointments');
      print('📦 [AppointmentService] Body: $body');
      final response = await _dio.post(
        '/barber/appointments',
        data: body,
      );
      print('✅ [AppointmentService] Appointment created, status: ${response.statusCode}');
      return AppointmentDto.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [AppointmentService] Error al crear cita: ${e.response?.statusCode}');
      print('📋 [AppointmentService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [AppointmentService] Error inesperado al crear cita: $e');
      rethrow;
    }
  }

  /// Obtener una cita específica
  Future<AppointmentDto> getAppointment(int id) async {
    try {
      print('🌐 [AppointmentService] GET /barber/appointments/$id');
      final response = await _dio.get('/barber/appointments/$id');
      print('✅ [AppointmentService] Appointment retrieved, status: ${response.statusCode}');
      
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
      print('❌ [AppointmentService] Error al obtener cita: ${e.response?.statusCode}');
      print('📋 [AppointmentService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [AppointmentService] Error inesperado: $e');
      rethrow;
    }
  }

  Future<AppointmentDto> updateAppointment({
    required int id,
    String? status,
    String? date,
    String? time,
    String? clientName,
    String? clientPhone,
    int? serviceId, // Legacy
    List<int>? serviceIds, // Nuevo: múltiples servicios
  }) async {
    try {
      final body = <String, dynamic>{};
      if (status != null) body['status'] = status;
      if (date != null) body['date'] = date;
      if (time != null) body['time'] = time;
      if (clientName != null) body['clientName'] = clientName;
      if (clientPhone != null) body['clientPhone'] = clientPhone;
      if (serviceId != null) body['serviceId'] = serviceId; // Legacy
      if (serviceIds != null && serviceIds.isNotEmpty) {
        body['serviceIds'] = serviceIds; // Nuevo
      }

      print('🌐 [AppointmentService] PUT /barber/appointments/$id');
      print('📦 [AppointmentService] Body: $body');
      final response = await _dio.put(
        '/barber/appointments/$id',
        data: body,
      );
      print('✅ [AppointmentService] Appointment updated, status: ${response.statusCode}');
      return AppointmentDto.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [AppointmentService] Error al actualizar cita: ${e.response?.statusCode}');
      print('📋 [AppointmentService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [AppointmentService] Error inesperado al actualizar cita: $e');
      rethrow;
    }
  }

  Future<void> deleteAppointment(int id) async {
    await _dio.delete('/barber/appointments/$id');
  }

  Future<Map<String, dynamic>> getWhatsAppUrl(int id) async {
    try {
      print('🌐 [AppointmentService] GET /barber/appointments/$id/whatsapp-url');
      final response = await _dio.get('/barber/appointments/$id/whatsapp-url');
      print('✅ [AppointmentService] WhatsApp URL obtenida, status: ${response.statusCode}');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('❌ [AppointmentService] Error al obtener WhatsApp URL: ${e.response?.statusCode}');
      print('📋 [AppointmentService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [AppointmentService] Error inesperado al obtener WhatsApp URL: $e');
      rethrow;
    }
  }
}

final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  final dio = ref.watch(dioProvider);
  return AppointmentService(dio);
});


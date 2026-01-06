import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/barber.dart';
import '../../models/dashboard_barber.dart';
import '../../models/finance.dart';
import '../../models/auth.dart';
import '../../providers/providers.dart';

class BarberService {
  final Dio _dio;

  BarberService(this._dio);

  Future<BarberDashboardDto> getDashboard() async {
    try {
      print('🌐 [BarberService] GET /barber/dashboard');
      final response = await _dio.get('/barber/dashboard');
      print('✅ [BarberService] Dashboard response status: ${response.statusCode}');
      
      // Validar que la respuesta sea JSON
      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'El servidor devolvió HTML. Posible sesión expirada o token inválido.',
        );
      }
      
      print('📦 [BarberService] Dashboard data type: ${response.data.runtimeType}');
      return BarberDashboardDto.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [BarberService] Error en dashboard: ${e.response?.statusCode}');
      if (e.response?.data is String && (e.response!.data as String).contains('<!DOCTYPE')) {
        print('❌ [BarberService] El servidor devolvió HTML - sesión probablemente expirada');
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      }
      print('📋 [BarberService] Error data: ${e.response?.data}');
      print('📋 [BarberService] Error message: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ [BarberService] Error inesperado en dashboard: $e');
      rethrow;
    }
  }

  Future<BarberDto> getProfile() async {
    try {
      print('🌐 [BarberService] GET /barber/profile');
      final response = await _dio.get('/barber/profile');
      print('✅ [BarberService] Profile response status: ${response.statusCode}');
      
      // Validar que la respuesta sea JSON
      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'El servidor devolvió HTML. Posible sesión expirada o token inválido.',
        );
      }
      
      print('📦 [BarberService] Profile data type: ${response.data.runtimeType}');
      return BarberDto.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [BarberService] Error en profile: ${e.response?.statusCode}');
      if (e.response?.data is String && (e.response!.data as String).contains('<!DOCTYPE')) {
        print('❌ [BarberService] El servidor devolvió HTML - sesión probablemente expirada');
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      }
      print('📋 [BarberService] Error data: ${e.response?.data}');
      print('📋 [BarberService] Error message: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ [BarberService] Error inesperado en profile: $e');
      rethrow;
    }
  }

  Future<BarberDto> updateProfile({
    required String name,
    String? businessName,
    required String phone,
  }) async {
    final response = await _dio.put(
      '/barber/profile',
      data: {
        'name': name,
        'businessName': businessName,
        'phone': phone,
      },
    );
    return BarberDto.fromJson(response.data);
  }

  Future<QrResponse> getQrCode() async {
    final response = await _dio.get('/barber/qr-url');
    return QrResponse.fromJson(response.data);
  }

  Future<FinanceSummaryDto> getFinanceSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      print('🌐 [BarberService] GET /barber/finances/summary');
      final response = await _dio.get(
        '/barber/finances/summary',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      print('✅ [BarberService] Finance summary response status: ${response.statusCode}');
      
      // Validar que la respuesta sea JSON
      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'El servidor devolvió HTML. Posible sesión expirada o token inválido.',
        );
      }
      
      print('📦 [BarberService] Finance data type: ${response.data.runtimeType}');
      return FinanceSummaryDto.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [BarberService] Error en finance summary: ${e.response?.statusCode}');
      if (e.response?.data is String && (e.response!.data as String).contains('<!DOCTYPE')) {
        print('❌ [BarberService] El servidor devolvió HTML - sesión probablemente expirada');
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      }
      print('📋 [BarberService] Error data: ${e.response?.data}');
      print('📋 [BarberService] Error message: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ [BarberService] Error inesperado en finance summary: $e');
      rethrow;
    }
  }

  Future<List<WorkingHoursDto>> getWorkingHours() async {
    try {
      print('🌐 [BarberService] GET /barber/working-hours');
      final response = await _dio.get('/barber/working-hours');
      print('✅ [BarberService] Working hours response status: ${response.statusCode}');
      
      // Validar que la respuesta sea JSON
      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'El servidor devolvió HTML. Posible sesión expirada o token inválido.',
        );
      }
      
      print('📦 [BarberService] Working hours data type: ${response.data.runtimeType}');
      if (response.data is! List) {
        throw Exception('Respuesta inesperada: se esperaba una lista pero se recibió ${response.data.runtimeType}');
      }
      
      // Log del primer elemento para debugging
      if ((response.data as List).isNotEmpty) {
        print('📋 [BarberService] Primer elemento: ${(response.data as List).first}');
      }
      
      return (response.data as List)
          .map((json) {
            try {
              return WorkingHoursDto.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              print('❌ [BarberService] Error al parsear working hours: $e');
              print('📋 [BarberService] JSON problemático: $json');
              rethrow;
            }
          })
          .toList();
    } on DioException catch (e) {
      print('❌ [BarberService] Error en working hours: ${e.response?.statusCode}');
      if (e.response?.data is String && (e.response!.data as String).contains('<!DOCTYPE')) {
        print('❌ [BarberService] El servidor devolvió HTML - sesión probablemente expirada');
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      }
      print('📋 [BarberService] Error data: ${e.response?.data}');
      print('📋 [BarberService] Error message: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ [BarberService] Error inesperado en working hours: $e');
      rethrow;
    }
  }

  Future<void> updateWorkingHours(List<Map<String, dynamic>> workingHours) async {
    try {
      final requestData = {
        'workingHours': workingHours,
      };
      print('🌐 [BarberService] PUT /barber/working-hours');
      print('📦 [BarberService] Sending data: $requestData');
      print('📦 [BarberService] Working hours count: ${workingHours.length}');
      final response = await _dio.put(
        '/barber/working-hours',
        data: requestData,
      );
      print('✅ [BarberService] Working hours updated, status: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ [BarberService] Error al actualizar working hours: ${e.response?.statusCode}');
      print('📋 [BarberService] Error data: ${e.response?.data}');
      print('📋 [BarberService] Error message: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ [BarberService] Error inesperado al actualizar working hours: $e');
      rethrow;
    }
  }
}

final barberServiceProvider = Provider<BarberService>((ref) {
  final dio = ref.watch(dioProvider);
  return BarberService(dio);
});


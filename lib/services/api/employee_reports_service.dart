import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/employee_reports.dart';
import '../../providers/providers.dart';

class EmployeeReportsService {
  final Dio _dio;

  EmployeeReportsService(this._dio);

  /// Obtener reporte de citas por empleado
  Future<EmployeeAppointmentsReportDto> getAppointmentsReport({
    DateTime? startDate,
    DateTime? endDate,
    int? employeeId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (employeeId != null) {
        queryParams['employeeId'] = employeeId.toString();
      }

      print('🌐 [EmployeeReportsService] GET /barber/reports/employees/appointments');
      print('📦 [EmployeeReportsService] Query params: $queryParams');
      final response = await _dio.get(
        '/barber/reports/employees/appointments',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      print('✅ [EmployeeReportsService] Appointments report response status: ${response.statusCode}');

      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'El servidor devolvió HTML. Posible sesión expirada o token inválido.',
        );
      }

      return EmployeeAppointmentsReportDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ [EmployeeReportsService] Error en appointments report: ${e.response?.statusCode}');
      print('📋 [EmployeeReportsService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [EmployeeReportsService] Error inesperado: $e');
      rethrow;
    }
  }

  /// Obtener reporte de ingresos por empleado
  Future<EmployeeIncomeReportDto> getIncomeReport({
    DateTime? startDate,
    DateTime? endDate,
    int? employeeId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (employeeId != null) {
        queryParams['employeeId'] = employeeId.toString();
      }

      print('🌐 [EmployeeReportsService] GET /barber/reports/employees/income');
      print('📦 [EmployeeReportsService] Query params: $queryParams');
      final response = await _dio.get(
        '/barber/reports/employees/income',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      print('✅ [EmployeeReportsService] Income report response status: ${response.statusCode}');

      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'El servidor devolvió HTML. Posible sesión expirada o token inválido.',
        );
      }

      return EmployeeIncomeReportDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ [EmployeeReportsService] Error en income report: ${e.response?.statusCode}');
      print('📋 [EmployeeReportsService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [EmployeeReportsService] Error inesperado: $e');
      rethrow;
    }
  }

  /// Obtener reporte de egresos por empleado
  Future<EmployeeExpensesReportDto> getExpensesReport({
    DateTime? startDate,
    DateTime? endDate,
    int? employeeId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (employeeId != null) {
        queryParams['employeeId'] = employeeId.toString();
      }

      print('🌐 [EmployeeReportsService] GET /barber/reports/employees/expenses');
      print('📦 [EmployeeReportsService] Query params: $queryParams');
      final response = await _dio.get(
        '/barber/reports/employees/expenses',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      print('✅ [EmployeeReportsService] Expenses report response status: ${response.statusCode}');

      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'El servidor devolvió HTML. Posible sesión expirada o token inválido.',
        );
      }

      return EmployeeExpensesReportDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ [EmployeeReportsService] Error en expenses report: ${e.response?.statusCode}');
      print('📋 [EmployeeReportsService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [EmployeeReportsService] Error inesperado: $e');
      rethrow;
    }
  }

  /// Obtener reporte de actividad general de empleados
  Future<EmployeeActivityReportDto> getActivityReport({
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

      print('🌐 [EmployeeReportsService] GET /barber/reports/employees/activity');
      print('📦 [EmployeeReportsService] Query params: $queryParams');
      final response = await _dio.get(
        '/barber/reports/employees/activity',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      print('✅ [EmployeeReportsService] Activity report response status: ${response.statusCode}');

      if (response.data is String && (response.data as String).trim().startsWith('<!DOCTYPE')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'El servidor devolvió HTML. Posible sesión expirada o token inválido.',
        );
      }

      return EmployeeActivityReportDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ [EmployeeReportsService] Error en activity report: ${e.response?.statusCode}');
      print('📋 [EmployeeReportsService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [EmployeeReportsService] Error inesperado: $e');
      rethrow;
    }
  }
}

final employeeReportsServiceProvider = Provider<EmployeeReportsService>((ref) {
  final dio = ref.watch(dioProvider);
  return EmployeeReportsService(dio);
});


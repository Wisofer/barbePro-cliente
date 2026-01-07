import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/finance.dart';
import '../../providers/providers.dart';

class EmployeeFinanceService {
  final Dio _dio;

  EmployeeFinanceService(this._dio);

  /// Obtener ingresos del trabajador autenticado
  Future<TransactionsResponse> getIncome({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      print('🌐 [EmployeeFinanceService] GET /employee/finances/income');
      final response = await _dio.get(
        '/employee/finances/income',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      print('✅ [EmployeeFinanceService] Income response status: ${response.statusCode}');
      return TransactionsResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [EmployeeFinanceService] Error al obtener ingresos: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      print('❌ [EmployeeFinanceService] Error inesperado: $e');
      rethrow;
    }
  }

  /// Crear ingreso manual (trabajador)
  Future<TransactionDto> createIncome({
    required double amount,
    required String description,
    String? category,
    required DateTime date,
  }) async {
    try {
      print('🌐 [EmployeeFinanceService] POST /employee/finances/income');
      final data = <String, dynamic>{
        'amount': amount,
        'description': description,
        'date': date.toIso8601String().split('T')[0],
      };
      if (category != null && category.isNotEmpty) {
        data['category'] = category;
      }
      final response = await _dio.post(
        '/employee/finances/income',
        data: data,
      );
      print('✅ [EmployeeFinanceService] Income created, status: ${response.statusCode}');
      return TransactionDto.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [EmployeeFinanceService] Error al crear ingreso: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      print('❌ [EmployeeFinanceService] Error inesperado: $e');
      rethrow;
    }
  }

  /// Obtener egresos del trabajador autenticado
  Future<TransactionsResponse> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      print('🌐 [EmployeeFinanceService] GET /employee/finances/expenses');
      final response = await _dio.get(
        '/employee/finances/expenses',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      print('✅ [EmployeeFinanceService] Expenses response status: ${response.statusCode}');
      return TransactionsResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [EmployeeFinanceService] Error al obtener egresos: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      print('❌ [EmployeeFinanceService] Error inesperado: $e');
      rethrow;
    }
  }

  /// Crear egreso (trabajador)
  Future<TransactionDto> createExpense({
    required double amount,
    required String description,
    String? category,
    required DateTime date,
  }) async {
    try {
      print('🌐 [EmployeeFinanceService] POST /employee/finances/expenses');
      final data = <String, dynamic>{
        'amount': amount,
        'description': description,
        'date': date.toIso8601String().split('T')[0],
      };
      if (category != null && category.isNotEmpty) {
        data['category'] = category;
      }
      final response = await _dio.post(
        '/employee/finances/expenses',
        data: data,
      );
      print('✅ [EmployeeFinanceService] Expense created, status: ${response.statusCode}');
      return TransactionDto.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [EmployeeFinanceService] Error al crear egreso: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      print('❌ [EmployeeFinanceService] Error inesperado: $e');
      rethrow;
    }
  }
}

final employeeFinanceServiceProvider = Provider<EmployeeFinanceService>((ref) {
  final dio = ref.watch(dioProvider);
  return EmployeeFinanceService(dio);
});


import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/finance.dart';
import '../../providers/providers.dart';

class FinanceService {
  final Dio _dio;

  FinanceService(this._dio);

  // Obtener ingresos
  Future<TransactionsResponse> getIncome({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0]; // YYYY-MM-DD
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0]; // YYYY-MM-DD
      }

      print('🌐 [FinanceService] GET /barber/finances/income');
      final response = await _dio.get(
        '/barber/finances/income',
        queryParameters: queryParams,
      );
      print('✅ [FinanceService] Income response status: ${response.statusCode}');
      return TransactionsResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [FinanceService] Error al obtener ingresos: ${e.response?.statusCode}');
      print('📋 [FinanceService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [FinanceService] Error inesperado al obtener ingresos: $e');
      rethrow;
    }
  }

  // Crear ingreso manual
  Future<TransactionDto> createIncome({
    required double amount,
    required String description,
    String? category,
    required DateTime date,
  }) async {
    try {
      print('🌐 [FinanceService] POST /barber/finances/income');
      final data = <String, dynamic>{
        'amount': amount,
        'description': description,
        'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
      };
      if (category != null && category.isNotEmpty) {
        data['category'] = category;
      }
      print('📦 [FinanceService] Sending data: $data');
      final response = await _dio.post(
        '/barber/finances/income',
        data: data,
      );
      print('✅ [FinanceService] Income created, status: ${response.statusCode}');
      return TransactionDto.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [FinanceService] Error al crear ingreso: ${e.response?.statusCode}');
      print('📋 [FinanceService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [FinanceService] Error inesperado al crear ingreso: $e');
      rethrow;
    }
  }

  // Obtener egresos
  Future<TransactionsResponse> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0]; // YYYY-MM-DD
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0]; // YYYY-MM-DD
      }

      print('🌐 [FinanceService] GET /barber/finances/expenses');
      final response = await _dio.get(
        '/barber/finances/expenses',
        queryParameters: queryParams,
      );
      print('✅ [FinanceService] Expenses response status: ${response.statusCode}');
      return TransactionsResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [FinanceService] Error al obtener egresos: ${e.response?.statusCode}');
      print('📋 [FinanceService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [FinanceService] Error inesperado al obtener egresos: $e');
      rethrow;
    }
  }

  // Crear egreso
  Future<TransactionDto> createExpense({
    required double amount,
    required String description,
    String? category,
    required DateTime date,
  }) async {
    try {
      print('🌐 [FinanceService] POST /barber/finances/expenses');
      final data = <String, dynamic>{
        'amount': amount,
        'description': description,
        'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
      };
      if (category != null && category.isNotEmpty) {
        data['category'] = category;
      }
      print('📦 [FinanceService] Sending data: $data');
      final response = await _dio.post(
        '/barber/finances/expenses',
        data: data,
      );
      print('✅ [FinanceService] Expense created, status: ${response.statusCode}');
      return TransactionDto.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [FinanceService] Error al crear egreso: ${e.response?.statusCode}');
      print('📋 [FinanceService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [FinanceService] Error inesperado al crear egreso: $e');
      rethrow;
    }
  }

  // Actualizar egreso
  Future<TransactionDto> updateExpense({
    required int id,
    required double amount,
    required String description,
    String? category,
    required DateTime date,
  }) async {
    try {
      print('🌐 [FinanceService] PUT /barber/finances/expenses/$id');
      final data = <String, dynamic>{
        'amount': amount,
        'description': description,
        'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
      };
      if (category != null && category.isNotEmpty) {
        data['category'] = category;
      }
      print('📦 [FinanceService] Sending data: $data');
      final response = await _dio.put(
        '/barber/finances/expenses/$id',
        data: data,
      );
      print('✅ [FinanceService] Expense updated, status: ${response.statusCode}');
      return TransactionDto.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [FinanceService] Error al actualizar egreso: ${e.response?.statusCode}');
      print('📋 [FinanceService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [FinanceService] Error inesperado al actualizar egreso: $e');
      rethrow;
    }
  }

  // Eliminar egreso
  Future<void> deleteExpense(int id) async {
    try {
      print('🌐 [FinanceService] DELETE /barber/finances/expenses/$id');
      await _dio.delete('/barber/finances/expenses/$id');
      print('✅ [FinanceService] Expense deleted');
    } on DioException catch (e) {
      print('❌ [FinanceService] Error al eliminar egreso: ${e.response?.statusCode}');
      print('📋 [FinanceService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [FinanceService] Error inesperado al eliminar egreso: $e');
      rethrow;
    }
  }

  // Obtener categorías
  Future<List<String>> getCategories() async {
    try {
      print('🌐 [FinanceService] GET /barber/finances/categories');
      final response = await _dio.get('/barber/finances/categories');
      print('✅ [FinanceService] Categories response status: ${response.statusCode}');
      return (response.data as List).map((e) => e.toString()).toList();
    } on DioException catch (e) {
      print('❌ [FinanceService] Error al obtener categorías: ${e.response?.statusCode}');
      print('📋 [FinanceService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [FinanceService] Error inesperado al obtener categorías: $e');
      rethrow;
    }
  }
}

final financeServiceProvider = Provider<FinanceService>((ref) {
  final dio = ref.watch(dioProvider);
  return FinanceService(dio);
});


import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/providers.dart';

class ExportService {
  final Dio _dio;

  ExportService(this._dio);

  /// Exportar citas
  Future<File> exportAppointments({
    String format = 'csv',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{'format': format};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      print('🌐 [ExportService] GET /barber/export/appointments?format=$format');
      final response = await _dio.get(
        '/barber/export/appointments',
        queryParameters: queryParams,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      print('✅ [ExportService] Appointments export response status: ${response.statusCode}');
      
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().split('T')[0].replaceAll('-', '');
      final extension = format == 'excel' ? 'xlsx' : format;
      final file = File('${directory.path}/citas_$timestamp.$extension');
      await file.writeAsBytes(response.data);
      
      print('💾 [ExportService] File saved: ${file.path}');
      return file;
    } on DioException catch (e) {
      print('❌ [ExportService] Error en export appointments: ${e.response?.statusCode}');
      print('📋 [ExportService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [ExportService] Error inesperado en export appointments: $e');
      rethrow;
    }
  }

  /// Exportar finanzas
  Future<File> exportFinances({
    String format = 'csv',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{'format': format};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      print('🌐 [ExportService] GET /barber/export/finances?format=$format');
      final response = await _dio.get(
        '/barber/export/finances',
        queryParameters: queryParams,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      print('✅ [ExportService] Finances export response status: ${response.statusCode}');
      
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().split('T')[0].replaceAll('-', '');
      final extension = format == 'excel' ? 'xlsx' : format;
      final file = File('${directory.path}/finanzas_$timestamp.$extension');
      await file.writeAsBytes(response.data);
      
      print('💾 [ExportService] File saved: ${file.path}');
      return file;
    } on DioException catch (e) {
      print('❌ [ExportService] Error en export finances: ${e.response?.statusCode}');
      print('📋 [ExportService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [ExportService] Error inesperado en export finances: $e');
      rethrow;
    }
  }

  /// Exportar clientes
  Future<File> exportClients({String format = 'csv'}) async {
    try {
      print('🌐 [ExportService] GET /barber/export/clients?format=$format');
      final response = await _dio.get(
        '/barber/export/clients',
        queryParameters: {'format': format},
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      print('✅ [ExportService] Clients export response status: ${response.statusCode}');
      
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().split('T')[0].replaceAll('-', '');
      final extension = format == 'excel' ? 'xlsx' : format;
      final file = File('${directory.path}/clientes_$timestamp.$extension');
      await file.writeAsBytes(response.data);
      
      print('💾 [ExportService] File saved: ${file.path}');
      return file;
    } on DioException catch (e) {
      print('❌ [ExportService] Error en export clients: ${e.response?.statusCode}');
      print('📋 [ExportService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [ExportService] Error inesperado en export clients: $e');
      rethrow;
    }
  }

  /// Crear backup completo
  Future<File> exportBackup() async {
    try {
      print('🌐 [ExportService] GET /barber/export/backup');
      final response = await _dio.get(
        '/barber/export/backup',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      print('✅ [ExportService] Backup export response status: ${response.statusCode}');
      
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '').split('.')[0];
      final file = File('${directory.path}/backup_$timestamp.json');
      await file.writeAsBytes(response.data);
      
      print('💾 [ExportService] File saved: ${file.path}');
      return file;
    } on DioException catch (e) {
      print('❌ [ExportService] Error en export backup: ${e.response?.statusCode}');
      print('📋 [ExportService] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ [ExportService] Error inesperado en export backup: $e');
      rethrow;
    }
  }
}

final exportServiceProvider = Provider<ExportService>((ref) {
  final dio = ref.watch(dioProvider);
  return ExportService(dio);
});


import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:system_movil/models/notification_log.dart';
import 'package:system_movil/services/storage/fcm_token_storage.dart';
import 'package:system_movil/services/storage/token_storage.dart';

class _Endpoints {
  // Endpoints según documentación del backend
  static const String devices = '/notifications/devices';
  static const String refreshToken = '/notifications/devices/refresh-token';
  static String deviceById(int id) => '/notifications/devices/$id';
  static String notificationLogs({int? page, int? pageSize}) {
    final basePath = '/notifications/logs';
    final params = <String, String>{
      if (page != null) 'page': '$page',
      if (pageSize != null) 'pageSize': '$pageSize',
    };
    if (params.isEmpty) return basePath;
    final query = params.entries
        .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return '$basePath?$query';
  }
  // Endpoints para gestionar notificaciones (según documentación original)
  static String notificationLogOpened(int id) => '/v1/push/notificationlog/$id/opened';
  static String notificationLogDelete(int id) => '/v1/push/notificationlog/$id';
  static const String notificationLogOpenedAll = '/v1/push/notificationlog/opened-all';
  static const String notificationLogDeleteAll = '/v1/push/notificationlog/delete-all';
}

class FcmApi {
  final Dio _dio;
  final FcmTokenStorage _storage;
  final TokenStorage _tokenStorage;

  FcmApi(this._dio, this._storage, this._tokenStorage);

  /// Registrar dispositivo con token FCM
  /// Endpoint: POST /api/notifications/devices
  /// Respuesta: 201 Created o 200 OK (si ya existe)
  Future<DeviceDto?> createDevice({required String fcmToken}) async {
    final access = await _tokenStorage.getAccessToken();
    if (access == null || access.isEmpty) {
      throw Exception('No access token available to resolve userId.');
    }

    final platform = _detectPlatform();
    
    final data = <String, dynamic>{
      'fcmToken': fcmToken,
      'platform': platform,
    };

    final headers = {
      ..._dio.options.headers,
      'Authorization': 'Bearer $access',
    };

    try {
      final response = await _dio.post(
        _Endpoints.devices,
        data: data,
        options: Options(headers: headers),
      );
      
      // Guardar token localmente
      await _storage.saveFcmToken(fcmToken);
      
      // Retornar dispositivo creado/actualizado
      if (response.data != null) {
        return DeviceDto.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (e is DioException) {
        final status = e.response?.statusCode;
        
        if (status == 200 || status == 201) {
          await _storage.saveFcmToken(fcmToken);
          if (e.response?.data != null) {
            return DeviceDto.fromJson(e.response!.data as Map<String, dynamic>);
          }
          return null;
        }
        if (status == 403) {
          await _storage.saveFcmToken(fcmToken);
          return null; // No lanzar excepción para 403
        }
      }
      rethrow;
    }
  }

  /// Actualizar token FCM del dispositivo
  /// Endpoint: POST /api/notifications/devices/refresh-token
  Future<void> refreshDeviceFcmToken({required String newFcmToken}) async {
    final current = await _storage.getFcmToken();
    final access = await _tokenStorage.getAccessToken();
    final platform = _detectPlatform();

    final data = <String, dynamic>{
      'newFcmToken': newFcmToken,
      'platform': platform,
      if (current != null && current.isNotEmpty) 'currentFcmToken': current,
    };

    final headers = {
      ..._dio.options.headers,
      if (access != null && access.isNotEmpty) 'Authorization': 'Bearer $access',
    };

    try {
      await _dio.post(
        _Endpoints.refreshToken,
        data: data,
        options: Options(headers: headers),
      );
      await _storage.saveFcmToken(newFcmToken);
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener token FCM almacenado
  Future<String?> getStoredFcmToken() => _storage.getFcmToken();

  /// Detectar plataforma actual
  String _detectPlatform() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'web';
    }
  }

  /// Obtener mis dispositivos registrados
  /// Endpoint: GET /api/notifications/devices
  Future<List<DeviceDto>> getMyDevices() async {
    final access = await _tokenStorage.getAccessToken();
    if (access == null || access.isEmpty) {
      throw Exception('No access token available');
    }

    final headers = {
      ..._dio.options.headers,
      'Authorization': 'Bearer $access',
    };

    try {
      final response = await _dio.get(
        _Endpoints.devices,
        options: Options(headers: headers),
      );

      if (response.data is List) {
        return (response.data as List)
            .map((item) => DeviceDto.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }

  /// Eliminar dispositivo
  /// Endpoint: DELETE /api/notifications/devices/{id}
  Future<void> deleteDevice(int deviceId) async {
    final access = await _tokenStorage.getAccessToken();
    if (access == null || access.isEmpty) {
      throw Exception('No access token available');
    }

    final headers = {
      ..._dio.options.headers,
      'Authorization': 'Bearer $access',
    };

    try {
      await _dio.delete(
        _Endpoints.deviceById(deviceId),
        options: Options(headers: headers),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener historial de notificaciones del usuario
  /// Endpoint: GET /api/notifications/logs?page=1&pageSize=50
  Future<List<NotificationLogDto>> getNotificationLogs({
    int page = 1,
    int pageSize = 50,
  }) async {
    final access = await _tokenStorage.getAccessToken();
    if (access == null || access.isEmpty) {
      throw Exception('No access token available');
    }

    final headers = {
      ..._dio.options.headers,
      'Authorization': 'Bearer $access',
    };

    try {
      final endpoint = _Endpoints.notificationLogs(page: page, pageSize: pageSize);
      
      final response = await _dio.get(
        endpoint,
        options: Options(headers: headers),
      );

      if (response.data is List) {
        return (response.data as List)
            .map((item) => NotificationLogDto.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }

  /// Marcar notificación como leída
  /// Endpoint: POST /v1/push/notificationlog/{id}/opened
  Future<void> markNotificationAsOpened(int notificationLogId) async {
    final access = await _tokenStorage.getAccessToken();
    if (access == null || access.isEmpty) {
      throw Exception('No access token available');
    }

    final headers = {
      ..._dio.options.headers,
      'Authorization': 'Bearer $access',
    };

    final endpoint = _Endpoints.notificationLogOpened(notificationLogId);

    try {
      await _dio.post(
        endpoint,
        data: {'id': notificationLogId},
        options: Options(headers: headers),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar notificación
  /// Endpoint: DELETE /v1/push/notificationlog/{id}
  Future<void> deleteNotificationLog(int notificationLogId) async {
    final access = await _tokenStorage.getAccessToken();
    if (access == null || access.isEmpty) {
      throw Exception('No access token available');
    }

    final headers = {
      ..._dio.options.headers,
      'Authorization': 'Bearer $access',
    };

    final endpoint = _Endpoints.notificationLogDelete(notificationLogId);

    try {
      await _dio.delete(
        endpoint,
        options: Options(headers: headers),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Marcar todas las notificaciones como leídas
  /// Endpoint: POST /v1/push/notificationlog/opened-all
  Future<void> markAllNotificationsAsOpened() async {
    final access = await _tokenStorage.getAccessToken();
    if (access == null || access.isEmpty) {
      throw Exception('No access token available');
    }

    final headers = {
      ..._dio.options.headers,
      'Authorization': 'Bearer $access',
    };

    final endpoint = _Endpoints.notificationLogOpenedAll;

    try {
      await _dio.post(
        endpoint,
        data: {},
        options: Options(headers: headers),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar todas las notificaciones
  /// Endpoint: DELETE /v1/push/notificationlog/delete-all
  Future<void> deleteAllNotificationLogs() async {
    final access = await _tokenStorage.getAccessToken();
    if (access == null || access.isEmpty) {
      throw Exception('No access token available');
    }

    final headers = {
      ..._dio.options.headers,
      'Authorization': 'Bearer $access',
    };

    try {
      await _dio.delete(
        _Endpoints.notificationLogDeleteAll,
        options: Options(headers: headers),
      );
    } catch (e) {
      rethrow;
    }
  }
}

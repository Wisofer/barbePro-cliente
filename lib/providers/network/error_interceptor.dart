import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor centralizado para manejo de errores y métricas de Dio.
/// Si se recibe 403 con code "TRIAL_EXPIRED", se llama a [onTrialExpired].
class ErrorInterceptor extends Interceptor {
  ErrorInterceptor({this.onTrialExpired});

  final void Function()? onTrialExpired;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 403) {
      final data = err.response!.data;
      if (data is Map<String, dynamic> && data['code'] == 'TRIAL_EXPIRED') {
        onTrialExpired?.call();
      }
    }
    final userFriendlyMessage = _translateError(err);
    
    // 🐛 FIX: No loguear 404 esperados (comportamiento normal, no errores)
    final isExpected404 = _isExpected404(err);
    
    // Log en modo debug (solo si no es un 404 esperado)
    if (kDebugMode && !isExpected404) {
    }
    
    // Crear un nuevo error con mensaje traducido
    final error = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: userFriendlyMessage,
      stackTrace: err.stackTrace,
    );
    
    handler.next(error);
  }
  
  /// Verificar si un 404 es esperado (comportamiento normal, no un error)
  bool _isExpected404(DioException err) {
    if (err.response?.statusCode != 404) {
      return false;
    }
    
    final path = err.requestOptions.path.toLowerCase();
    final message = err.response?.data?.toString().toLowerCase() ?? '';
    
    // 404 esperados (comportamiento normal):
    // - No hay reacciones en shared posts
    // - No hay notificaciones para el usuario
    // - No hay NotificationLogs
    final expectedMessages = [
      'no se encontraron reacciones',
      'no se encontraron notificationlogs',
      'no se encontraron notificaciones',
    ];
    
    final expectedPaths = [
      '/v1/social/shared/jobpost/reaction',
      '/v1/push/user/notificationlog',
    ];
    
    // Verificar si el mensaje o path indican que es un 404 esperado
    final isExpectedMessage = expectedMessages.any((expected) => message.contains(expected));
    final isExpectedPath = expectedPaths.any((expected) => path.contains(expected));
    
    return isExpectedMessage || isExpectedPath;
  }

  /// Traduce errores de Dio a mensajes amigables para el usuario
  String _translateError(DioException error) {
    // Errores de red
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Tiempo de espera agotado. Verifica tu conexión a internet.';
    }
    
    if (error.type == DioExceptionType.connectionError) {
      return 'Error de conexión. Verifica tu conexión a internet.';
    }
    
    // Errores HTTP
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final responseData = error.response!.data;
      
      // Extraer mensaje del backend si existe
      String? backendMessage;
      if (responseData is Map<String, dynamic>) {
        final errorMessages = responseData['errorMessages'];
        if (errorMessages is List && errorMessages.isNotEmpty) {
          backendMessage = errorMessages.first.toString();
        } else if (errorMessages is String) {
          backendMessage = errorMessages;
        }
      }
      
      // Traducir códigos de estado comunes
      switch (statusCode) {
        case 400:
          return backendMessage ?? 'Solicitud inválida. Verifica los datos ingresados.';
        case 401:
          return backendMessage ?? 'No autorizado. Por favor, inicia sesión nuevamente.';
        case 403:
          return backendMessage ?? 'Acceso denegado. No tienes permisos para esta acción.';
        case 404:
          return backendMessage ?? 'Recurso no encontrado.';
        case 409:
          return backendMessage ?? 'Conflicto. El recurso ya existe o está en uso.';
        case 422:
          return backendMessage ?? 'Datos inválidos. Verifica la información ingresada.';
        case 429:
          return 'Demasiadas solicitudes. Por favor, espera un momento.';
        case 500:
          return backendMessage ?? 'Error del servidor. Por favor, intenta más tarde.';
        case 502:
          return 'Servicio no disponible temporalmente. Intenta más tarde.';
        case 503:
          return 'Servicio en mantenimiento. Intenta más tarde.';
        default:
          return backendMessage ?? 'Error desconocido ($statusCode).';
      }
    }
    
    // Error genérico
    return error.message ?? 'Error de conexión. Intenta nuevamente.';
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log de respuestas exitosas en modo debug
    if (kDebugMode) {
      final statusCode = response.statusCode;
      final method = response.requestOptions.method;
      final path = response.requestOptions.path;
      
      // Solo loguear si no es 200/201/204 (para reducir ruido)
      if (statusCode != null && statusCode >= 300) {
      }
    }
    
    handler.next(response);
  }
}


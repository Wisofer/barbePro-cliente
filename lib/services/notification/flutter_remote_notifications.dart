import 'dart:developer' as developer;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:system_movil/services/notification/flutter_local_notifications.dart';
import 'package:system_movil/services/notification/fcm_api.dart';
import 'package:system_movil/services/notification/notification_handler.dart';
import 'package:system_movil/services/navigation/navigation_service.dart';

/// Handler para mensajes en background (debe ser top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('Mensaje en background: ${message.messageId} data=${message.data}');
  
  final type = (message.data['type'] ?? message.data['route'] ?? '')
      .toString()
      .toLowerCase();
  
  // Tipos de notificaciones que NO se muestran en foreground
  const suppressedInForeground = {'post', 'comment', 'message'};

  if (suppressedInForeground.contains(type)) {
    developer.log('Notificación suprimida en background para type="$type"');
    return;
  }

  // Mostrar notificación local
  await FlutterLocalNotifications.showNotificationFromMessage(message);
}

class FlutterRemoteNotifications {
  static Ref? _ref;
  
  static Future<void> init(FcmApi fcmApi, {Ref? ref}) async {
    _ref = ref;
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // ✅ Solicitar permisos (iOS & Android 13+)
    NotificationSettings settings;
    try {
      settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (e, stackTrace) {
      developer.log('Error al solicitar permisos', error: e, stackTrace: stackTrace);
      rethrow;
    }

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        break;
      case AuthorizationStatus.denied:
        return;
      case AuthorizationStatus.notDetermined:
        return;
      case AuthorizationStatus.provisional:
        break;
    }

    // ✅ Habilitar auto-init de FCM
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // ✅ Registrar handler de mensajes en background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // ✅ Obtener token FCM
    String? token = await messaging.getToken();

    // ✅ Manejar cuando se abre la app desde una notificación (foreground/background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log('App abierta desde notificación: ${message.messageId}');
      final payload = json.encode({
        'type': message.data['type'] ?? message.data['route'] ?? 'home',
        if (message.data.containsKey('deeplink')) 'deeplink': message.data['deeplink'],
        'data': message.data,
      });
      NavigationService.navigateFromPayload(payload);
    });

    // ✅ Manejar mensajes cuando la app está en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log('Foreground message recibido: id=${message.messageId} data=${message.data}');
      
      final type = (message.data['type'] ?? message.data['route'] ?? '')
          .toString()
          .toLowerCase();
      const suppressedInForeground = {'post', 'comment', 'message'};

      if (suppressedInForeground.contains(type)) {
        developer.log('Notificación suprimida en foreground para type="$type"');
        return;
      }

      // Procesar notificación (actualizar contadores, refrescar dashboard, etc.)
      NotificationHandler.handleNotification(message);

      // Mostrar notificación local
      FlutterLocalNotifications.showNotificationFromMessage(message);
    });

    // ✅ Manejar cold start: app abierta desde notificación cuando estaba cerrada
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      developer.log('Cold start desde notificación: ${initialMessage.messageId}');
      final payload = json.encode({
        'type': initialMessage.data['type'] ?? initialMessage.data['route'] ?? 'home',
        if (initialMessage.data.containsKey('deeplink'))
          'deeplink': initialMessage.data['deeplink'],
        'data': initialMessage.data,
      });
      NavigationService.navigateFromPayload(payload);
    }

    // ✅ Sincronizar token inicial con el backend
    if (token != null && token.isNotEmpty) {
      await _syncFcmToken(fcmApi, token);
    } else {
      developer.log('FCM token not available yet; waiting for onTokenRefresh');
    }

    // ✅ Escuchar cambios/refrescos del token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      developer.log('FCM token refreshed: $newToken');
      if (newToken.isNotEmpty) {
        await _syncFcmToken(fcmApi, newToken);
      }
    });
  }

  static Future<void> _syncFcmToken(FcmApi fcmApi, String token) async {
    try {
      final stored = await fcmApi.getStoredFcmToken();
      
      if (stored == null || stored.isEmpty) {
        // Registrar dispositivo nuevo
        await fcmApi.createDevice(fcmToken: token);
      } else if (stored != token) {
        // Actualizar token existente
        await fcmApi.refreshDeviceFcmToken(newFcmToken: token);
      }
    } catch (e, s) {
      developer.log('Error syncing device FCM token', error: e, stackTrace: s);
    }
  }
}

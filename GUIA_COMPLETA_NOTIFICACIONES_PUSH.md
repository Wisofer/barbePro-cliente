# 📱 Guía Completa: Implementación de Notificaciones Push en Flutter

## 📋 Tabla de Contenidos

1. [Dependencias](#1-dependencias)
2. [Configuración de Firebase](#2-configuración-de-firebase)
3. [Configuración de Android](#3-configuración-de-android)
4. [Configuración de iOS](#4-configuración-de-ios)
5. [Archivos a Crear](#5-archivos-a-crear)
6. [Archivos a Modificar](#6-archivos-a-modificar)
7. [Implementación del UI](#7-implementación-del-ui)
8. [Flujo Completo](#8-flujo-completo)
9. [Pruebas](#9-pruebas)

---

## 1. Dependencias

### 1.1 Agregar al `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^4.1.0
  firebase_messaging: ^16.0.1

  # Notifications
  flutter_local_notifications: ^19.4.1
  permission_handler: ^11.3.1

  # JWT Decoder (para obtener userId del token)
  jwt_decoder: ^2.0.1

  # State Management (si usas Riverpod)
  flutter_riverpod: ^2.6.1

  # Storage
  flutter_secure_storage: ^9.2.4
```

### 1.2 Instalar dependencias

```bash
flutter pub get
```

---

## 2. Configuración de Firebase

### 2.1 Instalar FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 2.2 Configurar Firebase en el proyecto

```bash
# Navegar a la carpeta del proyecto
cd tu-proyecto

# Iniciar sesión en Firebase
firebase login

# Configurar Firebase para Flutter
flutterfire configure --project=tu-proyecto-id --platforms=android,ios --yes
```

**Nota:** Esto generará:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- Actualizará `firebase.json`

### 2.3 Verificar configuración

Asegúrate de que `firebase.json` tenga el proyecto correcto:

```json
{
  "flutter": {
    "platforms": {
      "android": {
        "default": {
          "projectId": "tu-proyecto-id",
          "appId": "1:xxxxx:android:xxxxx",
          "fileOutput": "android/app/google-services.json"
        }
      },
      "dart": {
        "lib/firebase_options.dart": {
          "projectId": "tu-proyecto-id",
          "configurations": {
            "android": "1:xxxxx:android:xxxxx",
            "ios": "1:xxxxx:ios:xxxxx"
          }
        }
      }
    }
  }
}
```

---

## 3. Configuración de Android

### 3.1 `android/app/build.gradle.kts`

**Agregar el plugin de Google Services:**

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // ✅ Google services plugin para Firebase
    id("com.google.gms.google-services")
}

dependencies {
    // ✅ Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:34.2.0"))
    // ✅ Dependencias de Firebase
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-messaging")
}
```

### 3.2 `android/build.gradle.kts` (nivel proyecto)

**Agregar el classpath de Google Services:**

```kotlin
buildscript {
    dependencies {
        // ... otras dependencias
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

### 3.3 `android/app/src/main/AndroidManifest.xml`

**Agregar permisos y configuración de Firebase:**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- ✅ Permiso para notificaciones (Android 13+) -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application
        android:label="TuApp"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- ✅ Firebase Messaging Default Channel -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance_channel" />
        
        <!-- ✅ Firebase Messaging Auto Init -->
        <meta-data
            android:name="firebase_messaging_auto_init_enabled"
            android:value="true" />
        
        <!-- ✅ Firebase Analytics -->
        <meta-data
            android:name="firebase_analytics_collection_enabled"
            android:value="true" />
        
        <!-- ... resto de la configuración -->
    </application>
</manifest>
```

### 3.4 Verificar `google-services.json`

Asegúrate de que el archivo `android/app/google-services.json` existe y tiene la configuración correcta de tu proyecto Firebase.

---

## 4. Configuración de iOS

### 4.1 Crear `ios/Runner/GoogleService-Info.plist`

**Copiar desde Firebase Console o crear manualmente:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CLIENT_ID</key>
    <string>1:xxxxx:ios:xxxxx</string>
    <key>REVERSED_CLIENT_ID</key>
    <string>com.googleusercontent.apps.xxxxx</string>
    <key>API_KEY</key>
    <string>AIzaSy...</string>
    <key>GCM_SENDER_ID</key>
    <string>xxxxx</string>
    <key>PLIST_VERSION</key>
    <string>1</string>
    <key>BUNDLE_ID</key>
    <string>com.tuapp.bundle</string>
    <key>PROJECT_ID</key>
    <string>tu-proyecto-id</string>
    <key>STORAGE_BUCKET</key>
    <string>tu-proyecto-id.firebasestorage.app</string>
    <key>IS_ADS_ENABLED</key>
    <false/>
    <key>IS_ANALYTICS_ENABLED</key>
    <false/>
    <key>IS_APPINVITE_ENABLED</key>
    <true/>
    <key>IS_GCM_ENABLED</key>
    <true/>
    <key>IS_SIGNIN_ENABLED</key>
    <true/>
    <key>GOOGLE_APP_ID</key>
    <string>1:xxxxx:ios:xxxxx</string>
</dict>
</plist>
```

**Nota:** Los valores los puedes obtener de `lib/firebase_options.dart` o desde Firebase Console.

### 4.2 Habilitar Push Notifications en Xcode

1. Abre `ios/Runner.xcworkspace` en Xcode
2. Selecciona el target `Runner`
3. Ve a la pestaña "Signing & Capabilities"
4. Haz clic en "+ Capability"
5. Agrega "Push Notifications"
6. Agrega "Background Modes" y marca "Remote notifications"

### 4.3 Configurar permisos en `ios/Runner/Info.plist`

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

---

## 5. Archivos a Crear

### 5.1 `lib/services/storage/fcm_token_storage.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacenamiento seguro del token FCM
class FcmTokenStorage {
  final _storage = FlutterSecureStorage();
  static const _fcmKey = 'fcm_token';

  /// Guardar token FCM
  Future<void> saveFcmToken(String token) async {
    await _storage.write(key: _fcmKey, value: token);
  }

  /// Obtener token FCM guardado
  Future<String?> getFcmToken() => _storage.read(key: _fcmKey);

  /// Eliminar token FCM (útil para logout)
  Future<void> clear() async {
    await _storage.delete(key: _fcmKey);
  }
}
```

### 5.2 `lib/services/notification/flutter_local_notifications.dart`

```dart
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:system_movil/services/navigation/navigation_service.dart';

const String kHighImportanceChannelId = 'high_importance_channel';
const String kHighImportanceChannelName = 'Notificaciones Importantes';
const String kHighImportanceChannelDescription = 'Canal para notificaciones en primer plano.';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class FlutterLocalNotifications {
  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        developer.log('Notificación pulsada. payload=${response.payload}');
        if (response.payload != null) {
          NavigationService.navigateFromPayload(response.payload);
        }
      },
    );

    // Crear canal de notificaciones para Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      kHighImportanceChannelId,
      kHighImportanceChannelName,
      description: kHighImportanceChannelDescription,
      importance: Importance.high,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> showNotificationFromMessage(RemoteMessage message) async {
    final n = message.notification;
    final title = n?.title ?? message.data['title'] ?? 'TuApp';
    final body = n?.body ?? message.data['body'] ?? '';

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      kHighImportanceChannelId,
      kHighImportanceChannelName,
      channelDescription: kHighImportanceChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.message,
      showWhen: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final payload = json.encode({
      'type': message.data['type'] ?? message.data['route'] ?? 'home',
      if (message.data.containsKey('deeplink')) 'deeplink': message.data['deeplink'],
      'data': message.data,
    });

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }
}
```

### 5.3 `lib/services/notification/flutter_remote_notifications.dart`

```dart
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:system_movil/services/notification/flutter_local_notifications.dart';
import 'package:system_movil/services/notification/fcm_api.dart';
import 'package:system_movil/services/notification/notification_handler.dart';
import 'package:system_movil/services/navigation/navigation_service.dart';
import 'package:system_movil/providers/notifications_provider.dart';

/// Handler para mensajes en background (debe ser top-level)
/// IMPORTANTE: Este handler se ejecuta cuando la app está en background O completamente cerrada
/// Cuando la app está cerrada (terminated), el sistema operativo ya muestra la notificación automáticamente,
/// por lo que NO debemos mostrar una notificación local adicional para evitar duplicados.
/// 
/// NOTA: Este handler NO puede acceder a Riverpod providers directamente porque corre en un isolate separado.
/// La actualización del badge se hará cuando la app se abra y cargue las notificaciones del backend.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('Mensaje en background handler: ${message.messageId} data=${message.data}');
  
  final type = (message.data['type'] ?? message.data['route'] ?? '')
      .toString()
      .toLowerCase();
  
  // Tipos de notificaciones que NO se muestran
  const suppressedTypes = {'post', 'comment', 'message'};

  if (suppressedTypes.contains(type)) {
    developer.log('Notificación suprimida en background para type="$type"');
    return;
  }

  // ⚠️ IMPORTANTE: NO mostrar notificación local aquí
  // Cuando la app está completamente cerrada (terminated), el sistema operativo
  // ya muestra la notificación automáticamente desde FCM.
  // Si mostramos una notificación local aquí, se duplicaría.
  
  developer.log('Notificación procesada en background handler (sistema mostrará la notificación)');
}

class FlutterRemoteNotifications {
  static Ref? _ref;
  static bool _initialized = false;
  static StreamSubscription<RemoteMessage>? _onMessageSubscription;
  static StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;
  
  static Future<void> init(FcmApi fcmApi, {Ref? ref}) async {
    // ✅ Protección contra inicialización múltiple
    if (_initialized) {
      developer.log('FCM ya está inicializado, omitiendo inicialización duplicada');
      return;
    }
    
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

    // ✅ ESCENARIO 2: Manejar cuando se abre la app desde una notificación (BACKGROUND)
    await _onMessageOpenedAppSubscription?.cancel();
    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log('📱 [BACKGROUND] App abierta desde notificación: ${message.messageId}');
      
      // ✅ Actualizar badge de notificaciones cuando se abre desde background
      if (_ref != null) {
        try {
          _ref!.read(notificationsProvider.notifier).refresh();
        } catch (e) {
          // Error silencioso
        }
      }
      
      final payload = json.encode({
        'type': message.data['type'] ?? message.data['route'] ?? 'home',
        if (message.data.containsKey('deeplink')) 'deeplink': message.data['deeplink'],
        'data': message.data,
      });
      NavigationService.navigateFromPayload(payload);
    });

    // ✅ ESCENARIO 1: Manejar mensajes cuando la app está en FOREGROUND (abierta y visible)
    await _onMessageSubscription?.cancel();
    _onMessageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log('📱 [FOREGROUND] Notificación recibida: id=${message.messageId}');
      
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

      // ✅ Mostrar notificación local (el sistema NO la muestra automáticamente en foreground)
      FlutterLocalNotifications.showNotificationFromMessage(message);
    });

    // ✅ ESCENARIO 3: Manejar cold start (app completamente CERRADA)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      developer.log('📱 [TERMINATED] Cold start desde notificación: ${initialMessage.messageId}');
      
      // ✅ Actualizar badge de notificaciones cuando se abre desde terminated
      if (_ref != null) {
        try {
          _ref!.read(notificationsProvider.notifier).refresh();
        } catch (e) {
          // Error silencioso
        }
      }
      
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
    
    // ✅ Marcar como inicializado
    _initialized = true;
    developer.log('FCM inicializado correctamente');
  }
  
  /// Resetear estado de inicialización (útil para testing o logout)
  static void reset() {
    _initialized = false;
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();
    _onMessageSubscription = null;
    _onMessageOpenedAppSubscription = null;
    _ref = null;
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
```

### 5.4 `lib/services/notification/fcm_api.dart`

```dart
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
  // Endpoints para gestionar notificaciones
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
      
      await _storage.saveFcmToken(fcmToken);
      
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
          return null;
        }
      }
      rethrow;
    }
  }

  /// Actualizar token FCM del dispositivo
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

  /// Obtener historial de notificaciones del usuario
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
```

### 5.5 `lib/models/notification_log.dart`

```dart
import 'dart:convert';

/// Modelo de dispositivo según documentación del backend
class DeviceDto {
  final int id;
  final String fcmToken;
  final String platform; // "android" o "ios"
  final DateTime? lastActiveAt;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceDto({
    required this.id,
    required this.fcmToken,
    required this.platform,
    this.lastActiveAt,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeviceDto.fromJson(Map<String, dynamic> json) {
    return DeviceDto(
      id: json['id'] ?? 0,
      fcmToken: json['fcmToken'] ?? '',
      platform: json['platform'] ?? '',
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'])
          : null,
      userId: json['userId'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Modelo de log de notificación según documentación del backend
class NotificationLogDto {
  final int id;
  final String status; // "sent", "opened", "failed"
  final String payload; // JSON string con el payload
  final DateTime sentAt;
  final int? deviceId;
  final int? templateId;
  final int userId;
  final DateTime createdAt;

  NotificationLogDto({
    required this.id,
    required this.status,
    required this.payload,
    required this.sentAt,
    this.deviceId,
    this.templateId,
    required this.userId,
    required this.createdAt,
  });

  factory NotificationLogDto.fromJson(Map<String, dynamic> json) {
    return NotificationLogDto(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'sent',
      payload: json['payload'] ?? '{}',
      sentAt: DateTime.parse(json['sentAt'] ?? DateTime.now().toIso8601String()),
      deviceId: json['deviceId'],
      templateId: json['templateId'],
      userId: json['userId'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Obtener datos parseados del payload
  Map<String, dynamic> get parsedPayload {
    try {
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  /// Obtener título de la notificación
  String get title {
    final data = parsedPayload;
    return data['title'] ?? data['notification']?['title'] ?? 'Notificación';
  }

  /// Obtener cuerpo de la notificación
  String get body {
    final data = parsedPayload;
    return data['body'] ?? data['notification']?['body'] ?? data['message'] ?? '';
  }

  /// Obtener tipo de notificación
  String get type {
    final data = parsedPayload;
    return data['type'] ?? data['route'] ?? 'unknown';
  }
}
```

### 5.6 `lib/services/notification/notification_handler.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../providers/pending_appointments_provider.dart';
import '../../providers/dashboard_refresh_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../utils/snackbar_helper.dart';

/// Handler centralizado para procesar notificaciones y actualizar la UI
class NotificationHandler {
  static Ref? _ref;
  
  /// Inicializar el handler con el ref
  static void initialize(Ref ref) {
    _ref = ref;
  }
  
  /// Procesar notificación de tipo "appointment" cuando la app está en foreground
  static void handleAppointmentNotification(RemoteMessage message) {
    final data = message.data;
    final type = (data['type'] ?? '').toString().toLowerCase();
    
    if (type != 'appointment') {
      return;
    }
    
    // Obtener información de la cita
    final clientName = data['clientName'] ?? data['data']?['clientName'] ?? 'Cliente';
    final date = data['date'] ?? data['data']?['date'] ?? '';
    final time = data['time'] ?? data['data']?['time'] ?? '';
    
    // Refrescar contador de citas pendientes y badge de notificaciones
    if (_ref != null) {
      try {
        _ref!.read(pendingAppointmentsProvider.notifier).refresh();
        _ref!.read(dashboardRefreshProvider.notifier).refresh();
        // ✅ Actualizar badge de notificaciones automáticamente
        _ref!.read(notificationsProvider.notifier).refresh();
      } catch (e) {
        // Error silencioso
      }
    }
    
    // Mostrar snackbar discreto
    _showAppointmentSnackbar(clientName, date, time);
  }
  
  /// Mostrar snackbar cuando llega una notificación de cita
  static void _showAppointmentSnackbar(String clientName, String date, String time) {
    try {
      SnackbarHelper.showInfo(
        title: 'Nueva cita recibida',
        message: '$clientName agendó una cita para el $date a las $time',
      );
    } catch (e) {
      // Error silencioso
    }
  }
  
  /// Procesar cualquier notificación y actualizar providers necesarios
  static void handleNotification(RemoteMessage message) {
    final data = message.data;
    final type = (data['type'] ?? '').toString().toLowerCase();
    
    switch (type) {
      case 'appointment':
        // handleAppointmentNotification ya actualiza el badge, no duplicar
        handleAppointmentNotification(message);
        break;
      default:
        // Para otros tipos de notificaciones, solo actualizar badge
        if (_ref != null) {
          try {
            _ref!.read(notificationsProvider.notifier).refresh();
          } catch (e) {
            // Error silencioso
          }
        }
        break;
    }
  }
}
```

### 5.7 `lib/providers/notifications_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_log.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';

/// Estado de las notificaciones
class NotificationsState {
  final List<NotificationLogDto> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationsState copyWith({
    List<NotificationLogDto>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
    bool clearError = false,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// Notifier para gestionar las notificaciones
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier(this.ref) : super(NotificationsState()) {
    if (_isAuthenticated()) {
      loadNotifications();
    }
  }

  final Ref ref;

  bool _isAuthenticated() {
    final authState = ref.read(authNotifierProvider);
    return authState.isAuthenticated && !authState.isDemoMode;
  }

  /// Cargar notificaciones
  Future<void> loadNotifications({bool showLoading = true}) async {
    if (!_isAuthenticated()) return;

    if (showLoading) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final fcmApi = ref.read(fcmApiProvider);
      final notifications = await fcmApi.getNotificationLogs(page: 1, pageSize: 50);

      final unreadCount = notifications.where((n) => n.status == 'sent').length;

      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        unreadCount: unreadCount,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Marcar notificación como leída
  Future<void> markAsRead(int notificationId) async {
    if (!_isAuthenticated()) return;

    try {
      final fcmApi = ref.read(fcmApiProvider);
      await fcmApi.markNotificationAsOpened(notificationId);
      
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notificationId && n.status == 'sent') {
          return NotificationLogDto(
            id: n.id,
            status: 'opened',
            payload: n.payload,
            sentAt: n.sentAt,
            deviceId: n.deviceId,
            templateId: n.templateId,
            userId: n.userId,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      final unreadCount = updatedNotifications.where((n) => n.status == 'sent').length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      // Si falla el backend, al menos actualizar localmente
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notificationId && n.status == 'sent') {
          return NotificationLogDto(
            id: n.id,
            status: 'opened',
            payload: n.payload,
            sentAt: n.sentAt,
            deviceId: n.deviceId,
            templateId: n.templateId,
            userId: n.userId,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      final unreadCount = updatedNotifications.where((n) => n.status == 'sent').length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    }
  }

  /// Eliminar notificación
  Future<void> deleteNotification(int notificationId) async {
    if (!_isAuthenticated()) return;

    try {
      final fcmApi = ref.read(fcmApiProvider);
      await fcmApi.deleteNotificationLog(notificationId);
      
      final updatedNotifications = state.notifications
          .where((n) => n.id != notificationId)
          .toList();

      final unreadCount = updatedNotifications.where((n) => n.status == 'sent').length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      // Si falla el backend, al menos actualizar localmente
      final updatedNotifications = state.notifications
          .where((n) => n.id != notificationId)
          .toList();

      final unreadCount = updatedNotifications.where((n) => n.status == 'sent').length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    }
  }

  /// Marcar todas como leídas
  Future<void> markAllAsRead() async {
    if (!_isAuthenticated()) return;

    try {
      final fcmApi = ref.read(fcmApiProvider);
      await fcmApi.markAllNotificationsAsOpened();
      
      final updatedNotifications = state.notifications.map((n) {
        if (n.status == 'sent') {
          return NotificationLogDto(
            id: n.id,
            status: 'opened',
            payload: n.payload,
            sentAt: n.sentAt,
            deviceId: n.deviceId,
            templateId: n.templateId,
            userId: n.userId,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      // Si falla el backend, al menos actualizar localmente
      final updatedNotifications = state.notifications.map((n) {
        if (n.status == 'sent') {
          return NotificationLogDto(
            id: n.id,
            status: 'opened',
            payload: n.payload,
            sentAt: n.sentAt,
            deviceId: n.deviceId,
            templateId: n.templateId,
            userId: n.userId,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    }
  }

  /// Refrescar notificaciones
  Future<void> refresh() async {
    await loadNotifications(showLoading: false);
  }
}

/// Provider de notificaciones
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref);
});
```

### 5.8 `lib/providers/dashboard_refresh_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para notificar cuando el dashboard necesita refrescarse
class DashboardRefreshNotifier extends StateNotifier<int> {
  DashboardRefreshNotifier() : super(0);

  /// Forzar refresco del dashboard
  void refresh() {
    state = state + 1;
  }
}

final dashboardRefreshProvider =
    StateNotifierProvider<DashboardRefreshNotifier, int>((ref) {
  return DashboardRefreshNotifier();
});
```

### 5.9 `lib/screens/notifications/notifications_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/notifications_provider.dart';
import '../../models/notification_log.dart';
import '../../services/navigation/navigation_service.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).loadNotifications();
    });
  }

  void _handleNotificationTap(NotificationLogDto notification) {
    ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    final type = notification.type.toLowerCase();
    final data = notification.parsedPayload;

    if (type == 'appointment') {
      final appointmentId = data['appointmentId'] ?? data['data']?['appointmentId'];
      if (appointmentId != null) {
        Navigator.of(context).pop();
        NavigationService.navigateToHome();
      }
    } else if (type == 'announcement') {
      _showAnnouncementDialog(notification);
    }
  }

  void _showAnnouncementDialog(NotificationLogDto notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Text(notification.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _deleteNotification(NotificationLogDto notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar notificación'),
        content: const Text('¿Estás seguro de que deseas eliminar esta notificación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(notificationsProvider.notifier).deleteNotification(notification.id);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notificationsState = ref.watch(notificationsProvider);

    final bgColor = isDark ? const Color(0xFF0A0A0B) : const Color(0xFFF9FAFB);
    final cardColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notificaciones',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        actions: [
          if (notificationsState.unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
              },
              child: Text(
                'Marcar todas',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          IconButton(
            icon: Icon(Iconsax.refresh, color: textColor),
            onPressed: () {
              ref.read(notificationsProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: notificationsState.isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : notificationsState.notifications.isEmpty
              ? _buildEmptyState(mutedColor)
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(notificationsProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notificationsState.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notificationsState.notifications[index];
                      return _buildNotificationItem(
                        notification,
                        cardColor,
                        textColor,
                        mutedColor,
                        isDark,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(Color mutedColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.notification_bing, size: 64, color: mutedColor),
          const SizedBox(height: 16),
          Text(
            'No hay notificaciones',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: mutedColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    NotificationLogDto notification,
    Color cardColor,
    Color textColor,
    Color mutedColor,
    bool isDark,
  ) {
    final isUnread = notification.status == 'sent';
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? const Color(0xFF10B981).withOpacity(0.3)
              : (isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB)),
          width: isUnread ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isUnread
                ? const Color(0xFF10B981).withOpacity(0.1)
                : mutedColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.notification,
            color: isUnread ? const Color(0xFF10B981) : mutedColor,
            size: 24,
          ),
        ),
        title: Text(
          notification.title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: mutedColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(notification.sentAt),
              style: GoogleFonts.inter(
                fontSize: 10,
                color: mutedColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: Icon(Iconsax.more, color: mutedColor, size: 20),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Marcar como leída'),
              onTap: () {
                Future.delayed(Duration.zero, () {
                  ref.read(notificationsProvider.notifier).markAsRead(notification.id);
                });
              },
            ),
            PopupMenuItem(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onTap: () {
                Future.delayed(Duration.zero, () {
                  _deleteNotification(notification);
                });
              },
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }
}
```

---

## 6. Archivos a Modificar

### 6.1 `lib/main.dart`

**Agregar inicialización de Firebase y notificaciones locales:**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:system_movil/firebase_options.dart';
import 'package:system_movil/services/notification/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // ✅ Inicializar notificaciones locales
    await FlutterLocalNotifications.init();
  } catch (e) {
    // Manejar error silenciosamente
  }

  runApp(const ProviderScope(child: SystemMovilApp()));
}
```

### 6.2 `lib/providers/providers.dart`

**Agregar providers de FCM:**

```dart
import '../services/storage/fcm_token_storage.dart';
import '../services/notification/fcm_api.dart';

/// Provides a singleton FcmTokenStorage
final fcmTokenStorageProvider = Provider<FcmTokenStorage>((ref) {
  return FcmTokenStorage();
});

/// Provides FcmApi service for communicating with backend
final fcmApiProvider = Provider<FcmApi>((ref) {
  final dio = ref.watch(dioProvider);
  final fcmStorage = ref.watch(fcmTokenStorageProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return FcmApi(dio, fcmStorage, tokenStorage);
});
```

### 6.3 `lib/providers/auth_provider.dart`

**Agregar inicialización de notificaciones después del login:**

```dart
import '../services/notification/flutter_remote_notifications.dart';
import '../services/notification/notification_handler.dart';

// En el método login(), después de autenticar exitosamente:
try {
  await _initializeNotifications();
} catch (e) {
  // Error silencioso al inicializar notificaciones
}

// En _initializeAuth(), si el usuario ya está autenticado:
try {
  await _initializeNotifications();
} catch (e) {
  // Error silencioso al inicializar notificaciones
}

// Agregar método:
Future<void> _initializeNotifications() async {
  try {
    if (state.isAuthenticated && !state.isDemoMode) {
      final fcmApi = ref.read(fcmApiProvider);
      
      // Inicializar NotificationHandler con el ref
      NotificationHandler.initialize(ref);
      
      await FlutterRemoteNotifications.init(fcmApi, ref: ref);
    }
  } catch (e) {
    // Error silencioso al inicializar notificaciones
  }
}
```

### 6.4 `lib/widgets/app_header.dart`

**Agregar icono de notificaciones con badge:**

```dart
import '../providers/notifications_provider.dart';
import '../screens/notifications/notifications_screen.dart';

// En el build method, dentro del Row de acciones:
Consumer(
  builder: (context, ref, child) {
    final notificationsState = ref.watch(notificationsProvider);
    final unreadCount = notificationsState.unreadCount;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Iconsax.notification,
            color: textColor,
            size: 24,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
          tooltip: 'Notificaciones',
        ),
        if (unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: unreadCount > 99
                  ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                  : const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  },
),
```

### 6.5 `lib/screens/dashboard/dashboard_screen.dart`

**Agregar listener para refrescar automáticamente:**

```dart
import '../../providers/dashboard_refresh_provider.dart';

// En el build method, al inicio:
ref.listen<int>(dashboardRefreshProvider, (previous, next) {
  if (next > 0 && mounted && !_isLoading) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        refresh();
      }
    });
  }
});
```

### 6.6 `lib/services/navigation/navigation_service.dart`

**Agregar manejo de deep linking desde notificaciones:**

```dart
import 'dart:convert';
import '../screens/home_screen.dart';
import '../screens/appointments/appointments_screen.dart';

/// Navigate from notification payload
static void navigateFromPayload(String? payload) {
  if (payload == null || payload.isEmpty) {
    _pushTo(const HomeScreen());
    return;
  }

  try {
    final data = json.decode(payload) as Map<String, dynamic>;
    final type = (data['type'] ?? data['route'] ?? 'home').toString().toLowerCase();
    final deeplink = data['deeplink'] as String?;

    switch (type) {
      case 'appointment':
      case 'cita':
      case 'appointments':
      case 'citas':
        _pushTo(const AppointmentsScreen());
        break;
      default:
        _pushTo(const HomeScreen());
    }
  } catch (e) {
    _pushTo(const HomeScreen());
  }
}
```

---

## 7. Implementación del UI

### 7.1 Icono de Notificaciones en Header

Ya está implementado en la sección 6.4. El badge se actualiza automáticamente cuando:
- Llega una notificación FCM
- Se marca una notificación como leída
- Se elimina una notificación

### 7.2 Pantalla de Notificaciones

Ya está implementada en la sección 5.9. Incluye:
- Lista de notificaciones
- Marcar como leída
- Eliminar notificación
- Marcar todas como leídas
- Pull-to-refresh
- Navegación según tipo de notificación

---

## 8. Flujo Completo

### 8.1 Inicialización (App Start)

```
1. main() → Firebase.initializeApp()
2. main() → FlutterLocalNotifications.init()
3. Usuario hace login
4. auth_provider → _initializeNotifications()
5. NotificationHandler.initialize(ref)
6. FlutterRemoteNotifications.init()
7. Solicitar permisos
8. Registrar token FCM en backend
9. Configurar listeners
```

### 8.2 Notificación Llega (Foreground)

```
1. FirebaseMessaging.onMessage.listen() detecta
2. NotificationHandler.handleNotification()
3. Actualiza badge de notificaciones (refresh)
4. Actualiza contador de citas
5. Refresca dashboard
6. Muestra snackbar
7. Muestra notificación local
```

### 8.3 Notificación Llega (Background)

```
1. Sistema operativo muestra notificación
2. Usuario toca notificación
3. onMessageOpenedApp.listen() detecta
4. Actualiza badge de notificaciones
5. Navega a pantalla correspondiente
```

### 8.4 Notificación Llega (Terminated)

```
1. Sistema operativo muestra notificación
2. Usuario toca notificación
3. App se inicia
4. getInitialMessage() detecta
5. Actualiza badge de notificaciones
6. Navega a pantalla correspondiente
```

---

## 9. Pruebas

### 9.1 Verificar Inicialización

1. Abre la app
2. Haz login
3. Revisa logs: deberías ver "FCM inicializado correctamente"
4. Verifica que el token FCM se registre en el backend

### 9.2 Probar Notificación en Foreground

1. Mantén la app abierta
2. Envía notificación desde Firebase Console o backend
3. Deberías ver:
   - Snackbar informativo
   - Badge actualizado
   - Contador de citas actualizado (si es tipo appointment)
   - Dashboard refrescado (si es tipo appointment)

### 9.3 Probar Notificación en Background

1. Minimiza la app
2. Envía notificación
3. Toca la notificación
4. Deberías ver:
   - App se abre
   - Badge actualizado
   - Navegación a pantalla correspondiente

### 9.4 Probar Notificación en Terminated

1. Cierra completamente la app
2. Envía notificación
3. Toca la notificación
4. Deberías ver:
   - App se inicia
   - Badge actualizado
   - Navegación a pantalla correspondiente

### 9.5 Verificar Badge

1. Abre la app
2. Verifica que el badge muestre el número correcto
3. Marca una notificación como leída
4. Verifica que el badge disminuya
5. Elimina una notificación
6. Verifica que el badge disminuya

---

## 10. Endpoints del Backend Requeridos

### 10.1 Dispositivos

- `POST /notifications/devices` - Registrar dispositivo
- `POST /notifications/devices/refresh-token` - Actualizar token
- `GET /notifications/devices` - Obtener dispositivos del usuario
- `DELETE /notifications/devices/{id}` - Eliminar dispositivo

### 10.2 Notificaciones

- `GET /notifications/logs?page=1&pageSize=50` - Obtener historial
- `POST /v1/push/notificationlog/{id}/opened` - Marcar como leída
- `DELETE /v1/push/notificationlog/{id}` - Eliminar notificación
- `POST /v1/push/notificationlog/opened-all` - Marcar todas como leídas
- `DELETE /v1/push/notificationlog/delete-all` - Eliminar todas

### 10.3 Formato de Notificación FCM

El backend debe enviar notificaciones con este formato:

```json
{
  "notification": {
    "title": "Nueva cita recibida",
    "body": "Juan Pérez agendó una cita para el 15/01/2024 a las 10:00"
  },
  "data": {
    "type": "appointment",
    "appointmentId": "123",
    "clientName": "Juan Pérez",
    "date": "15/01/2024",
    "time": "10:00",
    "status": "Pending"
  }
}
```

**IMPORTANTE:** El backend DEBE guardar el log de notificaciones en la base de datos cuando envía una notificación FCM, de lo contrario no aparecerán en la pantalla de notificaciones.

---

## 11. Troubleshooting

### 11.1 Notificaciones no llegan

- Verificar que Firebase esté configurado correctamente
- Verificar que el token FCM se registre en el backend
- Verificar permisos de notificaciones en el dispositivo
- Revisar logs del backend

### 11.2 Badge no se actualiza

- Verificar que `notificationsProvider.refresh()` se llame
- Verificar que el backend guarde los logs de notificaciones
- Verificar que `AppHeader` observe `notificationsProvider`

### 11.3 Notificaciones duplicadas

- Verificar que el background handler NO muestre notificación local
- Verificar que no haya inicialización múltiple de FCM

### 11.4 Token no se sincroniza

- Verificar que el usuario esté autenticado
- Verificar que el endpoint `/notifications/devices` funcione
- Revisar logs de `_syncFcmToken`

---

## 12. Resumen de Archivos

### Archivos Creados:
- `lib/services/storage/fcm_token_storage.dart`
- `lib/services/notification/flutter_local_notifications.dart`
- `lib/services/notification/flutter_remote_notifications.dart`
- `lib/services/notification/fcm_api.dart`
- `lib/services/notification/notification_handler.dart`
- `lib/models/notification_log.dart`
- `lib/providers/notifications_provider.dart`
- `lib/providers/dashboard_refresh_provider.dart`
- `lib/screens/notifications/notifications_screen.dart`

### Archivos Modificados:
- `pubspec.yaml`
- `lib/main.dart`
- `lib/providers/providers.dart`
- `lib/providers/auth_provider.dart`
- `lib/widgets/app_header.dart`
- `lib/screens/dashboard/dashboard_screen.dart`
- `lib/services/navigation/navigation_service.dart`
- `android/app/build.gradle.kts`
- `android/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/GoogleService-Info.plist`

---

## 13. Checklist Final

- [ ] Dependencias instaladas
- [ ] Firebase configurado
- [ ] Android configurado (build.gradle, AndroidManifest)
- [ ] iOS configurado (GoogleService-Info.plist, Xcode)
- [ ] Todos los archivos creados
- [ ] Todos los archivos modificados
- [ ] Icono de notificaciones en header
- [ ] Pantalla de notificaciones implementada
- [ ] Backend configurado para guardar logs
- [ ] Pruebas realizadas en los 3 escenarios

---

**¡Listo!** Con esta guía puedes implementar notificaciones push completas en cualquier proyecto Flutter.

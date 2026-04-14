import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth.dart';
import '../models/user_profile.dart';
import '../services/api/auth_service.dart';
import '../services/api/account_service.dart';
import '../services/api/barber_service.dart';
import '../services/notification/flutter_remote_notifications.dart';
import '../services/notification/notification_handler.dart';
import '../services/storage/token_storage.dart';
import '../services/storage/trial_welcome_storage.dart';
import '../services/storage/barber_profile_cache.dart';
import 'trial_expired_provider.dart';
import '../utils/jwt_decoder.dart';
import 'providers.dart';

/// Estado inmutable del módulo de autenticación.
@immutable
class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.isInitialized = false,
    this.isLoading = false,
    this.isDemoMode = false,
    this.userToken,
    this.userProfile,
    this.subscription,
    this.errorMessage,
  });

  final bool isAuthenticated;
  final bool isInitialized;
  final bool isLoading;
  final bool isDemoMode;
  final String? userToken;
  final UserProfile? userProfile;
  final SubscriptionDto? subscription;
  final String? errorMessage;

  String? get currentUserId => userProfile?.userId;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isInitialized,
    bool? isLoading,
    bool? isDemoMode,
    String? userToken,
    UserProfile? userProfile,
    SubscriptionDto? subscription,
    String? errorMessage,
    bool clearError = false,
    bool clearProfile = false,
    bool clearSubscription = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      userToken: userToken ?? this.userToken,
      userProfile: clearProfile ? null : (userProfile ?? this.userProfile),
      subscription: clearSubscription ? null : (subscription ?? this.subscription),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  static AuthState initial() => const AuthState();
}

/// Notifier responsable de toda la lógica de autenticación usando Riverpod.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this.ref) : super(AuthState.initial()) {
    _initialize();
  }

  final Ref ref;

  late final Dio _dio;
  late final TokenStorage _tokenStorage;
  AuthService? _authService;
  bool _servicesInitialized = false;

  Future<void> _initialize() async {
    try {
      _dio = ref.read(dioProvider);
      _tokenStorage = TokenStorage();
      _authService = ref.read(authServiceProvider);
      _servicesInitialized = true;
      await _initializeAuth();
    } catch (e) {
      state = state.copyWith(
        isInitialized: true,
        isAuthenticated: false,
        userToken: null,
        clearProfile: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _initializeAuth() async {
    if (!_servicesInitialized) return;

    try {
      final savedToken = await _tokenStorage.getAccessToken();
      final refreshToken = await _tokenStorage.getRefreshToken();
      
      if (savedToken != null && savedToken.isNotEmpty) {
        // Verificar si el token está expirado
        if (JwtDecoder.isTokenExpired(savedToken)) {
          // Token expirado, intentar refrescar antes de limpiar
          
          // Solo intentar refresh si hay refreshToken disponible
          if (refreshToken != null && refreshToken.isNotEmpty) {
            final refreshed = await _tryRefreshToken(refreshToken);
            
            if (refreshed != null && refreshed.isNotEmpty) {
              // Token refrescado exitosamente
              _dio.options.headers['Authorization'] = 'Bearer $refreshed';
              state = state.copyWith(
                userToken: refreshed,
                isAuthenticated: true,
              );
              // Cargar perfil del usuario
              await loadUserProfile();
            } else {
              // No se pudo refrescar, limpiar y pedir login
              await _clearAuthState();
            }
          } else {
            // No hay refreshToken, limpiar y pedir login
            await _clearAuthState();
          }
        } else {
          // Token válido, configurar header
          _dio.options.headers['Authorization'] = 'Bearer $savedToken';
          state = state.copyWith(
            userToken: savedToken,
            isAuthenticated: true,
          );
          // Cargar perfil del usuario
          await loadUserProfile();
          // ✅ Inicializar notificaciones si el usuario ya estaba autenticado
          try {
            await initializeNotifications();
          } catch (e) {
            // Error silencioso al inicializar notificaciones
          }
        }
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          userToken: null,
          clearProfile: true,
        );
      }
    } catch (e) {
      await _clearAuthState();
    } finally {
      state = state.copyWith(isInitialized: true);
    }
  }

  /// Inicializar notificaciones remotas (FCM). Público para llamar desde Home.
  Future<void> initializeNotifications() async {
    try {
      // Solo inicializar si el usuario está autenticado y no está en modo demo
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

  /// Intenta refrescar el token usando el refresh token
  Future<String?> _tryRefreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data;
        if (raw is Map) {
          _applyUserFromRefreshData(Map<String, dynamic>.from(raw));
        }
        final newToken = response.data['token'] as String?;
        final newRefreshToken = response.data['refreshToken'] as String?;
        
        if (newToken != null && newToken.isNotEmpty) {
          // Guardar ambos tokens (access y refresh)
          await _tokenStorage.saveTokens(
            newToken, 
            newRefreshToken ?? newToken, // Si no hay nuevo refreshToken, usar el mismo
          );
          return newToken;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  void _applyUserFromRefreshData(Map<String, dynamic>? data) {
    final userJson = data?['user'];
    if (userJson == null || userJson is! Map<String, dynamic>) return;
    try {
      final user = UserDto.fromJson(userJson);
      final prev = state.userProfile;
      if (prev == null) return;
      var merged = _mergeUserDeletionIntoProfile(prev, user);
      final sub = user.subscription;
      if (sub != null) {
        merged = UserProfile(
          userId: merged.userId,
          userName: merged.userName,
          role: merged.role,
          nombre: merged.nombre,
          apellido: merged.apellido,
          email: merged.email,
          phone: merged.phone,
          direccion: merged.direccion,
          avatar: merged.avatar,
          latitude: merged.latitude,
          longitude: merged.longitude,
          address: merged.address,
          sexo: merged.sexo,
          fechaNacimiento: merged.fechaNacimiento,
          dni: merged.dni,
          lugarNacimiento: merged.lugarNacimiento,
          domicilio: merged.domicilio,
          estadoCivil: merged.estadoCivil,
          ocupacion: merged.ocupacion,
          profileImageUrl: merged.profileImageUrl,
          coverImageUrl: merged.coverImageUrl,
          iconImageUrl: merged.iconImageUrl,
          handle: merged.handle,
          displayName: merged.displayName,
          description: merged.description,
          countryCode: merged.countryCode,
          nationalNumber: merged.nationalNumber,
          country: merged.country,
          starCount: merged.starCount,
          hasRated: merged.hasRated,
          accountDeletionPending: merged.accountDeletionPending,
          accountDeletionRequestedAtUtc: merged.accountDeletionRequestedAtUtc,
          accountDeletionScheduledForUtc: merged.accountDeletionScheduledForUtc,
          accountDeletionGracePeriodDays: merged.accountDeletionGracePeriodDays,
          trialEndsAt: sub.trialEndsAt ?? merged.trialEndsAt,
          isPro: sub.isProActive || merged.isPro,
        );
      }
      state = state.copyWith(
        userProfile: merged,
        subscription: sub ?? state.subscription,
      );
    } catch (_) {}
  }

  UserProfile _mergeUserDeletionIntoProfile(UserProfile prev, UserDto user) {
    return UserProfile(
      userId: prev.userId,
      userName: prev.userName,
      role: prev.role,
      nombre: prev.nombre,
      apellido: prev.apellido,
      email: prev.email,
      phone: prev.phone,
      direccion: prev.direccion,
      avatar: prev.avatar,
      latitude: prev.latitude,
      longitude: prev.longitude,
      address: prev.address,
      sexo: prev.sexo,
      fechaNacimiento: prev.fechaNacimiento,
      dni: prev.dni,
      lugarNacimiento: prev.lugarNacimiento,
      domicilio: prev.domicilio,
      estadoCivil: prev.estadoCivil,
      ocupacion: prev.ocupacion,
      profileImageUrl: prev.profileImageUrl,
      coverImageUrl: prev.coverImageUrl,
      iconImageUrl: prev.iconImageUrl,
      handle: prev.handle,
      displayName: prev.displayName,
      description: prev.description,
      countryCode: prev.countryCode,
      nationalNumber: prev.nationalNumber,
      country: prev.country,
      starCount: prev.starCount,
      hasRated: prev.hasRated,
      accountDeletionPending: user.accountDeletionPending,
      accountDeletionRequestedAtUtc: user.accountDeletionRequestedAtUtc,
      accountDeletionScheduledForUtc: user.accountDeletionScheduledForUtc,
      accountDeletionGracePeriodDays: user.accountDeletionGracePeriodDays,
      trialEndsAt: prev.trialEndsAt,
      isPro: prev.isPro,
    );
  }

  /// Llamado desde el interceptor de refresh y desde [_tryRefreshToken].
  void updateUserFromRefreshResponse(Map<String, dynamic>? data) {
    _applyUserFromRefreshData(data);
  }

  /// GET /account/deletion — actualiza [UserProfile] con el estado de borrado programado.
  Future<void> refreshAccountDeletionStatus() async {
    if (!state.isAuthenticated || state.isDemoMode || state.userProfile == null) {
      return;
    }
    try {
      final status = await ref.read(accountServiceProvider).getDeletionStatus();
      final prev = state.userProfile!;
      state = state.copyWith(
        userProfile: prev.applyAccountDeletionStatus(status),
      );
    } catch (_) {
      // Endpoint ausente o red: no bloquear la app
    }
  }

  /// POST /account/deletion/request (Barber o Employee; Admin recibe 400 en servidor).
  Future<String?> requestAccountDeletion() async {
    if (!state.isAuthenticated || state.isDemoMode) {
      return 'No disponible en modo demo';
    }
    try {
      await ref.read(accountServiceProvider).requestDeletion();
      await refreshAccountDeletionStatus();
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  /// POST /account/deletion/cancel
  Future<String?> cancelAccountDeletion() async {
    if (!state.isAuthenticated || state.isDemoMode) {
      return 'No disponible en modo demo';
    }
    try {
      await ref.read(accountServiceProvider).cancelDeletion();
      await refreshAccountDeletionStatus();
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Limpia el estado de autenticación
  Future<void> _clearAuthState() async {
    await _tokenStorage.clear();
    _dio.options.headers.remove('Authorization');
    state = state.copyWith(
      isAuthenticated: false,
      isDemoMode: false,
      userToken: null,
      clearProfile: true,
      clearSubscription: true,
      errorMessage: null,
    );
  }

  /// Aplica respuesta de login/register/google/apple al estado
  void _applyLoginResponse(LoginResponse loginResponse) {
    final user = loginResponse.user;
    final barber = user.barber;
    final profile = UserProfile(
      userId: user.id.toString(),
      userName: user.email,
      role: user.role,
      nombre: barber?.name ?? user.email,
      apellido: '',
      email: user.email,
      phone: barber?.phone,
      accountDeletionPending: user.accountDeletionPending,
      accountDeletionRequestedAtUtc: user.accountDeletionRequestedAtUtc,
      accountDeletionScheduledForUtc: user.accountDeletionScheduledForUtc,
      accountDeletionGracePeriodDays: user.accountDeletionGracePeriodDays,
      trialEndsAt: user.subscription?.trialEndsAt ?? barber?.trialEndsAt,
      isPro: barber?.isPro ?? user.subscription?.isProActive ?? false,
      profileImageUrl: barber?.profileImageUrl,
    );
    state = state.copyWith(
      userToken: loginResponse.token,
      isAuthenticated: true,
      isLoading: false,
      userProfile: profile,
      subscription: user.subscription,
    );
  }

  /// Ejecuta una acción de auth (login/register/google/apple) y aplica el resultado.
  Future<bool> _performAuth(Future<LoginResponse> Function() action) async {
    if (_authService == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final loginResponse = await action();
      if (loginResponse.token.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No se pudo completar la autenticación.',
        );
        return false;
      }
      _dio.options.headers['Authorization'] = 'Bearer ${loginResponse.token}';
      _applyLoginResponse(loginResponse);
      try {
        await initializeNotifications();
      } catch (_) {}
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Iniciar sesión (email/contraseña)
  Future<bool> login(String email, String password) async =>
      _performAuth(() => _authService!.login(email, password));

  /// Registro (email/contraseña) — 1 mes de prueba
  Future<bool> register(RegisterRequest request) async =>
      _performAuth(() => _authService!.register(request));

  /// Login con Google (Firebase ID token)
  Future<bool> loginWithGoogle({
    required String idToken,
    String? name,
    String? businessName,
    String? phone,
  }) async =>
      _performAuth(() => _authService!.loginWithGoogle(
            idToken: idToken,
            name: name,
            businessName: businessName,
            phone: phone,
          ));

  /// Login con Apple (Firebase ID token)
  Future<bool> loginWithApple({
    required String idToken,
    String? name,
    String? businessName,
    String? phone,
  }) async =>
      _performAuth(() => _authService!.loginWithApple(
            idToken: idToken,
            name: name,
            businessName: businessName,
            phone: phone,
          ));

  /// Activar modo demo
  Future<void> enableDemoMode() async {
    final demoProfile = UserProfile(
      userId: '999',
      userName: 'demo@barbenic.com',
      role: 'Barber',
      nombre: 'Usuario',
      apellido: 'de Prueba',
      email: 'demo@barbenic.com',
      phone: '8888-8888',
      isPro: true,
    );
    state = state.copyWith(
      isAuthenticated: true,
      isDemoMode: true,
      isLoading: false,
      userToken: 'demo_token',
      userProfile: demoProfile,
      subscription: SubscriptionDto(
        trialEndsAt: null,
        isProActive: true,
        proActivatedAt: null,
        status: 'Pro',
        hasAccess: true,
      ),
      errorMessage: null,
    );
  }

  /// Refrescar estado de suscripción (GET /api/barber/subscription)
  Future<void> refreshSubscription() async {
    if (!state.isAuthenticated || state.isDemoMode) return;
    try {
      final barberService = ref.read(barberServiceProvider);
      final subscription = await barberService.getSubscription();
      state = state.copyWith(subscription: subscription);
    } catch (_) {}
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      await _tokenStorage.clear();
    } catch (_) {
      // Ignorar errores
    }
    try {
      await TrialWelcomeStorage.clear();
    } catch (_) {}
    try {
      await BarberProfileCache.clear();
    } catch (_) {}
    try {
      ref.read(trialExpiredNotifierProvider.notifier).clear();
    } catch (_) {}
    try {
      await ref.read(socialAuthServiceProvider).signOutFromGoogleAndFirebase();
    } catch (_) {
      // Ignorar si no había sesión social
    }
    await _clearAuthState();
    state = AuthState.initial().copyWith(isInitialized: true);
  }

  /// Verificar si hay un token válido
  Future<bool> verifyToken() async {
    try {
      final access = await _tokenStorage.getAccessToken();
      if (access == null || access.isEmpty) return false;
      
      // Verificar si el token está expirado
      if (JwtDecoder.isTokenExpired(access)) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Cargar perfil del usuario
  Future<bool> loadUserProfile() async {
    if (!state.isAuthenticated || state.userToken == null) {
      return false;
    }

    // Primero verificar el rol desde el token
    final role = JwtDecoder.getUserRole(state.userToken!);
    
    // Si es Employee, no intentar cargar perfil del barbero
    if (role == 'Employee') {
      final fallback = _buildProfileFromToken(state.userToken!);
      if (fallback != null) {
        state = state.copyWith(userProfile: fallback);
        await refreshAccountDeletionStatus();
        return true;
      }
      return false;
    }

    try {
      final barberService = ref.read(barberServiceProvider);
      final barberProfile = await barberService.getProfile();
      final profile = UserProfile(
        userId: barberProfile.id.toString(),
        userName: barberProfile.email ?? '',
        role: 'Barber',
        nombre: barberProfile.name,
        apellido: '',
        email: barberProfile.email,
        phone: barberProfile.phone,
        profileImageUrl: barberProfile.profileImageUrl,
        trialEndsAt: barberProfile.trialEndsAt,
        isPro: barberProfile.isPro,
      );
      state = state.copyWith(userProfile: profile);
      // Actualizar suscripción (Trial/Pro/Expired)
      try {
        final subscription = await barberService.getSubscription();
        state = state.copyWith(subscription: subscription);
      } catch (_) {}
      await refreshAccountDeletionStatus();
      return true;
    } catch (e) {
      final message = e.toString();
      
      if (message.contains('401') || message.contains('Sesión expirada')) {
        await _clearAuthState();
        return false;
      }
      
      // Si no se puede cargar, usar datos del token
      if (state.userToken != null && state.userProfile == null) {
        final fallback = _buildProfileFromToken(state.userToken!);
        if (fallback != null) {
          state = state.copyWith(userProfile: fallback);
          await refreshAccountDeletionStatus();
          return true;
        }
      }
      
      return false;
    }
  }

  /// Construir un perfil básico desde el token JWT
  UserProfile? _buildProfileFromToken(String token) {
    final userId = JwtDecoder.getUserId(token);
    if (userId == null) return null;

    final userName = JwtDecoder.getUserName(token) ?? 'Usuario';
    final role = JwtDecoder.getUserRole(token) ?? 'Usuario';

    return UserProfile(
      userId: userId,
      userName: userName,
      role: role,
      nombre: userName,
      apellido: '',
      email: userName,
    );
  }
}

/// Provider de Riverpod para exponer el estado y la lógica de autenticación.
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

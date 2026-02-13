import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/auth.dart';
import '../../providers/providers.dart';
import '../../services/storage/token_storage.dart';

class AuthService {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthService(this._dio, this._tokenStorage);

  /// POST /api/auth/login
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      await _tokenStorage.saveTokens(loginResponse.token, loginResponse.refreshToken);
      return loginResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Credenciales inválidas');
      }
      throw Exception(e.response?.data['message'] ?? 'Error en el login');
    }
  }

  /// POST /api/auth/register — Crea barbero con 1 mes de prueba
  Future<LoginResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: request.toJson(),
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      await _tokenStorage.saveTokens(loginResponse.token, loginResponse.refreshToken);
      return loginResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final msg = e.response?.data['message'] as String?;
        throw Exception(msg ?? 'El email ya está registrado.');
      }
      throw Exception(e.response?.data['message'] ?? 'Error en el registro');
    }
  }

  /// POST /api/auth/google — Login con Firebase ID token (Google)
  Future<LoginResponse> loginWithGoogle({
    required String idToken,
    String? name,
    String? businessName,
    String? phone,
  }) =>
      _loginWithIdToken('/auth/google', idToken, name, businessName, phone);

  /// POST /api/auth/apple — Login con Firebase ID token (Apple)
  Future<LoginResponse> loginWithApple({
    required String idToken,
    String? name,
    String? businessName,
    String? phone,
  }) =>
      _loginWithIdToken('/auth/apple', idToken, name, businessName, phone);

  Future<LoginResponse> _loginWithIdToken(
    String path,
    String idToken,
    String? name,
    String? businessName,
    String? phone,
  ) async {
    try {
      final data = <String, dynamic>{'idToken': idToken};
      if (name != null && name.isNotEmpty) data['name'] = name;
      if (businessName != null && businessName.isNotEmpty) data['businessName'] = businessName;
      if (phone != null && phone.isNotEmpty) data['phone'] = phone;

      final response = await _dio.post(path, data: data);
      final loginResponse = LoginResponse.fromJson(response.data);
      await _tokenStorage.saveTokens(loginResponse.token, loginResponse.refreshToken);
      return loginResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Token inválido o expirado.');
      }
      throw Exception(
        e.response?.data['message'] as String? ?? 'Error al iniciar sesión.',
      );
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthService(dio, tokenStorage);
});


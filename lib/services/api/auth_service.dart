import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/auth.dart';
import '../../providers/providers.dart';
import '../../services/storage/token_storage.dart';

class AuthService {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthService(this._dio, this._tokenStorage);

  Future<LoginResponse> login(String email, String password) async {
    try {
      print('🔵 [AuthService] Iniciando login para: $email');
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      print('✅ [AuthService] Login response status: ${response.statusCode}');
      print('📦 [AuthService] Login response data type: ${response.data.runtimeType}');
      
      final loginResponse = LoginResponse.fromJson(response.data);
      
      print('🔑 [AuthService] Token recibido (primeros 30 chars): ${loginResponse.token.substring(0, loginResponse.token.length > 30 ? 30 : loginResponse.token.length)}...');
      
      // Guardar token
      await _tokenStorage.saveTokens(loginResponse.token, loginResponse.token);
      print('💾 [AuthService] Token guardado en storage');
      
      // Verificar que se guardó correctamente
      final savedToken = await _tokenStorage.getAccessToken();
      if (savedToken != null && savedToken == loginResponse.token) {
        print('✅ [AuthService] Token verificado en storage correctamente');
      } else {
        print('⚠️ [AuthService] Advertencia: El token guardado no coincide con el recibido');
      }
      
      return loginResponse;
    } on DioException catch (e) {
      print('❌ [AuthService] Error en login: ${e.response?.statusCode}');
      print('📋 [AuthService] Error data: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Credenciales inválidas');
      }
      throw Exception(e.response?.data['message'] ?? 'Error en el login');
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthService(dio, tokenStorage);
});


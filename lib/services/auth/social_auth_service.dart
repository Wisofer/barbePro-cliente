import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Obtiene el ID token de Firebase para enviar al backend (/api/auth/google y /api/auth/apple).
/// Requiere Firebase Auth y en iOS/Android la configuración de Google/Apple.
class SocialAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Inicia sesión con Google y devuelve el Firebase ID token.
  /// Lanza si el usuario cancela o hay error.
  Future<String> getGoogleIdToken() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Inicio de sesión con Google cancelado');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw Exception('No se pudo obtener el token de Google');
      }
      return idToken;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Error con Firebase Auth');
    } catch (e) {
      rethrow;
    }
  }

  /// Inicia sesión con Apple y devuelve el Firebase ID token.
  /// En iOS requiere "Sign in with Apple" capability.
  Future<String> getAppleIdToken() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      final idToken = await userCredential.user?.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw Exception('No se pudo obtener el token de Apple');
      }
      return idToken;
    } on SignInWithAppleAuthorizationException catch (e) {
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          throw Exception('Inicio de sesión con Apple cancelado');
        case AuthorizationErrorCode.notHandled:
          throw Exception('Apple no respondió');
        default:
          throw Exception(e.message);
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Error con Firebase Auth');
    } catch (e) {
      rethrow;
    }
  }

  /// Comprueba si Sign in with Apple está disponible (p. ej. iOS 13+).
  Future<bool> isAppleSignInAvailable() async {
    return await SignInWithApple.isAvailable();
  }
}

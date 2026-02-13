import 'package:shared_preferences/shared_preferences.dart';

/// Guarda si el usuario cerró la card de prueba gratuita para no mostrarla de nuevo.
class TrialCardStorage {
  static const _keyPrefix = 'trial_card_dismissed_';

  /// Indica si el usuario ya cerró la card de prueba (por userId).
  static Future<bool> isDismissed(String? userId) async {
    if (userId == null || userId.isEmpty) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('$_keyPrefix$userId') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Marca la card como cerrada para este usuario.
  static Future<void> setDismissed(String? userId) async {
    if (userId == null || userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_keyPrefix$userId', true);
    } catch (_) {}
  }
}

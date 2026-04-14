import 'package:shared_preferences/shared_preferences.dart';

const String _keyTrialWelcomeShown = 'trial_welcome_modal_shown_barbepro';

/// Persistencia del modal de bienvenida al trial (se borra al cerrar sesión).
class TrialWelcomeStorage {
  static Future<bool> getShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTrialWelcomeShown) ?? false;
  }

  static Future<void> setShown(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      await prefs.setBool(_keyTrialWelcomeShown, true);
    } else {
      await prefs.remove(_keyTrialWelcomeShown);
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTrialWelcomeShown);
  }
}

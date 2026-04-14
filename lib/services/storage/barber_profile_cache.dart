import 'package:shared_preferences/shared_preferences.dart';

const String _keyBarberProfileImageUrl = 'barber_profile_image_url';

/// Caché local de la URL de la foto de perfil del negocio (header instantáneo).
class BarberProfileCache {
  static Future<String?> getImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBarberProfileImageUrl);
  }

  static Future<void> saveImageUrl(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    if (url != null && url.isNotEmpty) {
      await prefs.setString(_keyBarberProfileImageUrl, url);
    } else {
      await prefs.remove(_keyBarberProfileImageUrl);
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBarberProfileImageUrl);
  }
}

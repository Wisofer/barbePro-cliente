import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/settings/settings_notifier.dart';
import '../../utils/audio_helper.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  NotificationSettings? _notificationSettings;
  bool _isCheckingPermissions = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermissions();
  }

  Future<void> _checkNotificationPermissions() async {
    setState(() {
      _isCheckingPermissions = true;
    });
    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      if (mounted) {
        setState(() {
          _notificationSettings = settings;
          _isCheckingPermissions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingPermissions = false;
        });
      }
    }
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      if (mounted) {
        setState(() {
          _notificationSettings = settings;
        });
        if (settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Permisos de notificaciones activados'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al solicitar permisos: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openAppSettings() async {
    try {
      await openAppSettings();
      // Refrescar permisos después de que el usuario regrese
      Future.delayed(const Duration(seconds: 1), () {
        _checkNotificationPermissions();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir la configuración: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getPermissionSubtitle() {
    if (_notificationSettings == null) {
      return 'Verificando estado...';
    }
    switch (_notificationSettings!.authorizationStatus) {
      case AuthorizationStatus.authorized:
        return 'Recibirás notificaciones de citas y actualizaciones';
      case AuthorizationStatus.denied:
        return 'Las notificaciones están desactivadas. Actívalas en configuración';
      case AuthorizationStatus.notDetermined:
        return 'Toca para activar las notificaciones';
      case AuthorizationStatus.provisional:
        return 'Notificaciones activadas de forma provisional';
    }
  }

  Widget? _getPermissionTrailing(Color mutedColor) {
    if (_isCheckingPermissions) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_notificationSettings == null) {
      return null;
    }

    switch (_notificationSettings!.authorizationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Activado',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF10B981),
            ),
          ),
        );
      case AuthorizationStatus.denied:
        return Icon(Iconsax.arrow_right_3, color: mutedColor.withAlpha(100), size: 18);
      case AuthorizationStatus.notDetermined:
        return Icon(Iconsax.arrow_right_3, color: mutedColor.withAlpha(100), size: 18);
    }
  }

  VoidCallback? _getPermissionOnTap() {
    if (_notificationSettings == null) {
      return null;
    }

    switch (_notificationSettings!.authorizationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return null; // Ya está activado, no hacer nada
      case AuthorizationStatus.denied:
        return _openAppSettings; // Abrir configuración del sistema
      case AuthorizationStatus.notDetermined:
        return _requestNotificationPermissions; // Solicitar permisos
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
    final cardColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
    const accentColor = Color(0xFF10B981);
    
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: isDark ? const Color(0xFF0A0A0B) : const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personaliza tu experiencia',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: mutedColor,
              ),
            ),
            const SizedBox(height: 24),

            // Apariencia
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apariencia',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SettingOption(
                    icon: Iconsax.moon,
                    title: 'Modo Oscuro',
                    subtitle: settings.themeMode == ThemeMode.dark 
                        ? 'Tema oscuro activado' 
                        : settings.themeMode == ThemeMode.light
                            ? 'Tema claro activado'
                            : 'Siguiendo configuración del sistema',
                    trailing: Switch(
                      value: settings.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        ref.read(settingsNotifierProvider.notifier).setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                      activeColor: accentColor,
                    ),
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Notificaciones
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notificaciones',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SettingOption(
                    icon: Iconsax.notification,
                    title: 'Notificaciones Push',
                    subtitle: _getPermissionSubtitle(),
                    trailing: _getPermissionTrailing(mutedColor),
                    onTap: _getPermissionOnTap(),
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                  const SizedBox(height: 12),
                  _SettingOption(
                    icon: Iconsax.sound,
                    title: 'Sonidos',
                    subtitle: settings.soundsEnabled ? 'Activados' : 'Desactivados',
                    trailing: Switch(
                      value: settings.soundsEnabled,
                      onChanged: (value) {
                        ref.read(settingsNotifierProvider.notifier).setSoundsEnabled(value);
                        // Actualizar AudioHelper inmediatamente
                        AudioHelper.setEnabled(value);
                      },
                      activeColor: accentColor,
                    ),
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Idioma
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Idioma',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SettingOption(
                    icon: Iconsax.global,
                    title: 'Idioma de la Aplicación',
                    subtitle: 'Español',
                    trailing: Icon(Iconsax.arrow_right_3, color: mutedColor.withAlpha(100), size: 18),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Esta funcionalidad estará disponible'),
                          backgroundColor: accentColor,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color textColor;
  final Color mutedColor;

  const _SettingOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    final widget = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF10B981), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );

    return widget;
  }
}


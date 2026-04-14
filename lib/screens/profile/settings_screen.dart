import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/settings/settings_notifier.dart';
import '../../utils/audio_helper.dart';
import 'widgets/ios_grouped_row.dart';
import 'widgets/profile_ios_section.dart';

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
            const SnackBar(
              content: Text('Permisos de notificaciones activados'),
              backgroundColor: Color(0xFF10B981),
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
        return 'Citas y actualizaciones';
      case AuthorizationStatus.denied:
        return 'Desactivadas · Configúralas en el sistema';
      case AuthorizationStatus.notDetermined:
        return 'Toca para permitir';
      case AuthorizationStatus.provisional:
        return 'Activadas de forma provisional';
    }
  }

  Widget? _buildPermissionTrailing(Color mutedColor) {
    if (_isCheckingPermissions) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_notificationSettings == null) {
      return null;
    }

    switch (_notificationSettings!.authorizationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return Text(
          'Activado',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF10B981),
          ),
        );
      case AuthorizationStatus.denied:
      case AuthorizationStatus.notDetermined:
        return Icon(Iconsax.arrow_right_3, color: mutedColor.withValues(alpha: 0.5), size: 16);
    }
  }

  VoidCallback? _getPermissionOnTap() {
    if (_notificationSettings == null) {
      return null;
    }

    switch (_notificationSettings!.authorizationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return null;
      case AuthorizationStatus.denied:
        return _openAppSettings;
      case AuthorizationStatus.notDetermined:
        return _requestNotificationPermissions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8);
    final groupedBg = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final sectionHeaderColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D72);
    const accentColor = Color(0xFF10B981);

    final settings = ref.watch(settingsNotifierProvider);

    Widget switchAccent(bool value, ValueChanged<bool> onChanged) {
      return Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: accentColor,
        activeTrackColor: accentColor.withValues(alpha: 0.45),
      );
    }

    return Scaffold(
      backgroundColor: groupedBg,
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        backgroundColor: groupedBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileIosSection(
              isFirst: true,
              title: 'Apariencia',
              headerColor: sectionHeaderColor,
              cardColor: cardColor,
              borderColor: borderColor,
              tiles: [
                IosGroupedRow(
                  icon: Iconsax.moon,
                  title: 'Modo oscuro',
                  subtitle: settings.themeMode == ThemeMode.dark
                      ? 'Activado'
                      : 'Desactivado',
                  trailing: switchAccent(
                    settings.themeMode == ThemeMode.dark,
                    (value) {
                      ref.read(settingsNotifierProvider.notifier).setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                    },
                  ),
                  accentColor: accentColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
              ],
            ),
            ProfileIosSection(
              title: 'Notificaciones',
              headerColor: sectionHeaderColor,
              cardColor: cardColor,
              borderColor: borderColor,
              tiles: [
                IosGroupedRow(
                  icon: Iconsax.notification,
                  title: 'Notificaciones push',
                  subtitle: _getPermissionSubtitle(),
                  trailing: _buildPermissionTrailing(mutedColor),
                  onTap: _getPermissionOnTap(),
                  accentColor: accentColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
                IosGroupedRow(
                  icon: Iconsax.sound,
                  title: 'Sonidos',
                  subtitle: settings.soundsEnabled ? 'Activados en la app' : 'Desactivados',
                  trailing: switchAccent(
                    settings.soundsEnabled,
                    (value) {
                      ref.read(settingsNotifierProvider.notifier).setSoundsEnabled(value);
                      AudioHelper.setEnabled(value);
                    },
                  ),
                  accentColor: accentColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
              ],
            ),
            ProfileIosSection(
              title: 'Idioma',
              headerColor: sectionHeaderColor,
              cardColor: cardColor,
              borderColor: borderColor,
              tiles: [
                IosGroupedRow(
                  icon: Iconsax.global,
                  title: 'Idioma de la app',
                  subtitle: 'Español',
                  trailing: Icon(
                    Iconsax.arrow_right_3,
                    color: mutedColor.withValues(alpha: 0.5),
                    size: 16,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Disponible próximamente'),
                        backgroundColor: accentColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  accentColor: accentColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/settings/settings_notifier.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
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
                    subtitle: 'Activar tema oscuro',
                    trailing: Switch(
                      value: settings.isDarkMode,
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
                    subtitle: 'Recibir notificaciones de nuevas citas',
                    trailing: Switch(
                      value: true, // TODO: Conectar con configuración real
                      onChanged: (value) {
                        // TODO: Implementar
                      },
                      activeColor: accentColor,
                    ),
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                  const SizedBox(height: 12),
                  _SettingOption(
                    icon: Iconsax.sound,
                    title: 'Sonidos',
                    subtitle: 'Reproducir sonidos en notificaciones',
                    trailing: Switch(
                      value: true, // TODO: Conectar con configuración real
                      onChanged: (value) {
                        // TODO: Implementar
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
                    trailing: Icon(Iconsax.arrow_right_3, color: mutedColor, size: 18),
                    onTap: () {
                      // TODO: Mostrar selector de idioma
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


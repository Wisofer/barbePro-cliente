import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'widgets/profile_option.dart';

/// Colores del perfil según tema (alineado con [ProfileScreen]).
class ProfilePalette {
  const ProfilePalette({
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accent,
  });

  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accent;

  static const Color destructive = Color(0xFFEF4444);
  static const Color demoAccent = Color(0xFFFFB84D);
  static const Color mutedButton = Color(0xFF6B7280);
  static const Color success = Color(0xFF10B981);
  /// Marca BarbeNic (snackbars, acentos fuera de [ProfilePalette.of]).
  static const Color accentBrand = Color(0xFF10B981);

  factory ProfilePalette.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ProfilePalette(
      textColor: isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937),
      mutedColor: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
      cardColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      borderColor: isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8),
      accent: const Color(0xFF10B981),
    );
  }

  static const Widget rowGap = SizedBox(height: 10);
}

extension ProfilePaletteMenu on ProfilePalette {
  Widget deleteAccountOption({
    required bool pending,
    DateTime? scheduledFor,
    required String Function(DateTime utc) formatDate,
    required VoidCallback onTap,
  }) {
    return ProfileOption(
      icon: Iconsax.trash,
      title: 'Eliminar cuenta',
      subtitle: pending && scheduledFor != null
          ? 'Programada para el ${formatDate(scheduledFor)} · Toca para cancelar'
          : 'Elimina permanentemente tu cuenta y datos',
      onTap: onTap,
      textColor: ProfilePalette.destructive,
      mutedColor: ProfilePalette.destructive.withValues(alpha: 0.85),
      cardColor: cardColor,
      borderColor: borderColor,
      accentColor: ProfilePalette.destructive,
      isDestructive: true,
      style: ProfileOptionStyle.grouped,
    );
  }
}

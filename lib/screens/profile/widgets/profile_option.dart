import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

enum ProfileOptionStyle {
  /// Tarjeta independiente con borde (diseño anterior).
  card,
  /// Fila dentro de un grupo tipo iOS (sin borde propio; el grupo aporta el fondo).
  grouped,
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;
  final bool isDestructive;
  final ProfileOptionStyle style;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
    this.isDestructive = false,
    this.style = ProfileOptionStyle.card,
  });

  @override
  Widget build(BuildContext context) {
    final iconBg = isDestructive
        ? const Color(0xFFEF4444).withValues(alpha: 0.12)
        : accentColor.withValues(alpha: 0.12);
    final iconFg = isDestructive ? const Color(0xFFEF4444) : accentColor;

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: style == ProfileOptionStyle.grouped ? 30 : 40,
          height: style == ProfileOptionStyle.grouped ? 30 : 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(style == ProfileOptionStyle.grouped ? 8 : 10),
          ),
          child: Icon(
            icon,
            color: iconFg,
            size: style == ProfileOptionStyle.grouped ? 18 : 20,
          ),
        ),
        SizedBox(width: style == ProfileOptionStyle.grouped ? 12 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: style == ProfileOptionStyle.grouped ? 16 : 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  height: 1.2,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: style == ProfileOptionStyle.grouped ? 12 : 12,
                    color: mutedColor,
                    height: 1.25,
                  ),
                  maxLines: style == ProfileOptionStyle.grouped ? 2 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          Iconsax.arrow_right_3,
          color: mutedColor.withValues(alpha: 0.65),
          size: style == ProfileOptionStyle.grouped ? 16 : 18,
        ),
      ],
    );

    if (style == ProfileOptionStyle.grouped) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: row,
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != Colors.transparent ? Border.all(color: borderColor) : null,
        ),
        child: row,
      ),
    );
  }
}


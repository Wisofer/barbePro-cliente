import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main_theme.dart';
import 'profile_menu.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFD1D5DB);
    final cardColor = isDark ? const Color(0xFF18181B) : Colors.white;
    const accentColor = Color(0xFF10B981); // Verde suave

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemMovilTheme.getStatusBarStyle(isDark),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        ),
        child: SafeArea(
          bottom: false,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
        children: [
                // Logo con fondo verde suave
          Container(
                  width: 44,
                  height: 44,
            decoration: BoxDecoration(
                    color: accentColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo3.png',
                      width: 44,
                      height: 44,
                fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Iconsax.scissor,
                          color: accentColor,
                          size: 24,
                        );
                      },
              ),
            ),
          ),
                const SizedBox(width: 12),
          
                // Título
          Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'BarberPro',
              style: GoogleFonts.inter(
                          fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Sistema de Gestión',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: mutedColor,
                          fontWeight: FontWeight.w500,
              ),
                      ),
                    ],
            ),
          ),
          
                // Botón de perfil
          GestureDetector(
            onTap: () => ProfileMenu.show(context, ref),
            child: Container(
                    width: 44,
                    height: 44,
              decoration: BoxDecoration(
                color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
                    child: Icon(
                      Iconsax.profile_circle,
                      color: accentColor,
                      size: 22,
                    ),
            ),
          ),
        ],
            ),
          ),
        ),
      ),
    );
  }
}

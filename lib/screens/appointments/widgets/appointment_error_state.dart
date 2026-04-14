import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class AppointmentListErrorState extends StatelessWidget {
  const AppointmentListErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
    this.isSmallScreen = false,
  });

  final String errorMessage;
  final VoidCallback onRetry;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = isSmallScreen ? 24 : 40;
    final double verticalPadding = isSmallScreen ? 40 : 60;
    final double iconSize = isSmallScreen ? 48 : 56;
    final double titleFontSize = isSmallScreen ? 16 : 18;
    final double subtitleFontSize = isSmallScreen ? 12 : 13;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.warning_2,
                      color: const Color(0xFFEF4444),
                      size: iconSize,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    Text(
                      'Error al cargar',
                      style: GoogleFonts.inter(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 4 : 6),
                    Text(
                      errorMessage,
                      style: GoogleFonts.inter(
                        fontSize: subtitleFontSize,
                        color: mutedColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: Icon(Iconsax.refresh, size: isSmallScreen ? 16 : 18),
                      label: Text(
                        'Reintentar',
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 14 : 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16 : 20,
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

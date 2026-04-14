import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bloque redondeado sin título (texto largo, formularios, FAQs).
class IosGroupedCard extends StatelessWidget {
  const IosGroupedCard({
    super.key,
    required this.child,
    required this.cardColor,
  });

  final Widget child;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }
}

/// Encabezado + bloque redondeado estilo lista agrupada de iOS.
class ProfileIosSection extends StatelessWidget {
  const ProfileIosSection({
    super.key,
    required this.title,
    required this.tiles,
    required this.cardColor,
    required this.borderColor,
    required this.headerColor,
    this.isFirst = false,
  });

  final String title;
  final List<Widget> tiles;
  final Color cardColor;
  final Color borderColor;
  final Color headerColor;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 16,
            bottom: 6,
            top: isFirst ? 8 : 22,
          ),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: headerColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  for (int i = 0; i < tiles.length; i++) ...[
                    tiles[i],
                    if (i < tiles.length - 1)
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 56,
                        color: borderColor.withValues(alpha: 0.75),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

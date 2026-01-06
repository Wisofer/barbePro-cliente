import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Acerca de',
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
          children: [
            // Logo COWIB
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: accentColor.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.code,
                      color: accentColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'COWIB',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Desarrolladores de Software',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: mutedColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Información de la aplicación
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
                    'BarberPro',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sistema de gestión profesional para barberías. Gestiona citas, servicios, finanzas y clientes de manera eficiente.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: mutedColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Iconsax.code, size: 16, color: mutedColor),
                      const SizedBox(width: 8),
                      Text(
                        'Versión 1.0.0',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Información de contacto
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
                    'Contacto',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ContactItem(
                    icon: Iconsax.global,
                    label: 'Sitio Web',
                    value: 'www.cowib.com',
                    onTap: () => _launchUrl('https://www.cowib.com'),
                    textColor: textColor,
                    mutedColor: mutedColor,
                    accentColor: accentColor,
                  ),
                  const SizedBox(height: 12),
                  _ContactItem(
                    icon: Iconsax.sms,
                    label: 'Email',
                    value: 'contacto@cowib.com',
                    onTap: () => _launchUrl('mailto:contacto@cowib.com'),
                    textColor: textColor,
                    mutedColor: mutedColor,
                    accentColor: accentColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Derechos de autor
            Text(
              '© 2024 COWIB. Todos los derechos reservados.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: mutedColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(Iconsax.arrow_right_3, color: mutedColor, size: 16),
        ],
      ),
    );
  }
}


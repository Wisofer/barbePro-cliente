import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/ios_grouped_row.dart';
import 'widgets/profile_ios_section.dart';

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
    final mutedColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8);
    final groupedBg = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final sectionHeaderColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D72);
    const accentColor = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: groupedBg,
      appBar: AppBar(
        title: Text(
          'Acerca de',
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
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileIosSection(
              isFirst: true,
              title: 'App',
              headerColor: sectionHeaderColor,
              cardColor: cardColor,
              borderColor: borderColor,
              tiles: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Iconsax.scissor, color: accentColor, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BarbeNic',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                Text(
                                  'Gestión profesional',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: mutedColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(height: 1, color: borderColor.withValues(alpha: 0.6)),
                      const SizedBox(height: 14),
                      Text(
                        'Sistema de gestión para barberías: citas, servicios, finanzas y clientes.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: mutedColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ProfileIosSection(
              title: 'COWIB',
              headerColor: sectionHeaderColor,
              cardColor: cardColor,
              borderColor: borderColor,
              tiles: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Iconsax.code, color: accentColor, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'COWIB',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  'Desarrollo de software',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: mutedColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(height: 1, color: borderColor.withValues(alpha: 0.6)),
                      const SizedBox(height: 14),
                      Text(
                        'Software a medida y soluciones personalizadas para tu negocio.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: mutedColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ServiceItem(
                        icon: Iconsax.box,
                        text: 'Sistemas de inventario personalizados',
                        textColor: textColor,
                        accentColor: accentColor,
                      ),
                      const SizedBox(height: 8),
                      _ServiceItem(
                        icon: Iconsax.setting_2,
                        text: 'Soluciones tecnológicas a medida',
                        textColor: textColor,
                        accentColor: accentColor,
                      ),
                      const SizedBox(height: 8),
                      _ServiceItem(
                        icon: Iconsax.lamp,
                        text: 'Soporte tecnológico',
                        textColor: textColor,
                        accentColor: accentColor,
                      ),
                      const SizedBox(height: 8),
                      _ServiceItem(
                        icon: Iconsax.star,
                        text: 'Productos pensados para crecer contigo',
                        textColor: textColor,
                        accentColor: accentColor,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
            ProfileIosSection(
              title: 'Contacto',
              headerColor: sectionHeaderColor,
              cardColor: cardColor,
              borderColor: borderColor,
              tiles: [
                IosGroupedRow(
                  icon: Iconsax.global,
                  title: 'Sitio web',
                  subtitle: 'www.cowib.es',
                  trailing: Icon(
                    Iconsax.arrow_right_3,
                    color: mutedColor.withValues(alpha: 0.5),
                    size: 16,
                  ),
                  onTap: () => _launchUrl('https://www.cowib.es'),
                  accentColor: accentColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
                IosGroupedRow(
                  icon: Iconsax.sms,
                  title: 'Email',
                  subtitle: 'info@cowib.es',
                  trailing: Icon(
                    Iconsax.arrow_right_3,
                    color: mutedColor.withValues(alpha: 0.5),
                    size: 16,
                  ),
                  onTap: () => _launchUrl('mailto:info@cowib.es'),
                  accentColor: accentColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '© 2026 COWIB. Todos los derechos reservados.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: mutedColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color textColor;
  final Color accentColor;

  const _ServiceItem({
    required this.icon,
    required this.text,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: accentColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textColor,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

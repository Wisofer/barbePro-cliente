import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

/// Información de privacidad y seguridad (requisitos App Store / transparencia).
class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  static const String routeName = '/privacy-security';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
    final cardColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
    const accentColor = Color(0xFF10B981);
    final bg = isDark ? const Color(0xFF0A0A0B) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          'Privacidad y seguridad',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mq = MediaQuery.of(context);
            final w = constraints.maxWidth;
            final padH = w < 360 ? 16.0 : (w > 600 ? 32.0 : 20.0);
            final maxContent = math.min(560.0, w - 2 * padH);
            final bottomPad = mq.padding.bottom + 28;
            final introTitleSize = w < 360 ? 14.0 : 15.0;
            final introBodySize = w < 360 ? 12.5 : 13.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padH, 8, padH, bottomPad),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContent > 0 ? maxContent : w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            Text(
              'Transparencia sobre tus datos',
              style: GoogleFonts.inter(
                fontSize: introTitleSize,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: w < 360 ? 6 : 8),
            Text(
              'Última actualización: información general para usuarios de BarbePro. '
              'Si necesitas el texto legal completo, tu equipo puede enlazar aquí la política publicada en la web.',
              style: GoogleFonts.inter(
                fontSize: introBodySize,
                color: mutedColor,
                height: 1.5,
              ),
            ),
            SizedBox(height: w < 360 ? 16 : 20),
            _SectionCard(
              cardColor: cardColor,
              borderColor: borderColor,
              accentColor: accentColor,
              textColor: textColor,
              mutedColor: mutedColor,
              icon: Iconsax.shield_tick,
              title: 'Compromiso con la privacidad',
              body:
                  'BarbePro está diseñada para gestionar tu negocio de forma profesional. '
                  'Tratamos los datos personales y de tu barbería con fines legítimos: '
                  'prestar el servicio, autenticación, soporte y mejoras de la aplicación, '
                  'siempre respetando la normativa aplicable.',
            ),
            const SizedBox(height: 14),
            _SectionCard(
              cardColor: cardColor,
              borderColor: borderColor,
              accentColor: accentColor,
              textColor: textColor,
              mutedColor: mutedColor,
              icon: Iconsax.document_text,
              title: 'Datos que pueden tratarse',
              body:
                  'Entre otros: identificadores de cuenta (correo, nombre), datos del '
                  'negocio, información de citas y clientes que introduzcas en la '
                  'app, datos técnicos necesarios para el funcionamiento (tokens de sesión, '
                  'notificaciones push si las activas) y, si usas inicio con Google o Apple, '
                  'datos que esos proveedores compartan según su configuración.',
            ),
            const SizedBox(height: 14),
            _SectionCard(
              cardColor: cardColor,
              borderColor: borderColor,
              accentColor: accentColor,
              textColor: textColor,
              mutedColor: mutedColor,
              icon: Iconsax.lock,
              title: 'Seguridad',
              body:
                  'Utilizamos comunicación cifrada (HTTPS) con el servidor cuando la '
                  'infraestructura lo permite. Las contraseñas no deben compartirse. '
                  'Cierra sesión en dispositivos que no sean tuyos. Mantén tu sistema '
                  'operativo y la app actualizados.',
            ),
            const SizedBox(height: 14),
            _SectionCard(
              cardColor: cardColor,
              borderColor: borderColor,
              accentColor: accentColor,
              textColor: textColor,
              mutedColor: mutedColor,
              icon: Iconsax.user_minus,
              title: 'Tu cuenta y eliminación',
              body:
                  'Puedes solicitar la eliminación de tu cuenta desde la app (perfil), '
                  'sujeto al periodo de gracia configurado en el servidor. '
                  'También puedes contactar con soporte para dudas sobre tus datos.',
            ),
            const SizedBox(height: 14),
            _SectionCard(
              cardColor: cardColor,
              borderColor: borderColor,
              accentColor: accentColor,
              textColor: textColor,
              mutedColor: mutedColor,
              icon: Iconsax.message_question,
              title: 'Contacto',
              body:
                  'Para ejercer derechos de privacidad o preguntas sobre protección de datos, '
                  'contacta al responsable del tratamiento indicado en tu contrato o web oficial '
                  'de BarbePro, o a soporte a través de los canales de ayuda de la aplicación.',
            ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
    required this.icon,
    required this.title,
    required this.body,
  });

  final Color cardColor;
  final Color borderColor;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 360;
    final titleSize = compact ? 14.0 : 15.0;
    final bodySize = compact ? 12.5 : 13.0;
    final iconBox = compact ? 7.0 : 8.0;
    final iconSize = compact ? 18.0 : 20.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(iconBox),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: iconSize),
              ),
              SizedBox(width: compact ? 10 : 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 12),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: bodySize,
              color: mutedColor,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

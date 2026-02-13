import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../models/auth.dart';

/// Modal de bienvenida para periodo de prueba: entrada dinámica (scale + fade + blur).
class TrialWelcomeModal extends StatefulWidget {
  final SubscriptionDto subscription;
  final VoidCallback onDismiss;

  const TrialWelcomeModal({
    super.key,
    required this.subscription,
    required this.onDismiss,
  });

  @override
  State<TrialWelcomeModal> createState() => _TrialWelcomeModalState();
}

class _TrialWelcomeModalState extends State<TrialWelcomeModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _backdropOpacity;
  late Animation<double> _scale;
  late Animation<double> _contentOpacity;
  late Animation<double> _slideY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _backdropOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );
    _scale = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _contentOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );
    _slideY = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const accent = Color(0xFF10B981);
    const accentLight = Color(0xFF34D399);
    final cardBg = isDark ? const Color(0xFF18181B) : Colors.white;
    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final muted = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);

    final trialEndsAt = widget.subscription.trialEndsAt;
    String dateStr = '';
    if (trialEndsAt != null) {
      dateStr =
          '${trialEndsAt.day}/${trialEndsAt.month.toString().padLeft(2, '0')}/${trialEndsAt.year}';
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
            children: [
              // Backdrop con blur
              GestureDetector(
                onTap: widget.onDismiss,
                behavior: HitTestBehavior.opaque,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 8 * _backdropOpacity.value,
                    sigmaY: 8 * _backdropOpacity.value,
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.4 * _backdropOpacity.value),
                  ),
                ),
              ),
              // Card centrada con animación
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Transform.translate(
                    offset: Offset(0, _slideY.value),
                    child: Transform.scale(
                      scale: _scale.value,
                      child: Opacity(
                        opacity: _contentOpacity.value,
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 340),
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF27272A)
                                  : Colors.white,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.15),
                                blurRadius: 32,
                                spreadRadius: -4,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Franja superior con gradiente
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        accent.withOpacity(0.12),
                                        accentLight.withOpacity(0.08),
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: accent.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: accent.withOpacity(0.35),
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              Iconsax.gift,
                                              color: accent,
                                              size: 32,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '¡Bienvenido a BarbeNic!',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                    color: textColor,
                                                    letterSpacing: -0.3,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  dateStr.isEmpty
                                                      ? 'Tienes 1 mes gratis'
                                                      : 'Todo desbloqueado hasta el $dateStr',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: accent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                ),
                                // Cuerpo
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Ya puedes usar todas las funciones: citas, servicios, finanzas y más. Cuando termine tu mes, te ayudamos a seguir con BarbeNic sin complicaciones.',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          height: 1.45,
                                          color: muted,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: FilledButton(
                                          onPressed: widget.onDismiss,
                                          style: FilledButton.styleFrom(
                                            backgroundColor: accent,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                          ),
                                          child: Text(
                                            'Empezar',
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
      },
    );
  }
}

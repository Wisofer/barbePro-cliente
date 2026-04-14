import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../main_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trial_expired_provider.dart';

/// Pantalla cuando el período de prueba terminó (403 TRIAL_EXPIRED o suscripción expirada).
class TrialExpiredScreen extends ConsumerWidget {
  static const String routeName = '/trial-expired';

  const TrialExpiredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const accentColor = Color(0xFF10B981);
    const bgColor = Colors.white;
    const textColor = Color(0xFF1F2937);
    const mutedColor = Color(0xFF6B7280);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemMovilTheme.getStatusBarStyle(false),
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withAlpha(40),
                        const Color(0xFF059669).withAlpha(25),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Iconsax.timer_1,
                    size: 72,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Tu periodo de prueba terminó',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tu prueba gratuita ha finalizado. Activa BarbeNic Pro para seguir usando todas las funciones, '
                  'o si ya pagaste, el equipo activará tu cuenta pronto.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: mutedColor,
                    height: 1.45,
                  ),
                ),
                const Spacer(flex: 2),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: () async {
                      final authNotifier = ref.read(authNotifierProvider.notifier);
                      ref.read(trialExpiredNotifierProvider.notifier).clear();
                      await authNotifier.logout();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Cerrar sesión',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

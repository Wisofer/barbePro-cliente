import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/auth_provider.dart';

/// Card que muestra "Tienes 1 mes de prueba hasta [fecha]". Solo visible cuando status == Trial.
class SubscriptionTrialCard extends ConsumerWidget {
  const SubscriptionTrialCard({super.key});

  static String _formatTrialEnd(DateTime? trialEndsAt) {
    if (trialEndsAt == null) return '';
    final d = trialEndsAt.day;
    final m = trialEndsAt.month;
    final y = trialEndsAt.year;
    return '$d/${m.toString().padLeft(2, '0')}/$y';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final subscription = authState.subscription;

    if (subscription == null || !subscription.isTrial) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = Color(0xFF10B981);
    final cardColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
    final dateStr = _formatTrialEnd(subscription.trialEndsAt);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Iconsax.calendar_1, color: accentColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prueba gratuita',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr.isEmpty
                      ? 'Tienes 1 mes de prueba. Después puedes activar Pro con el administrador.'
                      : 'Tienes prueba hasta el $dateStr. Después puedes activar Pro con el administrador.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: mutedColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../main_theme.dart';
import 'snackbar_helper.dart';

/// SnackBars modernos: tarjeta oscura con acento lateral y cierre manual.
class ModernSnackBar {
  static void showCustom(
    BuildContext context, {
    required String title,
    required String message,
    required Color accentColor,
    required IconData icon,
  }) {
    ScaffoldMessengerState? messenger;
    try {
      if (context.mounted) {
        messenger = ScaffoldMessenger.of(context);
      }
    } catch (_) {
      messenger = SnackbarHelper.scaffoldMessengerKey.currentState;
    }

    messenger ??= SnackbarHelper.scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          duration: const Duration(seconds: 4),
          content: Container(
            padding: const EdgeInsets.fromLTRB(0, 12, 8, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 56,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: accentColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SystemMovilTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: SystemMovilTextStyles.bodyMedium.copyWith(
                          color: const Color(0xFFD1D5DB),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () {
                    final m =
                        SnackbarHelper.scaffoldMessengerKey.currentState ??
                        messenger;
                    m?.hideCurrentSnackBar();
                  },
                  icon: const Icon(Icons.close_rounded),
                  color: const Color(0xFFE5E7EB),
                  iconSize: 18,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
        ),
      );
  }

  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showCustom(
      context,
      title: title,
      message: message,
      accentColor: const Color(0xFF10B981),
      icon: Iconsax.tick_circle,
    );
  }

  static void showError(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showCustom(
      context,
      title: title,
      message: message,
      accentColor: const Color(0xFFEF4444),
      icon: Iconsax.close_circle,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showCustom(
      context,
      title: title,
      message: message,
      accentColor: const Color(0xFFF59E0B),
      icon: Iconsax.warning_2,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showCustom(
      context,
      title: title,
      message: message,
      accentColor: const Color(0xFF3B82F6),
      icon: Iconsax.info_circle,
    );
  }

  static void showHelp(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showCustom(
      context,
      title: title,
      message: message,
      accentColor: SystemMovilColors.primary,
      icon: Iconsax.message_question,
    );
  }
}

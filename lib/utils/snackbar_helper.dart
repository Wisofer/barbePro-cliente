import 'package:flutter/material.dart';
import 'modern_snackbar.dart';

class SnackbarHelper {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess({
    BuildContext? context,
    required String title,
    required String message,
  }) {
    _showSnackbar(
      context: context,
      title: title,
      message: message,
      type: SnackbarType.success,
    );
  }

  static void showError({
    BuildContext? context,
    required String title,
    required String message,
  }) {
    _showSnackbar(
      context: context,
      title: title,
      message: message,
      type: SnackbarType.error,
    );
  }

  static void showWarning({
    BuildContext? context,
    required String title,
    required String message,
  }) {
    _showSnackbar(
      context: context,
      title: title,
      message: message,
      type: SnackbarType.warning,
    );
  }

  static void showInfo({
    BuildContext? context,
    required String title,
    required String message,
  }) {
    _showSnackbar(
      context: context,
      title: title,
      message: message,
      type: SnackbarType.info,
    );
  }

  static void _showSnackbar({
    BuildContext? context,
    required String title,
    required String message,
    required SnackbarType type,
  }) {
    if (context != null && context.mounted) {
      try {
        switch (type) {
          case SnackbarType.success:
            ModernSnackBar.showSuccess(context, title: title, message: message);
            break;
          case SnackbarType.error:
            ModernSnackBar.showError(context, title: title, message: message);
            break;
          case SnackbarType.warning:
            ModernSnackBar.showWarning(context, title: title, message: message);
            break;
          case SnackbarType.info:
            ModernSnackBar.showInfo(context, title: title, message: message);
            break;
        }
        return;
      } catch (_) {}
    }

    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(_buildFallbackSnackBar(title, message, type));
    }
  }

  static SnackBar _buildFallbackSnackBar(
    String title,
    String message,
    SnackbarType type,
  ) {
    Color accentColor;
    IconData icon;
    switch (type) {
      case SnackbarType.success:
        accentColor = const Color(0xFF10B981);
        icon = Icons.check_circle_outline_rounded;
        break;
      case SnackbarType.error:
        accentColor = const Color(0xFFEF4444);
        icon = Icons.error_outline_rounded;
        break;
      case SnackbarType.warning:
        accentColor = const Color(0xFFF59E0B);
        icon = Icons.warning_amber_rounded;
        break;
      case SnackbarType.info:
        accentColor = const Color(0xFF3B82F6);
        icon = Icons.info_outline_rounded;
        break;
    }

    return SnackBar(
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
            Icon(icon, color: accentColor, size: 18),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFFD1D5DB)),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Cerrar',
              onPressed: () => scaffoldMessengerKey.currentState?.hideCurrentSnackBar(),
              icon: const Icon(Icons.close_rounded),
              color: const Color(0xFFE5E7EB),
              iconSize: 18,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }
}

enum SnackbarType { success, error, warning, info }

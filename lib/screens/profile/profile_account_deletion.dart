import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'profile_palette.dart';

/// Fecha corta dd/MM/yyyy (local).
String formatProfileAccountDeletionDate(DateTime utc) {
  final local = utc.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/'
      '${local.year}';
}

Future<bool?> showAccountDeletionPendingDialog(
  BuildContext context, {
  DateTime? scheduledFor,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Eliminación programada',
        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
      ),
      content: Text(
        scheduledFor != null
            ? 'Tu cuenta está programada para eliminarse el '
                '${formatProfileAccountDeletionDate(scheduledFor)}. '
                'Puedes cancelar la solicitud antes de esa fecha.'
            : 'Tu cuenta tiene una eliminación pendiente. Puedes cancelar la solicitud.',
        style: GoogleFonts.inter(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            'Cerrar',
            style: GoogleFonts.inter(color: ProfilePalette.mutedButton),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            'Cancelar eliminación',
            style: GoogleFonts.inter(
              color: ProfilePalette.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

Future<bool?> showAccountDeletionRequestDialog(
  BuildContext context, {
  int? gracePeriodDays,
}) {
  final days = gracePeriodDays ?? 30;
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        '¿Eliminar tu cuenta?',
        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
      ),
      content: SingleChildScrollView(
        child: Text(
          'Gracias por usar BarbePro.\n\n'
          'Tu cuenta no desaparece al instante: tienes un periodo de gracia de '
          '$days días antes del borrado definitivo.\n\n'
          'Al pulsar «Programar eliminación», quedará programada la solicitud y '
          'cerraremos tu sesión (como cerrar sesión).\n\n'
          'Si vuelves a entrar durante ese tiempo y cambias de opinión, puedes '
          'cancelar el proceso desde Perfil → Eliminar cuenta.\n\n'
          '¿Quieres continuar?',
          style: GoogleFonts.inter(height: 1.45, fontSize: 14),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            'Ahora no',
            style: GoogleFonts.inter(color: ProfilePalette.mutedButton),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            'Programar eliminación',
            style: GoogleFonts.inter(
              color: ProfilePalette.destructive,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

void showAccountDeletionSnackBar(
  BuildContext context, {
  required String? errorMessage,
  required bool isCancellation,
}) {
  final success = errorMessage == null;
  final text = errorMessage ??
      (isCancellation
          ? 'La eliminación programada fue cancelada.'
          : 'El borrado quedó programado según el periodo de gracia.');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor: success
          ? (isCancellation ? ProfilePalette.success : ProfilePalette.accentBrand)
          : ProfilePalette.destructive,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

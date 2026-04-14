import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/appointment.dart';
import '../../../utils/responsive_breakpoints.dart';

class DashboardQuickStatCard extends StatelessWidget {
  const DashboardQuickStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final w = context.screenWidth;
    final isSmallScreen = w < AppBreakpoints.compactWidth;
    final isMediumScreen = context.isComfortableWidth;

    final iconSize = isSmallScreen ? 32.0 : (isMediumScreen ? 36.0 : 40.0);
    final iconInnerSize = isSmallScreen ? 18.0 : 20.0;
    final padding = isSmallScreen ? 10.0 : (isMediumScreen ? 12.0 : 14.0);
    final fontSize = isSmallScreen ? 16.0 : (isMediumScreen ? 17.0 : 18.0);
    final labelFontSize = isSmallScreen ? 10.0 : 11.0;
    final spacing = isSmallScreen ? 8.0 : 12.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: iconInnerSize),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: labelFontSize,
                    color: mutedColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardStatItem extends StatelessWidget {
  const DashboardStatItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
    required this.mutedColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: mutedColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardAppointmentMiniCard extends StatelessWidget {
  const DashboardAppointmentMiniCard({
    super.key,
    required this.appointment,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
  });

  final AppointmentDto appointment;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFF10B981);
      case 'Pending':
        return const Color(0xFFF59E0B);
      default:
        return mutedColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _statusColor(appointment.status),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.clientName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Iconsax.clock, size: 11, color: mutedColor),
                    const SizedBox(width: 4),
                    Text(
                      appointment.time,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: mutedColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (appointment.services.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withAlpha(15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${appointment.services.length} servicio${appointment.services.length > 1 ? 's' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _statusColor(appointment.status),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardDismissibleAppointmentCard extends StatelessWidget {
  const DashboardDismissibleAppointmentCard({
    super.key,
    required this.appointment,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
    required this.onDismissed,
  });

  final AppointmentDto appointment;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('appointment_${appointment.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Iconsax.trash, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Quitar',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        onDismissed();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cita oculta del inicio',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: DashboardAppointmentMiniCard(
        appointment: appointment,
        textColor: textColor,
        mutedColor: mutedColor,
        cardColor: cardColor,
        borderColor: borderColor,
        accentColor: accentColor,
      ),
    );
  }
}

class DashboardLoadErrorState extends StatelessWidget {
  const DashboardLoadErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
  });

  final String? errorMessage;
  final VoidCallback onRetry;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.info_circle, color: mutedColor, size: 64),
            const SizedBox(height: 16),
            Text(
              'No se pudo cargar el dashboard',
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  errorMessage!,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFDC2626),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

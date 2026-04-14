import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/appointment.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/jwt_decoder.dart';
import '../../../utils/money_formatter.dart';
import '../../../utils/role_helper.dart';
import 'appointment_card_helpers.dart';

class AppointmentListCard extends ConsumerWidget {
  const AppointmentListCard({
    super.key,
    required this.appointment,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
    required this.onTap,
    this.isSmallScreen = false,
  });

  final AppointmentDto appointment;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isSmallScreen;

  static Color statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFF10B981);
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Cancelled':
        return const Color(0xFFEF4444);
      case 'Completed':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF6B7280);
    }
  }

  static String statusLabel(String status) {
    switch (status) {
      case 'Confirmed':
        return 'Confirmada';
      case 'Pending':
        return 'Pendiente';
      case 'Cancelled':
        return 'Cancelada';
      case 'Completed':
        return 'Completada';
      default:
        return status;
    }
  }

  static IconData statusIcon(String status) {
    switch (status) {
      case 'Confirmed':
        return Iconsax.tick_circle;
      case 'Pending':
        return Iconsax.clock;
      case 'Cancelled':
        return Iconsax.close_circle;
      case 'Completed':
        return Iconsax.tick_square;
      default:
        return Iconsax.info_circle;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmall = isSmallScreen;
    final stColor = statusColor(appointment.status);
    final dateTime = appointment.dateTime;
    final isToday = dateTime.year == DateTime.now().year &&
        dateTime.month == DateTime.now().month &&
        dateTime.day == DateTime.now().day;

    var isMyAppointment = false;
    final isEmployee = RoleHelper.isEmployee(ref);
    if (isEmployee) {
      final authState = ref.read(authNotifierProvider);
      final currentEmployeeId = int.tryParse(
            JwtDecoder.getUserId(authState.userToken) ?? '',
          ) ??
          int.tryParse(authState.userProfile?.userId ?? '');
      isMyAppointment = appointment.isAssignedTo(currentEmployeeId);
    }

    final timeShort = appointmentCardShortTime(appointment.time);
    final serviceLine = appointmentCardServiceSummaryLine(appointment);
    final dateLabel = isToday ? 'Hoy' : appointmentCardFormatShortDate(appointment.date);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (isEmployee && isMyAppointment)
                ? accentColor.withValues(alpha: 0.45)
                : borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isSmall ? 14 : 16,
            isSmall ? 12 : 14,
            isSmall ? 14 : 16,
            isSmall ? 12 : 14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: isSmall ? 38 : 40,
                    height: isSmall ? 38 : 40,
                    decoration: BoxDecoration(
                      color: mutedColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Iconsax.calendar,
                      color: accentColor,
                      size: isSmall ? 18 : 20,
                    ),
                  ),
                  SizedBox(width: isSmall ? 12 : 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.clientName,
                          style: GoogleFonts.inter(
                            fontSize: isSmall ? 15 : 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: textColor,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isSmall ? 3 : 4),
                        Text(
                          serviceLine,
                          style: GoogleFonts.inter(
                            fontSize: isSmall ? 12 : 13,
                            fontWeight: FontWeight.w400,
                            color: mutedColor,
                            height: 1.25,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isSmall ? 6 : 8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 8 : 10,
                      vertical: isSmall ? 5 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: stColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon(appointment.status),
                          size: isSmall ? 12 : 13,
                          color: stColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel(appointment.status),
                          style: GoogleFonts.inter(
                            fontSize: isSmall ? 11 : 12,
                            fontWeight: FontWeight.w600,
                            color: stColor,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 12),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: borderColor.withValues(alpha: 0.65),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      '$dateLabel · $timeShort',
                      style: GoogleFonts.inter(
                        fontSize: isSmall ? 13 : 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        letterSpacing: -0.15,
                      ),
                    ),
                  ),
                  Text(
                    MoneyFormatter.formatCordobas(
                      appointmentCardTotalPrice(appointment),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: isSmall ? 15 : 16,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

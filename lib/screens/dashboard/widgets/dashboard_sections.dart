import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/dashboard_barber.dart';
import '../../../utils/money_formatter.dart';
import '../../../utils/responsive_breakpoints.dart';
import 'dashboard_cards.dart';

class DashboardTodayQuickStat extends StatelessWidget {
  const DashboardTodayQuickStat({
    super.key,
    required this.dashboard,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
  });

  final BarberDashboardDto dashboard;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final today = dashboard.today;
    return DashboardQuickStatCard(
      icon: Iconsax.calendar_2,
      value: today.appointments.toString(),
      label: 'Citas hoy',
      color: accentColor,
      textColor: textColor,
      mutedColor: mutedColor,
      cardColor: cardColor,
      borderColor: borderColor,
    );
  }
}

class DashboardSummaryGrid extends StatelessWidget {
  const DashboardSummaryGrid({
    super.key,
    required this.dashboard,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
  });

  final BarberDashboardDto dashboard;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final today = dashboard.today;
    final month = dashboard.thisMonth;
    final w = context.screenWidth;
    final isSmallScreen = w < AppBreakpoints.compactWidth;
    final cardSpacing = isSmallScreen ? 8.0 : 10.0;
    final rowSpacing = isSmallScreen ? 8.0 : 10.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardQuickStatCard(
                icon: Iconsax.wallet_3,
                value: MoneyFormatter.formatCordobas(today.income),
                label: 'Ingresos hoy',
                color: const Color(0xFF22C55E),
                textColor: textColor,
                mutedColor: mutedColor,
                cardColor: cardColor,
                borderColor: borderColor,
              ),
            ),
            SizedBox(width: cardSpacing),
            Expanded(
              child: DashboardQuickStatCard(
                icon: Iconsax.wallet_3,
                value: MoneyFormatter.formatCordobas(month.income),
                label: 'Ingresos mes',
                color: const Color(0xFF22C55E),
                textColor: textColor,
                mutedColor: mutedColor,
                cardColor: cardColor,
                borderColor: borderColor,
              ),
            ),
          ],
        ),
        SizedBox(height: rowSpacing),
        Row(
          children: [
            Expanded(
              child: DashboardQuickStatCard(
                icon: Iconsax.money_send,
                value: MoneyFormatter.formatCordobas(today.expenses),
                label: 'Egresos hoy',
                color: const Color(0xFFF59E0B),
                textColor: textColor,
                mutedColor: mutedColor,
                cardColor: cardColor,
                borderColor: borderColor,
              ),
            ),
            SizedBox(width: cardSpacing),
            Expanded(
              child: DashboardQuickStatCard(
                icon: Iconsax.money_send,
                value: MoneyFormatter.formatCordobas(month.expenses),
                label: 'Egresos mes',
                color: const Color(0xFFF59E0B),
                textColor: textColor,
                mutedColor: mutedColor,
                cardColor: cardColor,
                borderColor: borderColor,
              ),
            ),
          ],
        ),
        SizedBox(height: rowSpacing),
        Row(
          children: [
            Expanded(
              child: DashboardQuickStatCard(
                icon: Iconsax.chart_21,
                value: MoneyFormatter.formatCordobas(today.profit),
                label: 'Ganancia hoy',
                color: const Color(0xFF10B981),
                textColor: textColor,
                mutedColor: mutedColor,
                cardColor: cardColor,
                borderColor: borderColor,
              ),
            ),
            SizedBox(width: cardSpacing),
            Expanded(
              child: DashboardQuickStatCard(
                icon: Iconsax.chart_21,
                value: MoneyFormatter.formatCordobas(month.profit),
                label: 'Ganancia mes',
                color: const Color(0xFF10B981),
                textColor: textColor,
                mutedColor: mutedColor,
                cardColor: cardColor,
                borderColor: borderColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DashboardAdditionalStatsCard extends StatelessWidget {
  const DashboardAdditionalStatsCard({
    super.key,
    required this.dashboard,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
  });

  final BarberDashboardDto dashboard;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final week = dashboard.thisWeek;
    final month = dashboard.thisMonth;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Iconsax.chart_2, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Estadísticas Adicionales',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DashboardStatItem(
                  icon: Iconsax.people,
                  value: month.uniqueClients.toString(),
                  label: 'Clientes únicos',
                  color: const Color(0xFF6366F1),
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
              ),
              Container(width: 1, height: 40, color: borderColor),
              Expanded(
                child: DashboardStatItem(
                  icon: Iconsax.dollar_circle,
                  value: MoneyFormatter.formatCordobas(month.averagePerClient),
                  label: 'Promedio/cliente',
                  color: const Color(0xFF22C55E),
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DashboardStatItem(
                  icon: Iconsax.calendar_2,
                  value: week.appointments.toString(),
                  label: 'Citas esta semana',
                  color: accentColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
              ),
              Container(width: 1, height: 40, color: borderColor),
              Expanded(
                child: DashboardStatItem(
                  icon: Iconsax.calendar_2,
                  value: month.appointments.toString(),
                  label: 'Citas este mes',
                  color: accentColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardUpcomingAppointmentsSection extends StatelessWidget {
  const DashboardUpcomingAppointmentsSection({
    super.key,
    required this.dashboard,
    required this.dismissedAppointmentIds,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
    required this.onNavigateToAppointments,
    required this.onDismissAppointment,
  });

  final BarberDashboardDto dashboard;
  final Set<int> dismissedAppointmentIds;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;
  final VoidCallback? onNavigateToAppointments;
  final ValueChanged<int> onDismissAppointment;

  @override
  Widget build(BuildContext context) {
    final activeAppointments = dashboard.upcomingAppointments
        .where((apt) =>
            apt.status != 'Completed' &&
            apt.status != 'Cancelled' &&
            !dismissedAppointmentIds.contains(apt.id))
        .take(3)
        .toList();

    if (activeAppointments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Próximas Citas',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onNavigateToAppointments,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver todas',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Iconsax.arrow_right_3, size: 14, color: accentColor),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...activeAppointments.map((apt) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DashboardDismissibleAppointmentCard(
                appointment: apt,
                textColor: textColor,
                mutedColor: mutedColor,
                cardColor: cardColor,
                borderColor: borderColor,
                accentColor: accentColor,
                onDismissed: () => onDismissAppointment(apt.id),
              ),
            )),
      ],
    );
  }
}

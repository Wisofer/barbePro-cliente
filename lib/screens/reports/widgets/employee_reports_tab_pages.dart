import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/employee_reports.dart';
import '../../../utils/money_formatter.dart';
import 'employee_report_appointment_income_cards.dart';
import 'employee_report_expense_activity_cards.dart';
import 'employee_report_summary_and_charts.dart';

class EmployeeReportsAppointmentsTab extends StatelessWidget {
  const EmployeeReportsAppointmentsTab({
    super.key,
    required this.report,
    required this.onRefresh,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
  });

  final EmployeeAppointmentsReportDto? report;
  final Future<void> Function() onRefresh;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return Center(
        child: Text(
          'No hay datos disponibles',
          style: GoogleFonts.inter(color: mutedColor),
        ),
      );
    }
    final r = report!;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: accentColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmployeeReportSummaryCard(
              title: 'Total de Citas',
              value: r.totalAppointments.toString(),
              icon: Iconsax.calendar_2,
              iconColor: accentColor,
              textColor: textColor,
              mutedColor: mutedColor,
              cardColor: cardColor,
              borderColor: borderColor,
            ),
            const SizedBox(height: 16),
            if (r.byEmployee.isNotEmpty) ...[
              Text(
                'Citas por Estado',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              EmployeeReportStatusChart(
                employees: r.byEmployee,
                textColor: textColor,
                mutedColor: mutedColor,
                cardColor: cardColor,
                borderColor: borderColor,
                accentColor: accentColor,
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Detalle por Empleado',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            ...r.byEmployee.map(
              (emp) => EmployeeAppointmentStatsCard(
                emp: emp,
                textColor: textColor,
                mutedColor: mutedColor,
                cardColor: cardColor,
                borderColor: borderColor,
                accentColor: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmployeeReportsIncomeTab extends StatelessWidget {
  const EmployeeReportsIncomeTab({
    super.key,
    required this.report,
    required this.onRefresh,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
  });

  final EmployeeIncomeReportDto? report;
  final Future<void> Function() onRefresh;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return Center(
        child: Text(
          'No hay datos disponibles',
          style: GoogleFonts.inter(color: mutedColor),
        ),
      );
    }
    final r = report!;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: accentColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmployeeReportSummaryCard(
              title: 'Ingresos Totales',
              value: MoneyFormatter.format(r.totalIncome),
              icon: Iconsax.wallet_add,
              iconColor: accentColor,
              textColor: textColor,
              mutedColor: mutedColor,
              cardColor: cardColor,
              borderColor: borderColor,
            ),
            const SizedBox(height: 16),
            if (r.byEmployee.isNotEmpty) ...[
              Text(
                'Distribución de Ingresos',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              EmployeeReportIncomeChart(
                employees: r.byEmployee,
                textColor: textColor,
                mutedColor: mutedColor,
                cardColor: cardColor,
                borderColor: borderColor,
                accentColor: accentColor,
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Detalle por Empleado',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            ...r.byEmployee.map(
              (emp) => EmployeeIncomeStatsCard(
                emp: emp,
                textColor: textColor,
                mutedColor: mutedColor,
                cardColor: cardColor,
                borderColor: borderColor,
                accentColor: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmployeeReportsExpensesTab extends StatelessWidget {
  const EmployeeReportsExpensesTab({
    super.key,
    required this.report,
    required this.onRefresh,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
  });

  final EmployeeExpensesReportDto? report;
  final Future<void> Function() onRefresh;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return Center(
        child: Text(
          'No hay datos disponibles',
          style: GoogleFonts.inter(color: mutedColor),
        ),
      );
    }
    final r = report!;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: accentColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmployeeReportSummaryCard(
              title: 'Egresos Totales',
              value: MoneyFormatter.format(r.totalExpenses),
              icon: Iconsax.wallet_minus,
              iconColor: const Color(0xFFEF4444),
              textColor: textColor,
              mutedColor: mutedColor,
              cardColor: cardColor,
              borderColor: borderColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Detalle por Empleado',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            ...r.byEmployee.map(
              (emp) => EmployeeExpenseStatsCard(
                emp: emp,
                textColor: textColor,
                mutedColor: mutedColor,
                cardColor: cardColor,
                borderColor: borderColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmployeeReportsActivityTab extends StatelessWidget {
  const EmployeeReportsActivityTab({
    super.key,
    required this.report,
    required this.onRefresh,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
  });

  final EmployeeActivityReportDto? report;
  final Future<void> Function() onRefresh;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return Center(
        child: Text(
          'No hay datos disponibles',
          style: GoogleFonts.inter(color: mutedColor),
        ),
      );
    }
    final r = report!;

    if (r.employees.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.chart_2, color: mutedColor, size: 64),
              const SizedBox(height: 16),
              Text(
                'No hay datos',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No hay empleados con actividad en el período seleccionado.',
                style: GoogleFonts.inter(fontSize: 14, color: mutedColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: accentColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actividad de Empleados',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            ...r.employees.map(
              (emp) => EmployeeActivityStatsCard(
                emp: emp,
                textColor: textColor,
                mutedColor: mutedColor,
                cardColor: cardColor,
                borderColor: borderColor,
                accentColor: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

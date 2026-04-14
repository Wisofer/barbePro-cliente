import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/employee_reports.dart';
import '../../../utils/money_formatter.dart';
import 'employee_report_summary_and_charts.dart';

class EmployeeAppointmentStatsCard extends StatelessWidget {
  const EmployeeAppointmentStatsCard({
    super.key,
    required this.emp,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
  });

  final EmployeeAppointmentStats emp;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Iconsax.user, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emp.employeeName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${emp.total} citas totales',
                      style: GoogleFonts.inter(fontSize: 12, color: mutedColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: EmployeeReportStatChip(
                  label: 'Completadas',
                  value: emp.completed.toString(),
                  color: const Color(0xFF10B981),
                ),
              ),
              Expanded(
                child: EmployeeReportStatChip(
                  label: 'Confirmadas',
                  value: emp.confirmed.toString(),
                  color: const Color(0xFF6366F1),
                ),
              ),
              Expanded(
                child: EmployeeReportStatChip(
                  label: 'Pendientes',
                  value: emp.pending.toString(),
                  color: const Color(0xFFF59E0B),
                ),
              ),
              Expanded(
                child: EmployeeReportStatChip(
                  label: 'Canceladas',
                  value: emp.cancelled.toString(),
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ingresos totales:',
                  style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
                ),
                Text(
                  MoneyFormatter.format(emp.totalIncome),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
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

class EmployeeIncomeStatsCard extends StatelessWidget {
  const EmployeeIncomeStatsCard({
    super.key,
    required this.emp,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
  });

  final EmployeeIncomeStats emp;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Iconsax.wallet_add, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emp.employeeName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${emp.count} transacciones',
                      style: GoogleFonts.inter(fontSize: 12, color: mutedColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: EmployeeReportStatChip(
                  label: 'De citas',
                  value: MoneyFormatter.format(emp.fromAppointments),
                  color: accentColor,
                ),
              ),
              Expanded(
                child: EmployeeReportStatChip(
                  label: 'Manuales',
                  value: MoneyFormatter.format(emp.manual),
                  color: const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
                ),
                Text(
                  MoneyFormatter.format(emp.totalIncome),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
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

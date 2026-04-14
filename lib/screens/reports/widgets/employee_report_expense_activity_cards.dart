import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/employee_reports.dart';
import '../../../utils/money_formatter.dart';
import 'employee_report_summary_and_charts.dart';

class EmployeeExpenseStatsCard extends StatelessWidget {
  const EmployeeExpenseStatsCard({
    super.key,
    required this.emp,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
  });

  final EmployeeExpenseStats emp;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;

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
                  color: const Color(0xFFEF4444).withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.wallet_minus,
                    color: Color(0xFFEF4444), size: 20),
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
          if (emp.categories.isNotEmpty) ...[
            Text(
              'Por categoría:',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: mutedColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...emp.categories.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: GoogleFonts.inter(fontSize: 13, color: textColor),
                    ),
                    Text(
                      MoneyFormatter.format(entry.value),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: mutedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withAlpha(10),
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
                  MoneyFormatter.format(emp.totalExpenses),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF4444),
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

class EmployeeActivityStatsCard extends StatelessWidget {
  const EmployeeActivityStatsCard({
    super.key,
    required this.emp,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
  });

  final EmployeeActivityStats emp;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final netColor =
        emp.netContribution >= 0 ? accentColor : const Color(0xFFEF4444);

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
                    Row(
                      children: [
                        Text(
                          emp.employeeName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        if (!emp.isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: mutedColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Inactivo',
                              style: GoogleFonts.inter(
                                  fontSize: 10, color: mutedColor),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (emp.email.isNotEmpty)
                      Text(
                        emp.email,
                        style:
                            GoogleFonts.inter(fontSize: 12, color: mutedColor),
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
                  value: emp.appointmentsCompleted.toString(),
                  color: accentColor,
                ),
              ),
              Expanded(
                child: EmployeeReportStatChip(
                  label: 'Pendientes',
                  value: emp.appointmentsPending.toString(),
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: EmployeeReportStatChip(
                  label: 'Ingresos',
                  value: MoneyFormatter.format(emp.totalIncome),
                  color: accentColor,
                ),
              ),
              Expanded(
                child: EmployeeReportStatChip(
                  label: 'Egresos',
                  value: MoneyFormatter.format(emp.totalExpenses),
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: netColor.withAlpha(10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: netColor.withAlpha(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contribución neta:',
                  style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
                ),
                Text(
                  MoneyFormatter.format(emp.netContribution),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: netColor,
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

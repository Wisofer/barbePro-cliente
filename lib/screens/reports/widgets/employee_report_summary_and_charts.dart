import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/employee_reports.dart';
import '../../../utils/money_formatter.dart';

class EmployeeReportSummaryCard extends StatelessWidget {
  const EmployeeReportSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor,
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

class EmployeeReportStatChip extends StatelessWidget {
  const EmployeeReportStatChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeReportStatusChart extends StatelessWidget {
  const EmployeeReportStatusChart({
    super.key,
    required this.employees,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
  });

  final List<EmployeeAppointmentStats> employees;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    var totalCompleted = 0;
    var totalPending = 0;
    var totalConfirmed = 0;
    var totalCancelled = 0;

    for (final emp in employees) {
      totalCompleted += emp.completed;
      totalPending += emp.pending;
      totalConfirmed += emp.confirmed;
      totalCancelled += emp.cancelled;
    }

    final total =
        totalCompleted + totalPending + totalConfirmed + totalCancelled;
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            'No hay citas en el período seleccionado',
            style: GoogleFonts.inter(color: mutedColor),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _ReportBarRow(
            label: 'Completadas',
            value: totalCompleted,
            total: total,
            color: accentColor,
            textColor: textColor,
            mutedColor: mutedColor,
          ),
          const SizedBox(height: 12),
          _ReportBarRow(
            label: 'Confirmadas',
            value: totalConfirmed,
            total: total,
            color: const Color(0xFF10B981),
            textColor: textColor,
            mutedColor: mutedColor,
          ),
          const SizedBox(height: 12),
          _ReportBarRow(
            label: 'Pendientes',
            value: totalPending,
            total: total,
            color: const Color(0xFFF59E0B),
            textColor: textColor,
            mutedColor: mutedColor,
          ),
          const SizedBox(height: 12),
          _ReportBarRow(
            label: 'Canceladas',
            value: totalCancelled,
            total: total,
            color: const Color(0xFFEF4444),
            textColor: textColor,
            mutedColor: mutedColor,
          ),
        ],
      ),
    );
  }
}

class _ReportBarRow extends StatelessWidget {
  const _ReportBarRow({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
    required this.textColor,
    required this.mutedColor,
  });

  final String label;
  final int value;
  final int total;
  final Color color;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (value / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value (${(percentage * 100).toStringAsFixed(1)}%)',
              style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withAlpha(30),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class EmployeeReportIncomeChart extends StatelessWidget {
  const EmployeeReportIncomeChart({
    super.key,
    required this.employees,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
  });

  final List<EmployeeIncomeStats> employees;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final total =
        employees.fold<double>(0.0, (sum, emp) => sum + emp.totalIncome);
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            'No hay ingresos en el período seleccionado',
            style: GoogleFonts.inter(color: mutedColor),
          ),
        ),
      );
    }

    final colors = <Color>[
      accentColor,
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: employees.asMap().entries.map((entry) {
          final index = entry.key;
          final emp = entry.value;
          final percentage = total > 0 ? (emp.totalIncome / total) : 0.0;
          final color = colors[index % colors.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        emp.employeeName,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      MoneyFormatter.format(emp.totalIncome),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: mutedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: color.withAlpha(30),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

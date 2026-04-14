import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../models/employee.dart';

class EmployeeReportsFiltersPanel extends StatelessWidget {
  const EmployeeReportsFiltersPanel({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.selectedEmployeeId,
    required this.employees,
    required this.selectedTabIndex,
    required this.onPickDateRange,
    required this.onEmployeeChanged,
    required this.onClearFilters,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final int? selectedEmployeeId;
  final List<EmployeeDto> employees;
  final int selectedTabIndex;
  final VoidCallback onPickDateRange;
  final ValueChanged<int?> onEmployeeChanged;
  final VoidCallback onClearFilters;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onPickDateRange,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.calendar, color: accentColor, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            startDate != null && endDate != null
                                ? '${DateFormat('dd/MM/yyyy').format(startDate!)} - ${DateFormat('dd/MM/yyyy').format(endDate!)}'
                                : 'Seleccionar rango de fechas',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: startDate != null ? textColor : mutedColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (selectedTabIndex != 3)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: selectedEmployeeId,
                        isExpanded: true,
                        hint: Text(
                          'Todos los empleados',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: mutedColor),
                        ),
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text(
                              'Todos los empleados',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: textColor),
                            ),
                          ),
                          ...employees.map((emp) {
                            return DropdownMenuItem<int?>(
                              value: emp.id,
                              child: Text(
                                emp.name,
                                style: GoogleFonts.inter(
                                    fontSize: 13, color: textColor),
                              ),
                            );
                          }),
                        ],
                        onChanged: onEmployeeChanged,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (startDate != null || selectedEmployeeId != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onClearFilters,
                icon: Icon(Iconsax.close_circle, size: 16, color: mutedColor),
                label: Text(
                  'Limpiar filtros',
                  style: GoogleFonts.inter(fontSize: 12, color: mutedColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EmployeeReportsLoadError extends StatelessWidget {
  const EmployeeReportsLoadError({
    super.key,
    required this.message,
    required this.onRetry,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
  });

  final String message;
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
            const Icon(Iconsax.warning_2, color: Color(0xFFEF4444), size: 56),
            const SizedBox(height: 16),
            Text(
              'Error al cargar',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.inter(fontSize: 14, color: mutedColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh, size: 18),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

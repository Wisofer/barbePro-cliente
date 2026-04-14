import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/employee.dart';
import '../../models/employee_reports.dart';
import '../../services/api/employee_reports_service.dart';
import '../../services/api/employee_service.dart';
import '../../utils/role_helper.dart';
import '../../widgets/responsive_centered_body.dart';
import 'widgets/employee_reports_filters_panel.dart';
import 'widgets/employee_reports_tab_pages.dart';

class EmployeeReportsScreen extends ConsumerStatefulWidget {
  const EmployeeReportsScreen({super.key});

  @override
  ConsumerState<EmployeeReportsScreen> createState() =>
      _EmployeeReportsScreenState();
}

class _EmployeeReportsScreenState extends ConsumerState<EmployeeReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedEmployeeId;
  List<EmployeeDto> _employees = [];

  EmployeeAppointmentsReportDto? _appointmentsReport;
  EmployeeIncomeReportDto? _incomeReport;
  EmployeeExpensesReportDto? _expensesReport;
  EmployeeActivityReportDto? _activityReport;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadEmployees();
    _loadCurrentReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    if (RoleHelper.isEmployee(ref)) return;

    try {
      final service = ref.read(employeeServiceProvider);
      final employees = await service.getEmployees();
      if (mounted) {
        setState(() {
          _employees = employees;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadCurrentReport() async {
    if (RoleHelper.isEmployee(ref)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reportsService = ref.read(employeeReportsServiceProvider);

      switch (_selectedTab) {
        case 0:
          _appointmentsReport = await reportsService.getAppointmentsReport(
            startDate: _startDate,
            endDate: _endDate,
            employeeId: _selectedEmployeeId,
          );
          break;
        case 1:
          _incomeReport = await reportsService.getIncomeReport(
            startDate: _startDate,
            endDate: _endDate,
            employeeId: _selectedEmployeeId,
          );
          break;
        case 2:
          _expensesReport = await reportsService.getExpensesReport(
            startDate: _startDate,
            endDate: _endDate,
            employeeId: _selectedEmployeeId,
          );
          break;
        case 3:
          _activityReport = await reportsService.getActivityReport(
            startDate: _startDate,
            endDate: _endDate,
          );
          break;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Error al cargar el reporte';
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1);
    final lastDate = DateTime(now.year + 1);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : DateTimeRange(
              start: DateTime(now.year, now.month, 1),
              end: now,
            ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF10B981),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadCurrentReport();
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedEmployeeId = null;
    });
    _loadCurrentReport();
  }

  Widget _reportBody(
    Color textColor,
    Color mutedColor,
    Color cardColor,
    Color borderColor,
    Color accentColor,
  ) {
    switch (_selectedTab) {
      case 0:
        return EmployeeReportsAppointmentsTab(
          report: _appointmentsReport,
          onRefresh: _loadCurrentReport,
          textColor: textColor,
          mutedColor: mutedColor,
          cardColor: cardColor,
          borderColor: borderColor,
          accentColor: accentColor,
        );
      case 1:
        return EmployeeReportsIncomeTab(
          report: _incomeReport,
          onRefresh: _loadCurrentReport,
          textColor: textColor,
          mutedColor: mutedColor,
          cardColor: cardColor,
          borderColor: borderColor,
          accentColor: accentColor,
        );
      case 2:
        return EmployeeReportsExpensesTab(
          report: _expensesReport,
          onRefresh: _loadCurrentReport,
          textColor: textColor,
          mutedColor: mutedColor,
          cardColor: cardColor,
          borderColor: borderColor,
          accentColor: accentColor,
        );
      case 3:
        return EmployeeReportsActivityTab(
          report: _activityReport,
          onRefresh: _loadCurrentReport,
          textColor: textColor,
          mutedColor: mutedColor,
          cardColor: cardColor,
          borderColor: borderColor,
          accentColor: accentColor,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
    final cardColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
    final bgColor = isDark ? const Color(0xFF0A0A0B) : Colors.white;
    const accentColor = Color(0xFF10B981);

    if (RoleHelper.isEmployee(ref)) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(
            'Reportes de Empleados',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: cardColor,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.chart_2, color: mutedColor, size: 64),
                const SizedBox(height: 16),
                Text(
                  'No disponible',
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Los reportes de empleados solo están disponibles para el dueño de la barbería.',
                  style: GoogleFonts.inter(
                    color: mutedColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Reportes de Empleados',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() => _selectedTab = index);
            _loadCurrentReport();
          },
          labelColor: accentColor,
          unselectedLabelColor: mutedColor,
          indicatorColor: accentColor,
          tabs: const [
            Tab(text: 'Citas', icon: Icon(Iconsax.calendar_2, size: 20)),
            Tab(text: 'Ingresos', icon: Icon(Iconsax.wallet_add, size: 20)),
            Tab(text: 'Egresos', icon: Icon(Iconsax.wallet_minus, size: 20)),
            Tab(text: 'Actividad', icon: Icon(Iconsax.chart_2, size: 20)),
          ],
        ),
      ),
      body: Column(
        children: [
          EmployeeReportsFiltersPanel(
            startDate: _startDate,
            endDate: _endDate,
            selectedEmployeeId: _selectedEmployeeId,
            employees: _employees,
            selectedTabIndex: _selectedTab,
            onPickDateRange: _selectDateRange,
            onEmployeeChanged: (value) {
              setState(() => _selectedEmployeeId = value);
              _loadCurrentReport();
            },
            onClearFilters: _clearFilters,
            textColor: textColor,
            mutedColor: mutedColor,
            cardColor: cardColor,
            borderColor: borderColor,
            accentColor: accentColor,
          ),
          Expanded(
            child: ResponsiveCenteredBody(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: accentColor))
                  : _errorMessage != null
                      ? EmployeeReportsLoadError(
                          message: _errorMessage!,
                          onRetry: _loadCurrentReport,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          accentColor: accentColor,
                        )
                      : _reportBody(
                          textColor,
                          mutedColor,
                          cardColor,
                          borderColor,
                          accentColor,
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

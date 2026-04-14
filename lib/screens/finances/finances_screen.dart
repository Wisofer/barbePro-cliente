import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../models/finance.dart';
import '../../services/api/barber_service.dart';
import '../../services/api/employee_finance_service.dart';
import '../../utils/money_formatter.dart';
import '../../utils/role_helper.dart';
import '../profile/profile_palette.dart';
import '../profile/widgets/profile_ios_section.dart' show IosGroupedCard;
import '../profile/widgets/ios_grouped_row.dart';
import 'income_screen.dart';
import 'expenses_screen.dart';

class FinancesScreen extends ConsumerStatefulWidget {
  const FinancesScreen({super.key});

  @override
  ConsumerState<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends ConsumerState<FinancesScreen> {
  FinanceSummaryDto? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    // Si es Employee, calcular resumen desde ingresos y egresos
    if (RoleHelper.isEmployee(ref)) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        
        final employeeService = ref.read(employeeFinanceServiceProvider);
        final incomeResponse = await employeeService.getIncome(
          startDate: startOfMonth,
          endDate: endOfMonth,
        );
        final expensesResponse = await employeeService.getExpenses(
          startDate: startOfMonth,
          endDate: endOfMonth,
        );
        
        final incomeThisMonth = incomeResponse.items.fold<double>(0.0, (sum, item) => sum + item.amount);
        final expensesThisMonth = expensesResponse.items.fold<double>(0.0, (sum, item) => sum + item.amount);
        final profitThisMonth = incomeThisMonth - expensesThisMonth;
        
        final totalIncomeResponse = await employeeService.getIncome();
        final totalExpensesResponse = await employeeService.getExpenses();
        
        final totalIncome = totalIncomeResponse.items.fold<double>(0.0, (sum, item) => sum + item.amount);
        final totalExpenses = totalExpensesResponse.items.fold<double>(0.0, (sum, item) => sum + item.amount);
        final netProfit = totalIncome - totalExpenses;
        
        if (mounted) {
          setState(() {
            _summary = FinanceSummaryDto(
              incomeThisMonth: incomeThisMonth,
              expensesThisMonth: expensesThisMonth,
              profitThisMonth: profitThisMonth,
              totalIncome: totalIncome,
              totalExpenses: totalExpenses,
              netProfit: netProfit,
            );
            _isLoading = false;
            _errorMessage = null;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = e.toString().replaceAll('Exception: ', '');
          });
        }
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final service = ref.read(barberServiceProvider);
      final summary = await service.getFinanceSummary();
      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      
      String message;
      if (errorData is Map<String, dynamic>) {
        message = errorData['message'] ?? e.message ?? 'Error desconocido';
      } else if (errorData is String) {
        message = errorData;
      } else {
        message = e.message ?? 'Error desconocido';
      }
      
      if (statusCode == 404) {
        message = 'Endpoint no encontrado. Verifica la configuración del servidor.';
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = statusCode != null ? 'Error $statusCode: $message' : message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = ProfilePalette.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final groupedBg = isDark ? const Color(0xFF000000) : Colors.white;
    final sectionHeaderColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D72);
    final textColor = p.textColor;
    final mutedColor = p.mutedColor;
    final cardColor = p.cardColor;
    final borderColor = p.borderColor;
    final accentColor = p.accent;
    const incomeGreen = Color(0xFF22C55E);
    const expenseRed = Color(0xFFEF4444);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: groupedBg,
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(color: accentColor),
          ),
        ),
      );
    }

    if (_summary == null) {
      return Scaffold(
        backgroundColor: groupedBg,
        body: SafeArea(
          child: _ErrorState(
            errorMessage: _errorMessage,
            onRetry: _loadSummary,
            textColor: textColor,
            mutedColor: mutedColor,
            accentColor: accentColor,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: groupedBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadSummary,
          color: accentColor,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Text(
                    'Finanzas',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.6,
                      height: 1.15,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                  child: Text(
                    'Resumen de tu negocio.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: mutedColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 16, bottom: 6, top: 20),
                  child: Text(
                    'ESTE MES',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: sectionHeaderColor,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildProfitCard(mutedColor, cardColor, accentColor),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 16, bottom: 6, top: 20),
                  child: Text(
                    'INGRESOS Y EGRESOS',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: sectionHeaderColor,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildMonthInOut(cardColor, borderColor, textColor),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 16, bottom: 6, top: 20),
                  child: Text(
                    'ACCIONES',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: sectionHeaderColor,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildQuickAccessRows(
                  textColor,
                  mutedColor,
                  cardColor,
                  borderColor,
                  incomeGreen,
                  expenseRed,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 16, bottom: 6, top: 20),
                  child: Text(
                    'TOTAL ACUMULADO',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: sectionHeaderColor,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: _buildTotalSummary(
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
        ),
      ),
    );
  }

  Widget _buildProfitCard(Color mutedColor, Color cardColor, Color accentColor) {
    final profit = _summary!.profitThisMonth;
    final isPositive = profit >= 0;
    final highlightColor = isPositive ? accentColor : const Color(0xFFEF4444);

    return IosGroupedCard(
      cardColor: cardColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GANANCIA DEL MES',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: mutedColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              MoneyFormatter.formatCordobas(profit.abs()),
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: highlightColor,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isPositive
                  ? 'Los ingresos del mes cubren los egresos.'
                  : 'Los egresos superan los ingresos del mes.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: mutedColor,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthInOut(Color cardColor, Color borderColor, Color textColor) {
    return IosGroupedCard(
      cardColor: cardColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Iconsax.arrow_down, size: 18, color: const Color(0xFF22C55E)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ingresos del mes',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                Text(
                  MoneyFormatter.formatCordobas(_summary!.incomeThisMonth),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 16,
            color: borderColor.withValues(alpha: 0.75),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Iconsax.arrow_up, size: 18, color: const Color(0xFFEF4444)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Egresos del mes',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                Text(
                  MoneyFormatter.formatCordobas(_summary!.expensesThisMonth),
                  style: GoogleFonts.inter(
                    fontSize: 16,
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

  Widget _buildQuickAccessRows(
    Color textColor,
    Color mutedColor,
    Color cardColor,
    Color borderColor,
    Color incomeGreen,
    Color expenseRed,
  ) {
    return IosGroupedCard(
      cardColor: cardColor,
      child: Column(
        children: [
          IosGroupedRow(
            icon: Iconsax.arrow_down,
            title: 'Ingresos',
            subtitle: 'Listado y movimientos',
            accentColor: incomeGreen,
            textColor: textColor,
            mutedColor: mutedColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const IncomeScreen()),
              );
            },
            trailing: Icon(Iconsax.arrow_right_3, size: 18, color: mutedColor),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 16,
            color: borderColor.withValues(alpha: 0.75),
          ),
          IosGroupedRow(
            icon: Iconsax.arrow_up,
            title: 'Egresos',
            subtitle: 'Listado y movimientos',
            accentColor: expenseRed,
            textColor: textColor,
            mutedColor: mutedColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExpensesScreen()),
              );
            },
            trailing: Icon(Iconsax.arrow_right_3, size: 18, color: mutedColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary(
    Color textColor,
    Color mutedColor,
    Color cardColor,
    Color borderColor,
    Color accentColor,
  ) {
    return IosGroupedCard(
      cardColor: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Iconsax.chart_2, color: accentColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  'Desde el inicio',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 16,
            color: borderColor.withValues(alpha: 0.75),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: _SummaryItem(
              label: 'Ingresos totales',
              value: MoneyFormatter.formatCordobas(_summary!.totalIncome),
              color: const Color(0xFF22C55E),
              textColor: textColor,
              mutedColor: mutedColor,
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 16,
            color: borderColor.withValues(alpha: 0.75),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: _SummaryItem(
              label: 'Egresos totales',
              value: MoneyFormatter.formatCordobas(_summary!.totalExpenses),
              color: const Color(0xFFEF4444),
              textColor: textColor,
              mutedColor: mutedColor,
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 16,
            color: borderColor.withValues(alpha: 0.75),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ganancia neta',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  Text(
                    MoneyFormatter.formatCordobas(_summary!.netProfit),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color textColor;
  final Color mutedColor;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: mutedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;

  const _ErrorState({
    required this.errorMessage,
    required this.onRetry,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.wallet, color: mutedColor, size: 64),
            const SizedBox(height: 16),
            Text(
              'No se pudo cargar la información',
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
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

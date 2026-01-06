import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../models/finance.dart';
import '../../services/api/barber_service.dart';
import '../../utils/money_formatter.dart';
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      print('🔵 [Finances] Cargando resumen financiero...');
      final service = ref.read(barberServiceProvider);
      final summary = await service.getFinanceSummary();
      print('✅ [Finances] Resumen cargado: Ingresos: ${summary.incomeThisMonth}, Egresos: ${summary.expensesThisMonth}');
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
      
      print('❌ [Finances] Error HTTP: $statusCode');
      print('📋 [Finances] Error data: $errorData');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = statusCode != null ? 'Error $statusCode: $message' : message;
        });
      }
    } catch (e, stackTrace) {
      print('❌ [Finances] Error al cargar: $e');
      print('📋 [Finances] StackTrace: $stackTrace');
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
    final cardColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFD1D5DB);
    const accentColor = Color(0xFF10B981);

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: accentColor));
    }

    if (_summary == null) {
      return Center(
        child: Padding(
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
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFDC2626),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Text(
                  'Verifica tu conexión e intenta nuevamente',
                  style: GoogleFonts.inter(
                    color: mutedColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadSummary,
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

    return RefreshIndicator(
      onRefresh: _loadSummary,
      color: accentColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen del mes
            _buildMonthSummary(_summary!, textColor, mutedColor, cardColor, borderColor, accentColor),
            const SizedBox(height: 24),

            // Resumen total
            _buildTotalSummary(_summary!, textColor, mutedColor, cardColor, borderColor, accentColor),
            const SizedBox(height: 24),

            // Accesos rápidos
            _buildQuickAccess(textColor, mutedColor, cardColor, borderColor, accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSummary(
    FinanceSummaryDto summary,
    Color textColor,
    Color mutedColor,
    Color cardColor,
    Color borderColor,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Iconsax.calendar, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Este Mes',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _FinanceStatItem(
                  label: 'Ingresos',
                  value: MoneyFormatter.formatCordobas(summary.incomeThisMonth),
                  icon: Iconsax.arrow_down,
                  color: const Color(0xFF22C55E),
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
              ),
              Container(width: 1, height: 60, color: borderColor),
              Expanded(
                child: _FinanceStatItem(
                  label: 'Egresos',
                  value: MoneyFormatter.formatCordobas(summary.expensesThisMonth),
                  icon: Iconsax.arrow_up,
                  color: const Color(0xFFEF4444),
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
              ),
              Container(width: 1, height: 60, color: borderColor),
              Expanded(
                child: _FinanceStatItem(
                  label: 'Ganancia',
                  value: MoneyFormatter.formatCordobas(summary.profitThisMonth),
                  icon: Iconsax.wallet,
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

  Widget _buildTotalSummary(
    FinanceSummaryDto summary,
    Color textColor,
    Color mutedColor,
    Color cardColor,
    Color borderColor,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Iconsax.chart, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Resumen Total',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SummaryRow(
            label: 'Ingresos Totales',
            value: MoneyFormatter.formatCordobas(summary.totalIncome),
            color: const Color(0xFF22C55E),
            textColor: textColor,
            mutedColor: mutedColor,
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Egresos Totales',
            value: MoneyFormatter.formatCordobas(summary.totalExpenses),
            color: const Color(0xFFEF4444),
            textColor: textColor,
            mutedColor: mutedColor,
          ),
          const SizedBox(height: 16),
          Divider(color: borderColor),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Ganancia Neta',
            value: MoneyFormatter.formatCordobas(summary.netProfit),
            color: accentColor,
            textColor: textColor,
            mutedColor: mutedColor,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(
    Color textColor,
    Color mutedColor,
    Color cardColor,
    Color borderColor,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accesos Rápidos',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickAccessCard(
                title: 'Ingresos',
                icon: Iconsax.arrow_down,
                color: const Color(0xFF22C55E),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IncomeScreen(),
                    ),
                  );
                },
                textColor: textColor,
                mutedColor: mutedColor,
                cardColor: cardColor,
                borderColor: borderColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAccessCard(
                title: 'Egresos',
                icon: Iconsax.arrow_up,
                color: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExpensesScreen(),
                    ),
                  );
                },
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

class _QuickAccessCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;

  const _QuickAccessCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinanceStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color textColor;
  final Color mutedColor;

  const _FinanceStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: mutedColor,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color textColor;
  final Color mutedColor;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
    required this.mutedColor,
    this.isBold = false,
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
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../utils/money_formatter.dart';
import '../../services/api/barber_service.dart';
import 'widgets/profile_ios_section.dart' show IosGroupedCard;

class QuickStatsScreen extends ConsumerStatefulWidget {
  const QuickStatsScreen({super.key});

  @override
  ConsumerState<QuickStatsScreen> createState() => _QuickStatsScreenState();
}

class _QuickStatsScreenState extends ConsumerState<QuickStatsScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(barberServiceProvider);
      final dashboard = await service.getDashboard();
      
      final monthStats = dashboard.thisMonth;
      final weekStats = dashboard.thisWeek;
      
      if (mounted) {
        setState(() {
          _stats = {
            'appointmentsThisMonth': monthStats.appointments,
            'incomeThisMonth': monthStats.income,
            'clientsServed': monthStats.uniqueClients,
            'averagePerClient': monthStats.averagePerClient,
            'completedAppointments': dashboard.today.completed,
            'cancelledAppointments': dashboard.today.pending,
            'weekAppointments': weekStats.appointments,
            'weekIncome': weekStats.income,
            'weekClients': weekStats.uniqueClients,
            'weekAverage': weekStats.averagePerClient,
          };
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      String message = 'Error al cargar las estadísticas';
      
      if (statusCode == 404) {
        message = 'Endpoint no encontrado. Verifica la configuración del servidor.';
      } else if (e.response?.data is Map) {
        message = e.response?.data['message'] ?? message;
      }
      
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8);
    final groupedBg = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final sectionHeaderColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D72);
    const accentColor = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: groupedBg,
      appBar: AppBar(
        title: Text(
          'Estadísticas rápidas',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        backgroundColor: groupedBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accentColor))
          : _stats == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.info_circle, color: mutedColor, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No se pudieron cargar las estadísticas',
                          style: GoogleFonts.inter(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: GoogleFonts.inter(
                              color: mutedColor,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadStats,
                          icon: const Icon(Iconsax.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  color: accentColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: Text(
                            'Resumen del mes en curso',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: mutedColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 16, bottom: 6, top: 20),
                          child: Text(
                            'MES ACTUAL',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              color: sectionHeaderColor,
                            ),
                          ),
                        ),

                        // Estadísticas principales
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Iconsax.calendar_2,
                                  label: 'Citas del Mes',
                                  value: _stats!['appointmentsThisMonth'].toString(),
                                  color: accentColor,
                                  textColor: textColor,
                                  mutedColor: mutedColor,
                                  cardColor: cardColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: Iconsax.wallet_money,
                                  label: 'Ingresos',
                                  value: MoneyFormatter.formatCordobas(_stats!['incomeThisMonth']),
                                  color: const Color(0xFF3B82F6),
                                  textColor: textColor,
                                  mutedColor: mutedColor,
                                  cardColor: cardColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Iconsax.profile_2user,
                                  label: 'Clientes Atendidos',
                                  value: _stats!['clientsServed'].toString(),
                                  color: const Color(0xFF8B5CF6),
                                  textColor: textColor,
                                  mutedColor: mutedColor,
                                  cardColor: cardColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: Iconsax.chart,
                                  label: 'Promedio por Cliente',
                                  value: MoneyFormatter.formatCordobas(_stats!['averagePerClient']),
                                  color: const Color(0xFFF59E0B),
                                  textColor: textColor,
                                  mutedColor: mutedColor,
                                  cardColor: cardColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 16, bottom: 6, top: 24),
                          child: Text(
                            'CITAS HOY',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              color: sectionHeaderColor,
                            ),
                          ),
                        ),
                        IosGroupedCard(
                          cardColor: cardColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                                child: _StatRow(
                                  icon: Iconsax.tick_circle,
                                  label: 'Completadas',
                                  value: _stats!['completedAppointments'].toString(),
                                  color: accentColor,
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
                                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                                child: _StatRow(
                                  icon: Iconsax.close_circle,
                                  label: 'Canceladas',
                                  value: _stats!['cancelledAppointments'].toString(),
                                  color: const Color(0xFFEF4444),
                                  textColor: textColor,
                                  mutedColor: mutedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color textColor;
  final Color mutedColor;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textColor,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}


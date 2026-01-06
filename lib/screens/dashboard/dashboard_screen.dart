import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../models/dashboard_barber.dart';
import '../../services/api/barber_service.dart';
import '../../utils/money_formatter.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends ConsumerState<DashboardScreen> {

  BarberDashboardDto? _dashboard;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _lastRefresh;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> refresh() async {
    // Evitar refrescar si ya se está cargando o si se refrescó hace menos de 2 segundos
    if (_isLoading) return;
    final now = DateTime.now();
    if (_lastRefresh != null && now.difference(_lastRefresh!).inSeconds < 2) {
      print('⏭️ [Dashboard] Refresco omitido (muy reciente)');
      return;
    }
    _lastRefresh = now;
    await _loadDashboard();
  }
  
  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      print('🔵 [Dashboard] Cargando dashboard...');
      final service = ref.read(barberServiceProvider);
      final dashboard = await service.getDashboard();
      print('✅ [Dashboard] Dashboard cargado exitosamente');
      print('📊 [Dashboard] Datos: ${dashboard.barber.name}, Hoy: ${dashboard.today.appointments} citas');
      if (mounted) {
        setState(() {
          _dashboard = dashboard;
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
      
      print('❌ [Dashboard] Error HTTP: $statusCode');
      print('📋 [Dashboard] Error data: $errorData');
      print('📋 [Dashboard] Error message: $message');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = statusCode != null ? 'Error $statusCode: $message' : message;
        });
      }
    } catch (e, stackTrace) {
      print('❌ [Dashboard] Error al cargar: $e');
      print('📋 [Dashboard] StackTrace: $stackTrace');
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
      return Center(
        child: CircularProgressIndicator(color: accentColor),
      );
    }

    if (_dashboard == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.info_circle, color: mutedColor, size: 64),
              const SizedBox(height: 16),
              Text(
                'No se pudo cargar el dashboard',
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
                  'Verifica tu conexión a internet e intenta nuevamente',
                  style: GoogleFonts.inter(
                    color: mutedColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadDashboard,
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
      onRefresh: _loadDashboard,
      color: accentColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo
            _buildGreeting(textColor, mutedColor),
            const SizedBox(height: 24),

            // Estadísticas de hoy
            _buildTodayStats(_dashboard!.today, textColor, mutedColor, cardColor, borderColor, accentColor),
            const SizedBox(height: 24),

            // Resumen semanal y mensual
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Esta Semana',
                    _dashboard!.thisWeek.appointments.toString(),
                    MoneyFormatter.formatCordobas(_dashboard!.thisWeek.income),
                    Iconsax.calendar_2,
                    accentColor,
                    textColor,
                    mutedColor,
                    cardColor,
                    borderColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Este Mes',
                    _dashboard!.thisMonth.appointments.toString(),
                    MoneyFormatter.formatCordobas(_dashboard!.thisMonth.income),
                    Iconsax.chart,
                    accentColor,
                    textColor,
                    mutedColor,
                    cardColor,
                    borderColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Próximas citas (excluir completadas y canceladas)
            ..._buildActiveAppointments(textColor, mutedColor, cardColor, borderColor, accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(Color textColor, Color mutedColor) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Buenos días';
    } else if (hour < 18) {
      greeting = 'Buenas tardes';
    } else {
      greeting = 'Buenas noches';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _dashboard?.barber.name ?? 'Barbero',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: mutedColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayStats(
    TodayStats stats,
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
                'Hoy',
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
                child: _StatItem(
                  label: 'Citas',
                  value: stats.appointments.toString(),
                  icon: Iconsax.calendar_2,
                  color: accentColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
              ),
              Container(width: 1, height: 50, color: borderColor),
              Expanded(
                child: _StatItem(
                  label: 'Completadas',
                  value: stats.completed.toString(),
                  icon: Iconsax.tick_circle,
                  color: const Color(0xFF22C55E),
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
              ),
              Container(width: 1, height: 50, color: borderColor),
              Expanded(
                child: _StatItem(
                  label: 'Ingresos',
                  value: MoneyFormatter.formatCordobas(stats.income),
                  icon: Iconsax.wallet,
                  color: const Color(0xFFF59E0B),
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

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color accentColor,
    Color textColor,
    Color mutedColor,
    Color cardColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
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
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: mutedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: mutedColor,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActiveAppointments(
    Color textColor,
    Color mutedColor,
    Color cardColor,
    Color borderColor,
    Color accentColor,
  ) {
    final activeAppointments = _dashboard!.upcomingAppointments
        .where((apt) => apt.status != 'Completed' && apt.status != 'Cancelled')
        .take(3)
        .toList();
    
    if (activeAppointments.isEmpty) {
      return [];
    }
    
    return [
      _buildSectionTitle('Próximas Citas', textColor),
      const SizedBox(height: 12),
      ...activeAppointments.map((apt) => _buildAppointmentCard(
            apt,
            textColor,
            mutedColor,
            cardColor,
            borderColor,
            accentColor,
          )),
    ];
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  Widget _buildAppointmentCard(
    appointment,
    Color textColor,
    Color mutedColor,
    Color cardColor,
    Color borderColor,
    Color accentColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Iconsax.calendar, color: accentColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.clientName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appointment.serviceName} - ${appointment.time}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: mutedColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(appointment.status).withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getStatusText(appointment.status),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(appointment.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFF10B981);
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Cancelled':
        return const Color(0xFFEF4444);
      case 'Completed':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Confirmed':
        return 'Confirmada';
      case 'Pending':
        return 'Pendiente';
      case 'Cancelled':
        return 'Cancelada';
      case 'Completed':
        return 'Completada';
      default:
        return status;
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color textColor;
  final Color mutedColor;

  const _StatItem({
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
            fontSize: 16,
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


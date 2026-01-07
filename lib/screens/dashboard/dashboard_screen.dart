import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../models/dashboard_barber.dart';
import '../../services/api/barber_service.dart';
import '../../utils/money_formatter.dart';
import '../../utils/role_helper.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToAppointments;
  
  const DashboardScreen({
    super.key,
    this.onNavigateToAppointments,
  });

  @override
  ConsumerState<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends ConsumerState<DashboardScreen> {
  BarberDashboardDto? _dashboard;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _lastRefresh;
  final Set<int> _dismissedAppointmentIds = {}; // IDs de citas ocultas

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> refresh() async {
    if (_isLoading) return;
    final now = DateTime.now();
    if (_lastRefresh != null && now.difference(_lastRefresh!).inSeconds < 2) {
      return;
    }
    _lastRefresh = now;
    await _loadDashboard();
  }
  
  Future<void> _loadDashboard() async {
    // Si es Employee, no cargar dashboard (no disponible)
    if (RoleHelper.isEmployee(ref)) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = null;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final service = ref.read(barberServiceProvider);
      final dashboard = await service.getDashboard();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
    final cardColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
    final bgColor = isDark ? const Color(0xFF0A0A0B) : const Color(0xFFF9FAFB);
    const accentColor = Color(0xFF10B981);

    // Si es Employee, mostrar mensaje de que el dashboard no está disponible
    if (RoleHelper.isEmployee(ref)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.chart_2, color: mutedColor, size: 64),
              const SizedBox(height: 16),
              Text(
                'Dashboard no disponible',
                style: GoogleFonts.inter(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Los trabajadores no tienen acceso al dashboard. Usa las secciones de Citas y Finanzas para gestionar tu trabajo.',
                style: GoogleFonts.inter(
                  color: mutedColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: accentColor));
    }

    if (_dashboard == null) {
      return _ErrorState(
        errorMessage: _errorMessage,
        onRetry: _loadDashboard,
        textColor: textColor,
        mutedColor: mutedColor,
        accentColor: accentColor,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      color: accentColor,
      child: Container(
        color: bgColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header compacto
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: _buildHeader(textColor, mutedColor),
              ),
            ),

            // Stats rápidas horizontales
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildQuickStats(textColor, mutedColor, cardColor, borderColor, accentColor),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Cards de resumen
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSummaryCards(textColor, mutedColor, cardColor, borderColor, accentColor),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Próximas citas (solo mostrar si hay citas activas)
            if (_dashboard!.upcomingAppointments
                .where((apt) => 
                    apt.status != 'Completed' && 
                    apt.status != 'Cancelled' &&
                    !_dismissedAppointmentIds.contains(apt.id))
                .isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: _buildUpcomingAppointments(textColor, mutedColor, cardColor, borderColor, accentColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color mutedColor) {
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
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _dashboard?.barber.name ?? 'Barbero',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: mutedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(
    Color textColor,
    Color mutedColor,
    Color cardColor,
    Color borderColor,
    Color accentColor,
  ) {
    final today = _dashboard!.today;
    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            icon: Iconsax.calendar_2,
            value: today.appointments.toString(),
            label: 'Citas hoy',
            color: accentColor,
            textColor: textColor,
            mutedColor: mutedColor,
            cardColor: cardColor,
            borderColor: borderColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickStatCard(
            icon: Iconsax.wallet_3,
            value: MoneyFormatter.formatCordobas(today.income),
            label: 'Ingresos',
            color: const Color(0xFF22C55E),
            textColor: textColor,
            mutedColor: mutedColor,
            cardColor: cardColor,
            borderColor: borderColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(
    Color textColor,
    Color mutedColor,
    Color cardColor,
    Color borderColor,
    Color accentColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Semana',
            appointments: _dashboard!.thisWeek.appointments.toString(),
            income: MoneyFormatter.formatCordobas(_dashboard!.thisWeek.income),
            gradient: [accentColor, accentColor.withOpacity(0.7)],
            textColor: textColor,
            mutedColor: mutedColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            title: 'Mes',
            appointments: _dashboard!.thisMonth.appointments.toString(),
            income: MoneyFormatter.formatCordobas(_dashboard!.thisMonth.income),
            gradient: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
            textColor: textColor,
            mutedColor: mutedColor,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointments(
    Color textColor,
    Color mutedColor,
    Color cardColor,
    Color borderColor,
    Color accentColor,
  ) {
    final activeAppointments = _dashboard!.upcomingAppointments
        .where((apt) => 
            apt.status != 'Completed' && 
            apt.status != 'Cancelled' &&
            !_dismissedAppointmentIds.contains(apt.id))
        .take(3)
        .toList();

    // Si no hay citas activas, no mostrar nada (ni título ni botón)
    if (activeAppointments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Próximas Citas',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            // Botón "Ver todas" - solo visible cuando hay citas
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onNavigateToAppointments,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver todas',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Iconsax.arrow_right_3,
                        size: 14,
                        color: accentColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...activeAppointments.map((apt) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DismissibleAppointmentCard(
                appointment: apt,
                textColor: textColor,
                mutedColor: mutedColor,
                cardColor: cardColor,
                borderColor: borderColor,
                accentColor: accentColor,
                onDismissed: () {
                  setState(() {
                    _dismissedAppointmentIds.add(apt.id);
                  });
                },
              ),
            )),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;

  const _QuickStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: mutedColor,
                    fontWeight: FontWeight.w500,
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String appointments;
  final String income;
  final List<Color> gradient;
  final Color textColor;
  final Color mutedColor;

  const _SummaryCard({
    required this.title,
    required this.appointments,
    required this.income,
    required this.gradient,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            appointments,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'citas',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              income,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DismissibleAppointmentCard extends StatelessWidget {
  final appointment;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;
  final VoidCallback onDismissed;

  const _DismissibleAppointmentCard({
    required this.appointment,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('appointment_${appointment.id}'),
      direction: DismissDirection.endToStart, // Solo deslizar de derecha a izquierda
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Iconsax.trash,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Quitar',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        onDismissed();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cita oculta del inicio',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: _AppointmentMiniCard(
        appointment: appointment,
        textColor: textColor,
        mutedColor: mutedColor,
        cardColor: cardColor,
        borderColor: borderColor,
        accentColor: accentColor,
      ),
    );
  }
}

class _AppointmentMiniCard extends StatelessWidget {
  final appointment;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;

  const _AppointmentMiniCard({
    required this.appointment,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFF10B981);
      case 'Pending':
        return const Color(0xFFF59E0B);
      default:
        return mutedColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(appointment.status),
              borderRadius: BorderRadius.circular(2),
            ),
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
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Iconsax.clock, size: 11, color: mutedColor),
                    const SizedBox(width: 4),
                    Text(
                      appointment.time,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: mutedColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (appointment.services.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withAlpha(15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${appointment.services.length} servicio${appointment.services.length > 1 ? 's' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(appointment.status),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

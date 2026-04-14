import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:dio/dio.dart';
import '../../models/dashboard_barber.dart';
import '../../services/api/barber_service.dart';
import '../../utils/role_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_refresh_provider.dart';
import 'widgets/dashboard_cards.dart';
import 'widgets/dashboard_sections.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({
    super.key,
    this.onNavigateToAppointments,
    this.onNavigateToServices,
    this.onNavigateToFinances,
  });

  final VoidCallback? onNavigateToAppointments;
  final VoidCallback? onNavigateToServices;
  final VoidCallback? onNavigateToFinances;

  @override
  ConsumerState<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends ConsumerState<DashboardScreen> {
  BarberDashboardDto? _dashboard;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _lastRefresh;
  final Set<int> _dismissedAppointmentIds = {};

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
      await ref.read(authNotifierProvider.notifier).refreshSubscription();
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
    final bgColor = isDark ? const Color(0xFF0A0A0B) : Colors.white;
    const accentColor = Color(0xFF10B981);

    ref.listen<int>(dashboardRefreshProvider, (previous, next) {
      if (next > 0 && mounted && !_isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            refresh();
          }
        });
      }
    });

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
      return DashboardLoadErrorState(
        errorMessage: _errorMessage,
        onRetry: _loadDashboard,
        textColor: textColor,
        mutedColor: mutedColor,
        accentColor: accentColor,
      );
    }

    final d = _dashboard!;

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      color: accentColor,
      child: Container(
        color: bgColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DashboardTodayQuickStat(
                  dashboard: d,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  accentColor: accentColor,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DashboardSummaryGrid(
                  dashboard: d,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DashboardAdditionalStatsCard(
                  dashboard: d,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  accentColor: accentColor,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (d.upcomingAppointments.where((apt) =>
                    apt.status != 'Completed' &&
                    apt.status != 'Cancelled' &&
                    !_dismissedAppointmentIds.contains(apt.id))
                .isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: DashboardUpcomingAppointmentsSection(
                    dashboard: d,
                    dismissedAppointmentIds: _dismissedAppointmentIds,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    accentColor: accentColor,
                    onNavigateToAppointments: widget.onNavigateToAppointments,
                    onDismissAppointment: (id) {
                      setState(() {
                        _dismissedAppointmentIds.add(id);
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

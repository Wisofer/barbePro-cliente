import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../models/appointment.dart';
import '../../services/api/appointment_service.dart';
import 'create_appointment_screen.dart';
import 'appointment_detail_screen.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  List<AppointmentDto> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedTab = 0; // 0 = Hoy, 1 = Pendientes

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      print('🔵 [Appointments] Cargando citas...');
      final service = ref.read(appointmentServiceProvider);
      
      // Configurar filtros según el tab seleccionado
      String? date;
      String? status;
      
      if (_selectedTab == 0) {
        // Tab "Hoy" - mostrar citas de hoy
        final today = DateTime.now();
        date = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      } else if (_selectedTab == 1) {
        // Tab "Pendientes" - mostrar solo pendientes
        status = 'Pending';
      }
      
      final appointments = await service.getAppointments(
        date: date,
        status: status,
      );
      print('✅ [Appointments] Citas cargadas: ${appointments.length}');
      if (mounted) {
        setState(() {
          _appointments = appointments;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      
      // Si es 404, el servicio ya retornó lista vacía, así que no deberíamos llegar aquí
      // Pero por si acaso, manejamos el caso
      if (statusCode == 404) {
        print('⚠️ [Appointments] 404 - No hay citas disponibles');
        if (mounted) {
          setState(() {
            _appointments = [];
            _isLoading = false;
            _errorMessage = null;
          });
        }
        return;
      }
      
      String message;
      if (errorData is Map<String, dynamic>) {
        message = errorData['message'] ?? e.message ?? 'Error desconocido';
      } else if (errorData is String) {
        message = errorData;
      } else {
        message = e.message ?? 'Error desconocido';
      }
      
      print('❌ [Appointments] Error HTTP: $statusCode');
      print('📋 [Appointments] Error data: $errorData');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = statusCode != null ? 'Error $statusCode: $message' : message;
        });
      }
    } catch (e, stackTrace) {
      print('❌ [Appointments] Error al cargar: $e');
      print('📋 [Appointments] StackTrace: $stackTrace');
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
    final bgColor = isDark ? const Color(0xFF0A0A0B) : const Color(0xFFF0FDF4);
    const accentColor = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header limpio
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Citas',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedTab == 0 ? 'Citas de hoy' : 'Citas pendientes',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: mutedColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateAppointmentScreen(),
                          ),
                        );
                        if (result == true) {
                          _loadAppointments();
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: accentColor.withAlpha(15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Iconsax.add,
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs estilo línea inferior
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _LineTabBar(
                selectedIndex: _selectedTab,
                onTabSelected: (index) {
                  setState(() => _selectedTab = index);
                  _loadAppointments();
                },
                tabs: const ['Hoy', 'Pendientes'],
                accentColor: accentColor,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
            ),
            const SizedBox(height: 12),

            // Lista de citas
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: accentColor))
                  : _errorMessage != null
                      ? _ErrorState(
                          errorMessage: _errorMessage!,
                          onRetry: _loadAppointments,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          accentColor: accentColor,
                        )
                      : _appointments.isEmpty
                          ? _EmptyState(
                              selectedTab: _selectedTab,
                              onAddAppointment: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CreateAppointmentScreen(),
                                  ),
                                );
                                if (result == true) {
                                  _loadAppointments();
                                }
                              },
                              textColor: textColor,
                              mutedColor: mutedColor,
                              accentColor: accentColor,
                            )
                          : RefreshIndicator(
                              onRefresh: _loadAppointments,
                              color: accentColor,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _appointments.length,
                                itemBuilder: (context, index) {
                                  final apt = _appointments[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _AppointmentCard(
                                      appointment: apt,
                                      textColor: textColor,
                                      mutedColor: mutedColor,
                                      cardColor: cardColor,
                                      borderColor: borderColor,
                                      accentColor: accentColor,
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AppointmentDetailScreen(
                                              appointment: apt,
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          _loadAppointments();
                                        }
                                      },
                                    ),
                                  );
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

class _LineTabBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final List<String> tabs;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;

  const _LineTabBar({
    required this.selectedIndex,
    required this.onTabSelected,
    required this.tabs,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  State<_LineTabBar> createState() => _LineTabBarState();
}

class _LineTabBarState extends State<_LineTabBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_LineTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: widget.tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final isSelected = index == widget.selectedIndex;
            
            return Expanded(
              child: GestureDetector(
                onTap: () => widget.onTabSelected(index),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? widget.textColor : widget.mutedColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        height: 1.5,
                        decoration: BoxDecoration(
                          color: isSelected ? widget.accentColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int selectedTab;
  final VoidCallback onAddAppointment;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;

  const _EmptyState({
    required this.selectedTab,
    required this.onAddAppointment,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: mutedColor.withAlpha(10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.calendar_remove,
                  color: mutedColor,
                  size: 56,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No hay citas',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                selectedTab == 0
                    ? 'No tienes citas programadas para hoy'
                    : 'No tienes citas pendientes',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: mutedColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAddAppointment,
                icon: const Icon(Iconsax.add, size: 18),
                label: const Text('Agregar Cita'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String errorMessage;
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
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.warning_2, color: const Color(0xFFEF4444), size: 56),
              const SizedBox(height: 20),
              Text(
                'Error al cargar',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                errorMessage,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: mutedColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Iconsax.refresh, size: 18),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentDto appointment;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;
  final VoidCallback onTap;

  const _AppointmentCard({
    required this.appointment,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
    required this.onTap,
  });

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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Confirmed':
        return Iconsax.tick_circle;
      case 'Pending':
        return Iconsax.clock;
      case 'Cancelled':
        return Iconsax.close_circle;
      case 'Completed':
        return Iconsax.tick_square;
      default:
        return Iconsax.info_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(appointment.status);
    final dateTime = appointment.dateTime;
    final isToday = dateTime.year == DateTime.now().year &&
        dateTime.month == DateTime.now().month &&
        dateTime.day == DateTime.now().day;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accentColor,
                          accentColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Iconsax.calendar_2,
                      color: Colors.white,
                      size: 20,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Mostrar todos los servicios o el primero si no hay lista
                        if (appointment.services.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: appointment.services.take(3).map((service) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: accentColor.withAlpha(15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  service.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: accentColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList()
                              ..addAll(
                                appointment.services.length > 3
                                    ? [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: mutedColor.withAlpha(15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '+${appointment.services.length - 3}',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: mutedColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ]
                                    : [],
                              ),
                          )
                        else if (appointment.serviceName != null && appointment.serviceName!.isNotEmpty)
                          Row(
                            children: [
                              Icon(Iconsax.scissor, size: 12, color: mutedColor),
                              const SizedBox(width: 5),
                              Expanded(
                              child: Text(
                                appointment.serviceName ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: mutedColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            'Sin servicio',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: mutedColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(appointment.status),
                          size: 12,
                          color: statusColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _getStatusText(appointment.status),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Iconsax.clock,
                        color: accentColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isToday ? 'Hoy' : _formatDate(appointment.date),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appointment.time,
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
                        color: accentColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.dollar_circle, size: 14, color: accentColor),
                          const SizedBox(width: 4),
                          Text(
                            'C\$${_getTotalPrice(appointment).toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                        ],
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

  double _getTotalPrice(AppointmentDto appointment) {
    if (appointment.services.isNotEmpty) {
      return appointment.services.fold<double>(0.0, (sum, service) => sum + service.price);
    }
    return appointment.servicePrice ?? 0.0;
  }

  String _formatDate(String date) {
    final parts = date.split('-');
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${parts[2]} ${months[int.parse(parts[1]) - 1]}';
  }
}

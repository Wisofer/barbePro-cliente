import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/appointment.dart';
import '../../services/api/appointment_service.dart';
import '../../services/api/employee_appointment_service.dart';
import '../../utils/role_helper.dart';
import 'appointment_detail_screen.dart';
import 'widgets/appointment_error_state.dart';
import 'widgets/appointment_list_card.dart';

class AppointmentHistoryScreen extends ConsumerStatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  ConsumerState<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState
    extends ConsumerState<AppointmentHistoryScreen> {
  List<AppointmentDto> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<AppointmentDto> appointments;
      if (RoleHelper.isEmployee(ref)) {
        final service = ref.read(employeeAppointmentServiceProvider);
        appointments = await service.getHistory();
      } else {
        final service = ref.read(appointmentServiceProvider);
        appointments = await service.getHistory();
      }

      appointments.sort((a, b) {
        final dateA = DateTime.parse('${a.date} ${a.time}');
        final dateB = DateTime.parse('${b.date} ${b.time}');
        return dateB.compareTo(dateA);
      });

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

      String message;
      if (errorData is Map<String, dynamic>) {
        message = errorData['message'] ?? e.message ?? 'Error desconocido';
      } else if (errorData is String) {
        message = errorData;
      } else {
        message = e.message ?? 'Error desconocido';
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              statusCode != null ? 'Error $statusCode: $message' : message;
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Historial de Citas',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : _errorMessage != null
              ? AppointmentListErrorState(
                  errorMessage: _errorMessage!,
                  onRetry: _loadHistory,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  accentColor: accentColor,
                )
              : _appointments.isEmpty
                  ? _AppointmentHistoryEmptyState(
                      textColor: textColor,
                      mutedColor: mutedColor,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      color: accentColor,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: _appointments.length,
                        itemBuilder: (context, index) {
                          final apt = _appointments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppointmentListCard(
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
                                  _loadHistory();
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _AppointmentHistoryEmptyState extends StatelessWidget {
  const _AppointmentHistoryEmptyState({
    required this.textColor,
    required this.mutedColor,
  });

  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.document_text,
              color: mutedColor,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              'No hay historial',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no tienes citas en el historial',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: mutedColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

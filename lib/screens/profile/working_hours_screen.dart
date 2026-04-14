import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../models/barber.dart';
import '../../services/api/barber_service.dart';
import 'widgets/profile_ios_section.dart' show IosGroupedCard;

class WorkingHoursScreen extends ConsumerStatefulWidget {
  const WorkingHoursScreen({super.key});

  @override
  ConsumerState<WorkingHoursScreen> createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends ConsumerState<WorkingHoursScreen> {
  Map<int, _DaySchedule> _schedules = {};
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  static const List<int> _weekDayOrder = [1, 2, 3, 4, 5, 6, 0];

  // Mapeo de días de la semana
  final Map<int, String> _dayNames = {
    0: 'Domingo',
    1: 'Lunes',
    2: 'Martes',
    3: 'Miércoles',
    4: 'Jueves',
    5: 'Viernes',
    6: 'Sábado',
  };

  @override
  void initState() {
    super.initState();
    _loadWorkingHours();
  }

  Future<void> _loadWorkingHours() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(barberServiceProvider);
      final workingHours = await service.getWorkingHours();

      // Inicializar todos los días (0-6)
      final schedules = <int, _DaySchedule>{};
      for (int day = 0; day < 7; day++) {
        final existing = workingHours.firstWhere(
          (wh) => wh.dayOfWeek == day,
          orElse: () => WorkingHoursDto(
            id: 0,
            dayOfWeek: day,
            startTime: '09:00',
            endTime: '18:00',
            isActive: false,
          ),
        );
        schedules[day] = _DaySchedule(
          id: existing.id,
          day: _dayNames[day]!,
          dayOfWeek: day,
          isActive: existing.isActive,
          startTime: existing.startTime,
          endTime: existing.endTime,
        );
      }

      if (mounted) {
        setState(() {
          _schedules = schedules;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      String message = 'Error al cargar los horarios';
      
      if (statusCode == 404) {
        // Si no hay horarios, inicializar con valores por defecto
        final schedules = <int, _DaySchedule>{};
        for (int day = 0; day < 7; day++) {
          schedules[day] = _DaySchedule(
            id: 0,
            day: _dayNames[day]!,
            dayOfWeek: day,
            isActive: day != 0 && day != 6, // Lunes a Viernes activos por defecto
            startTime: '09:00',
            endTime: '18:00',
          );
        }
        if (mounted) {
          setState(() {
            _schedules = schedules;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Error $statusCode: ${e.response?.data?['message'] ?? message}';
          });
        }
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

  Future<void> _saveWorkingHours() async {
    setState(() => _isSaving = true);

    try {
      final service = ref.read(barberServiceProvider);
      
      // Preparar datos para enviar
      final workingHours = _schedules.values.map((schedule) => {
        'dayOfWeek': schedule.dayOfWeek,
        'startTime': schedule.startTime,
        'endTime': schedule.endTime,
        'isActive': schedule.isActive,
      }).toList().cast<Map<String, dynamic>>();

      await service.updateWorkingHours(workingHours);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horarios guardados correctamente'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      String message = 'Error al guardar los horarios';
      final statusCode = e.response?.statusCode;
      
      if (e.response?.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          message = e.response!.data['message'] ?? message;
        } else if (e.response!.data is String) {
          message = e.response!.data as String;
        }
      }
      
      if (statusCode == 404) {
        message = 'Endpoint no encontrado. Verifica la configuración del servidor.';
      } else if (statusCode == 400) {
        message = 'Datos inválidos. Verifica los horarios ingresados.';
      }
      
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildDayRow(
    int day,
    Color textColor,
    Color mutedColor,
    Color accentColor,
  ) {
    final schedule = _schedules[day];
    if (schedule == null) return const SizedBox.shrink();
    return _DayScheduleCard(
      schedule: schedule,
      onToggle: (value) {
        setState(() {
          _schedules[day] = schedule.copyWith(isActive: value);
        });
      },
      onStartTimeChanged: (time) {
        setState(() {
          _schedules[day] = schedule.copyWith(startTime: time);
        });
      },
      onEndTimeChanged: (time) {
        setState(() {
          _schedules[day] = schedule.copyWith(endTime: time);
        });
      },
      textColor: textColor,
      mutedColor: mutedColor,
      accentColor: accentColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8);
    final groupedBg = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final sectionHeaderColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D72);
    const accentColor = Color(0xFF10B981);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Horarios',
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
        backgroundColor: groupedBg,
        body: const Center(child: CircularProgressIndicator(color: accentColor)),
      );
    }

    return Scaffold(
      backgroundColor: groupedBg,
      appBar: AppBar(
        title: Text(
          'Horarios',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        backgroundColor: groupedBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveWorkingHours,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  )
                : Text(
                    'Guardar',
                    style: GoogleFonts.inter(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: _errorMessage != null && _schedules.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.info_circle, color: mutedColor, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar horarios',
                      style: GoogleFonts.inter(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: GoogleFonts.inter(
                        color: mutedColor,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadWorkingHours,
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
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Text(
                      'Activa cada día y define el rango en el que aceptas citas.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: mutedColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 16, bottom: 6, top: 8),
                    child: Text(
                      'SEMANA',
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
                      children: [
                        for (int i = 0; i < _weekDayOrder.length; i++) ...[
                          _buildDayRow(
                            _weekDayOrder[i],
                            textColor,
                            mutedColor,
                            accentColor,
                          ),
                          if (i < _weekDayOrder.length - 1)
                            Divider(
                              height: 1,
                              thickness: 0.5,
                              indent: 16,
                              endIndent: 16,
                              color: borderColor.withValues(alpha: 0.75),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DaySchedule {
  final int id;
  final String day;
  final int dayOfWeek;
  final bool isActive;
  final String startTime;
  final String endTime;

  _DaySchedule({
    required this.id,
    required this.day,
    required this.dayOfWeek,
    required this.isActive,
    required this.startTime,
    required this.endTime,
  });

  _DaySchedule copyWith({
    int? id,
    String? day,
    int? dayOfWeek,
    bool? isActive,
    String? startTime,
    String? endTime,
  }) {
    return _DaySchedule(
      id: id ?? this.id,
      day: day ?? this.day,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isActive: isActive ?? this.isActive,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

class _DayScheduleCard extends StatelessWidget {
  final _DaySchedule schedule;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onStartTimeChanged;
  final ValueChanged<String> onEndTimeChanged;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;

  const _DayScheduleCard({
    required this.schedule,
    required this.onToggle,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  schedule.day,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              Switch.adaptive(
                value: schedule.isActive,
                onChanged: onToggle,
                activeThumbColor: accentColor,
                activeTrackColor: accentColor.withValues(alpha: 0.45),
              ),
            ],
          ),
          if (schedule.isActive) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _TimePicker(
                    label: 'Inicio',
                    time: schedule.startTime,
                    onTimeChanged: onStartTimeChanged,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    accentColor: accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimePicker(
                    label: 'Fin',
                    time: schedule.endTime,
                    onTimeChanged: onEndTimeChanged,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    accentColor: accentColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final String time;
  final ValueChanged<String> onTimeChanged;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;

  const _TimePicker({
    required this.label,
    required this.time,
    required this.onTimeChanged,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.parse(time.split(':')[0]),
            minute: int.parse(time.split(':')[1]),
          ),
        );
        if (picked != null) {
          final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          onTimeChanged(formatted);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accentColor.withAlpha(10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accentColor.withAlpha(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: mutedColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

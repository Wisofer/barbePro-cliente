import '../../models/appointment.dart';
import 'mock_data.dart';

/// Servicio mock de citas para modo demo
class MockAppointmentService {
  Future<List<AppointmentDto>> getAppointments({
    String? date,
    String? status,
  }) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    List<AppointmentDto> appointments;

    if (status == 'Pending') {
      appointments = MockData.mockPendingAppointments;
    } else if (date != null) {
      // Filtrar por fecha
      appointments = MockData.mockTodayAppointments
          .where((apt) => apt.date == date)
          .toList();
    } else {
      appointments = MockData.mockTodayAppointments;
    }

    return appointments;
  }

  Future<List<AppointmentDto>> getHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.mockHistoryAppointments;
  }

  Future<AppointmentDto> getAppointment(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allAppointments = MockData.mockHistoryAppointments;
    return allAppointments.firstWhere(
      (apt) => apt.id == id,
      orElse: () => MockData.mockTodayAppointments.first,
    );
  }

  Future<AppointmentDto> createAppointment({
    List<int>? serviceIds,
    required String clientName,
    required String clientPhone,
    required String date,
    required String time,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Simular creación (no se guarda realmente)
    return AppointmentDto(
      id: DateTime.now().millisecondsSinceEpoch,
      barberId: 1,
      barberName: 'Barbería Demo',
      services: MockData.mockServices
          .where((s) => serviceIds?.contains(s.id) ?? false)
          .toList(),
      clientName: clientName,
      clientPhone: clientPhone,
      date: date,
      time: time,
      status: 'Confirmed',
      createdAt: DateTime.now(),
    );
  }

  Future<AppointmentDto> updateAppointment({
    required int id,
    String? status,
    String? date,
    String? time,
    String? clientName,
    String? clientPhone,
    List<int>? serviceIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final existing = MockData.mockHistoryAppointments
        .firstWhere((apt) => apt.id == id, orElse: () => MockData.mockTodayAppointments.first);
    
    return AppointmentDto(
      id: existing.id,
      barberId: existing.barberId,
      barberName: existing.barberName,
      services: serviceIds != null
          ? MockData.mockServices.where((s) => serviceIds.contains(s.id)).toList()
          : existing.services,
      clientName: clientName ?? existing.clientName,
      clientPhone: clientPhone ?? existing.clientPhone,
      date: date ?? existing.date,
      time: time ?? existing.time,
      status: status ?? existing.status,
      createdAt: existing.createdAt,
    );
  }

  Future<void> deleteAppointment(int id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Simular eliminación (no hace nada realmente)
  }

  Future<Map<String, dynamic>> getWhatsAppUrl(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'url': 'https://wa.me/50588888888?text=Hola',
    };
  }

  Future<Map<String, dynamic>> getWhatsAppUrlReject(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final appointment = MockData.mockHistoryAppointments
        .firstWhere((apt) => apt.id == id, orElse: () => MockData.mockTodayAppointments.first);
    
    final message = 'Hola ${appointment.clientName}! 👋\n\n'
        'Lamentamos informarte que no podemos atenderte el ${appointment.date} a las ${appointment.time}. '
        '¿Te gustaría reagendar para otro horario? 📅';
    
    return {
      'url': 'https://wa.me/505${appointment.clientPhone}?text=${Uri.encodeComponent(message)}',
      'phoneNumber': '505${appointment.clientPhone}',
      'message': message,
    };
  }
}


import '../../../models/appointment.dart';

String appointmentCardShortTime(String time) {
  final parts = time.trim().split(':');
  if (parts.length >= 2) {
    final h = parts[0].padLeft(2, '0');
    final m = parts[1].padLeft(2, '0');
    return '$h:$m';
  }
  return time;
}

String appointmentCardServiceSummaryLine(AppointmentDto a) {
  if (a.services.isNotEmpty) {
    if (a.services.length == 1) {
      return a.services.first.name;
    }
    return '${a.services.length} servicios';
  }
  if (a.serviceName != null && a.serviceName!.isNotEmpty) {
    return a.serviceName!;
  }
  return 'Sin servicio';
}

double appointmentCardTotalPrice(AppointmentDto appointment) {
  if (appointment.services.isNotEmpty) {
    return appointment.services.fold<double>(0.0, (sum, service) => sum + service.price);
  }
  return appointment.servicePrice ?? 0.0;
}

String appointmentCardFormatShortDate(String date) {
  final parts = date.split('-');
  const months = [
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

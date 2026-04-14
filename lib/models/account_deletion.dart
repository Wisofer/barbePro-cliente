/// Respuesta de GET /api/account/deletion
class AccountDeletionStatusResponse {
  const AccountDeletionStatusResponse({
    required this.pending,
    this.requestedAtUtc,
    this.scheduledForUtc,
    this.gracePeriodDays,
  });

  final bool pending;
  final DateTime? requestedAtUtc;
  final DateTime? scheduledForUtc;
  final int? gracePeriodDays;

  factory AccountDeletionStatusResponse.fromJson(Map<String, dynamic> json) {
    return AccountDeletionStatusResponse(
      pending: json['pending'] == true,
      requestedAtUtc: _parseDate(json['requestedAtUtc']),
      scheduledForUtc: _parseDate(json['scheduledForUtc']),
      gracePeriodDays: _parseInt(json['gracePeriodDays']),
    );
  }
}

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

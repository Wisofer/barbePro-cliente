import 'barber.dart';

/// Estado de suscripción: Trial, Pro, Expired
class SubscriptionDto {
  final DateTime? trialEndsAt;
  final bool isProActive;
  final DateTime? proActivatedAt;
  final String status; // "Trial" | "Pro" | "Expired"
  final bool hasAccess;

  SubscriptionDto({
    this.trialEndsAt,
    required this.isProActive,
    this.proActivatedAt,
    required this.status,
    required this.hasAccess,
  });

  factory SubscriptionDto.fromJson(Map<String, dynamic> json) => SubscriptionDto(
        trialEndsAt: json['trialEndsAt'] != null
            ? DateTime.tryParse(json['trialEndsAt'].toString())
            : null,
        isProActive: json['isProActive'] == true,
        proActivatedAt: json['proActivatedAt'] != null
            ? DateTime.tryParse(json['proActivatedAt'].toString())
            : null,
        status: (json['status'] as String?) ?? 'Pro',
        hasAccess: json['hasAccess'] == true,
      );

  bool get isTrial => status == 'Trial';
  bool get isPro => status == 'Pro';
  bool get isExpired => status == 'Expired';
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String? businessName;
  final String phone;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    this.businessName,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'name': name,
        if (businessName != null && businessName!.isNotEmpty) 'businessName': businessName,
        'phone': phone,
      };
}

class LoginResponse {
  final String token;
  final String refreshToken;
  final UserDto user;
  final String role;

  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
    required this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        token: json['token'] ?? '',
        refreshToken: json['refreshToken'] ?? json['token'] ?? '', // Fallback al token si no hay refreshToken
        user: UserDto.fromJson(json['user']),
        role: json['role'],
      );
}

class UserDto {
  final int id;
  final String email;
  final String role;
  final String? authProvider; // "email" | "google.com" | "apple.com"
  final BarberDto? barber;
  final SubscriptionDto? subscription;

  UserDto({
    required this.id,
    required this.email,
    required this.role,
    this.authProvider,
    this.barber,
    this.subscription,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'],
        email: json['email'],
        role: json['role'],
        authProvider: json['authProvider'] as String?,
        barber: json['barber'] != null ? BarberDto.fromJson(json['barber']) : null,
        subscription: json['subscription'] != null
            ? SubscriptionDto.fromJson(
                Map<String, dynamic>.from(json['subscription'] as Map),
              )
            : null,
      );
}

class QrResponse {
  final String url;
  final String qrCode; // Base64 PNG

  QrResponse({
    required this.url,
    required this.qrCode,
  });

  factory QrResponse.fromJson(Map<String, dynamic> json) => QrResponse(
        url: json['url'],
        qrCode: json['qrCode'],
      );
}


import 'package:flutter/material.dart';

@immutable
class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.language = 'es',
    this.currency = 'NIO',
    this.twoFactorAuth = false,
    this.profilePublic = true,
    this.showOnlineStatus = true,
    this.allowMessages = true,
    this.isDarkMode = false,
  });

  final ThemeMode themeMode;
  final String language;
  final String currency;
  final bool twoFactorAuth;
  final bool profilePublic;
  final bool showOnlineStatus;
  final bool allowMessages;
  final bool isDarkMode;

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    String? currency,
    bool? twoFactorAuth,
    bool? profilePublic,
    bool? showOnlineStatus,
    bool? allowMessages,
    bool? isDarkMode,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      twoFactorAuth: twoFactorAuth ?? this.twoFactorAuth,
      profilePublic: profilePublic ?? this.profilePublic,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      allowMessages: allowMessages ?? this.allowMessages,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  static SettingsState initial() => const SettingsState();
}


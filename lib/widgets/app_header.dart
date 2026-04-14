import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main_theme.dart';
import '../providers/barber_profile_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/settings/settings_notifier.dart';
import '../screens/notifications/notifications_screen.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(settingsNotifierProvider).themeMode;
    final isDarkThemeSetting = themeMode == ThemeMode.dark;

    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
    const accentColor = Color(0xFF10B981);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemMovilTheme.getStatusBarStyle(isDark),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? null : Colors.white,
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: const [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                  ],
                )
              : null,
        ),
        child: SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final cachedAsync = ref.watch(barberCachedImageUrlProvider);
                    final profileAsync = ref.watch(barberProfileProvider);
                    final apiUrl = profileAsync.valueOrNull?.profileImageUrl;
                    final String? urlToShow =
                        apiUrl != null && apiUrl.isNotEmpty ? apiUrl : cachedAsync.valueOrNull;
                    final isLoading = profileAsync.isLoading && urlToShow == null;

                    late final Widget avatar;
                    if (urlToShow != null && urlToShow.isNotEmpty) {
                      avatar = _HeaderAvatarImage(url: urlToShow, accentColor: accentColor);
                    } else if (isLoading) {
                      avatar = _HeaderPlaceholder(accentColor: accentColor);
                    } else {
                      avatar = _HeaderLogoFallback(accentColor: accentColor);
                    }
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        avatar,
                        const SizedBox(width: 12),
                      ],
                    );
                  },
                ),
                
                // Título y subtítulo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'BarbeNic',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Gestión profesional',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: mutedColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tema claro / oscuro
                IconButton(
                  icon: Icon(
                    isDarkThemeSetting ? Iconsax.sun_1 : Iconsax.moon,
                    color: textColor,
                    size: 24,
                  ),
                  tooltip: isDarkThemeSetting ? 'Modo claro' : 'Modo oscuro',
                  onPressed: () {
                    ref.read(settingsNotifierProvider.notifier).setThemeMode(
                          isDarkThemeSetting ? ThemeMode.light : ThemeMode.dark,
                        );
                  },
                ),

                // Icono de notificaciones con badge
                Consumer(
                  builder: (context, ref, child) {
                    final notificationsState = ref.watch(notificationsProvider);
                    final unreadCount = notificationsState.unreadCount;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Icon(
                            Iconsax.notification,
                            color: textColor,
                            size: 24,
                          ),
                          onPressed: () {
                            // Abrir pantalla de notificaciones
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const NotificationsScreen(),
                              ),
                            );
                          },
                          tooltip: 'Notificaciones',
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: unreadCount > 99
                                  ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                                  : const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    height: 1.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderAvatarImage extends StatelessWidget {
  const _HeaderAvatarImage({required this.url, required this.accentColor});

  final String url;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Image.network(
          url,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: accentColor,
              child: Icon(Iconsax.scissor, color: Colors.white, size: 20),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderPlaceholder extends StatelessWidget {
  const _HeaderPlaceholder({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: accentColor.withAlpha(30),
      ),
      child: Icon(Iconsax.gallery, color: accentColor, size: 18),
    );
  }
}

class _HeaderLogoFallback extends StatelessWidget {
  const _HeaderLogoFallback({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Image.asset(
          'assets/images/logobarbe.png',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: accentColor,
              child: Icon(Iconsax.scissor, color: Colors.white, size: 20),
            );
          },
        ),
      ),
    );
  }
}

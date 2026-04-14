import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../models/barber.dart';
import '../../services/api/barber_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/barber_profile_provider.dart';
import '../../services/storage/barber_profile_cache.dart';
import 'edit_profile_screen.dart';
import 'qr_code_screen.dart';
import 'change_password_screen.dart';
import 'about_screen.dart';
import 'working_hours_screen.dart';
import 'quick_stats_screen.dart';
import 'help_support_screen.dart';
import 'export_data_screen.dart';
import 'settings_screen.dart';
import 'social_links_screen.dart';
import 'employees_screen.dart';
import '../../utils/role_helper.dart';
import 'profile_account_deletion.dart';
import 'profile_palette.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_ios_section.dart';
import 'widgets/profile_option.dart';
import 'widgets/profile_error_state.dart';
import '../reports/employee_reports_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  BarberDto? _profile;
  bool _isLoading = true;
  String? _errorMessage;
  bool _accountDeletionBusy = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).refreshAccountDeletionStatus();
    });
  }

  Future<void> _loadProfile() async {
    // Si es Employee, no cargar perfil del barbero (no disponible)
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
      final profile = await service.getProfile();
      if (mounted) {
        ref.invalidate(barberProfileProvider);
        ref.invalidate(barberCachedImageUrlProvider);
        setState(() {
          _profile = profile;
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

  Future<void> _exitDemoMode() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Salir del Modo Demo',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          '¿Estás seguro de que deseas salir del modo demo?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB84D),
            ),
            child: Text('Salir del Demo', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.logout();
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cerrar Sesión',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: Text('Cerrar Sesión', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.logout();
    }
  }

  Future<void> _onAccountDeletionTap() async {
    if (_accountDeletionBusy) return;

    setState(() => _accountDeletionBusy = true);
    await ref.read(authNotifierProvider.notifier).refreshAccountDeletionStatus();
    if (!mounted) return;
    setState(() => _accountDeletionBusy = false);

    final profile = ref.read(authNotifierProvider).userProfile;
    final pending = profile?.accountDeletionPending == true;
    final scheduledFor = profile?.accountDeletionScheduledForUtc;

    if (pending) {
      final wantCancel =
          await showAccountDeletionPendingDialog(context, scheduledFor: scheduledFor);
      if (wantCancel != true || !mounted) return;

      setState(() => _accountDeletionBusy = true);
      final err =
          await ref.read(authNotifierProvider.notifier).cancelAccountDeletion();
      if (!mounted) return;
      setState(() => _accountDeletionBusy = false);

      if (!mounted) return;
      showAccountDeletionSnackBar(
        context,
        errorMessage: err,
        isCancellation: true,
      );
      return;
    }

    final graceDays = profile?.accountDeletionGracePeriodDays;
    final confirm = await showAccountDeletionRequestDialog(
      context,
      gracePeriodDays: graceDays,
    );
    if (confirm != true || !mounted) return;

    setState(() => _accountDeletionBusy = true);
    final err =
        await ref.read(authNotifierProvider.notifier).requestAccountDeletion();
    if (!mounted) return;
    setState(() => _accountDeletionBusy = false);

    if (!mounted) return;
    if (err != null) {
      showAccountDeletionSnackBar(
        context,
        errorMessage: err,
        isCancellation: false,
      );
      return;
    }
    await ref.read(authNotifierProvider.notifier).logout();
  }

  static const int _maxPhotoBytes = 10 * 1024 * 1024;

  void _showProfilePhotoFullScreen(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                          color: const Color(0xFF10B981),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Iconsax.gallery_slash, size: 64, color: Colors.white54),
                      );
                    },
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Iconsax.close_circle, color: Colors.white, size: 32),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black45,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    if (!RoleHelper.isBarber(ref) || ref.read(authNotifierProvider).isDemoMode) {
      return;
    }
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Iconsax.gallery),
                title: const Text('Galería'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Iconsax.camera),
                title: const Text('Cámara'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Iconsax.close_circle),
                title: const Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;

      final bytes = await file.readAsBytes();
      if (bytes.length > _maxPhotoBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La imagen no debe superar 10 MB.'),
              backgroundColor: Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final ext = file.path.split('.').last.toLowerCase();
      if (ext != 'jpg' && ext != 'jpeg' && ext != 'png' && ext != 'gif') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usa JPG, PNG o GIF.'),
              backgroundColor: Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final b64 = base64Encode(bytes);
      final service = ref.read(barberServiceProvider);
      final updated = await service.uploadProfilePhoto(b64);
      await BarberProfileCache.saveImageUrl(updated.profileImageUrl);
      ref.invalidate(barberProfileProvider);
      ref.invalidate(barberCachedImageUrlProvider);
      if (mounted) {
        setState(() => _profile = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil actualizada'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8);
    final groupedBg = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final sectionHeaderColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D72);
    const accentColor = Color(0xFF10B981);

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: accentColor));
    }

    // Si es Employee, mostrar perfil con mismo diseño que barbero
    if (RoleHelper.isEmployee(ref)) {
      final authForDeletion = ref.watch(authNotifierProvider);
      final userProfile = authForDeletion.userProfile;
      final p = ProfilePalette.of(context);
      
      return RefreshIndicator(
        onRefresh: _loadProfile,
        color: accentColor,
        child: ColoredBox(
          color: groupedBg,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Material(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  accentColor,
                                  const Color(0xFF059669),
                                ],
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logobarbe.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Iconsax.scissor5,
                                    color: Colors.white,
                                    size: 28,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userProfile?.nombreCompleto ?? 'Trabajador',
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                if (userProfile?.email != null &&
                                    (userProfile?.email?.isNotEmpty ?? false)) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    userProfile?.email ?? '',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: mutedColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ProfileIosSection(
                  isFirst: true,
                  title: 'Cuenta',
                  headerColor: sectionHeaderColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  tiles: [
                    ProfileOption(
                      style: ProfileOptionStyle.grouped,
                      icon: Iconsax.lock,
                      title: 'Cambiar contraseña',
                      subtitle: 'Actualiza tu contraseña de acceso',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                      textColor: textColor,
                      mutedColor: mutedColor,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      accentColor: accentColor,
                    ),
                    ProfileOption(
                      style: ProfileOptionStyle.grouped,
                      icon: Iconsax.setting_2,
                      title: 'Configuración',
                      subtitle: 'Tema, notificaciones e idioma',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      textColor: textColor,
                      mutedColor: mutedColor,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      accentColor: accentColor,
                    ),
                  ],
                ),
                ProfileIosSection(
                  title: 'Ayuda',
                  headerColor: sectionHeaderColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  tiles: [
                    ProfileOption(
                      style: ProfileOptionStyle.grouped,
                      icon: Iconsax.message_question,
                      title: 'Ayuda y soporte',
                      subtitle: 'Preguntas frecuentes y contacto',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportScreen(),
                          ),
                        );
                      },
                      textColor: textColor,
                      mutedColor: mutedColor,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      accentColor: accentColor,
                    ),
                    ProfileOption(
                      style: ProfileOptionStyle.grouped,
                      icon: Iconsax.info_circle,
                      title: 'Acerca de',
                      subtitle: 'Información sobre la aplicación',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutScreen(),
                          ),
                        );
                      },
                      textColor: textColor,
                      mutedColor: mutedColor,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      accentColor: accentColor,
                    ),
                  ],
                ),
                if (RoleHelper.canRequestAccountDeletion(authForDeletion))
                  ProfileIosSection(
                    title: 'Privacidad',
                    headerColor: sectionHeaderColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    tiles: [
                      p.deleteAccountOption(
                        pending: userProfile?.accountDeletionPending == true,
                        scheduledFor: userProfile?.accountDeletionScheduledForUtc,
                        formatDate: formatProfileAccountDeletionDate,
                        onTap: _onAccountDeletionTap,
                      ),
                    ],
                  ),
                ProfileIosSection(
                  title: 'Sesión',
                  headerColor: sectionHeaderColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  tiles: [
                    ProfileOption(
                      style: ProfileOptionStyle.grouped,
                      icon: Iconsax.logout,
                      title: 'Cerrar sesión',
                      subtitle: '',
                      onTap: _logout,
                      textColor: const Color(0xFFEF4444),
                      mutedColor: const Color(0xFFEF4444),
                      cardColor: cardColor,
                      borderColor: borderColor,
                      accentColor: const Color(0xFFEF4444),
                      isDestructive: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    }

    if (_profile == null) {
      return ProfileErrorState(
        errorMessage: _errorMessage,
        onRetry: _loadProfile,
        textColor: textColor,
        mutedColor: mutedColor,
        accentColor: accentColor,
      );
    }

    final authForDeletion = ref.watch(authNotifierProvider);
    final p = ProfilePalette.of(context);

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: accentColor,
      child: ColoredBox(
        color: groupedBg,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Material(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: ProfileHeader(
                    profile: _profile!,
                    onProfileUpdated: _loadProfile,
                    onPhotoTap: RoleHelper.isBarber(ref) &&
                            !ref.watch(authNotifierProvider).isDemoMode
                        ? _pickAndUploadProfilePhoto
                        : null,
                    onPhotoViewTap: RoleHelper.isBarber(ref) &&
                            _profile!.profileImageUrl != null &&
                            _profile!.profileImageUrl!.isNotEmpty
                        ? () =>
                            _showProfilePhotoFullScreen(_profile!.profileImageUrl!)
                        : null,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    accentColor: accentColor,
                    iosGrouped: true,
                  ),
                ),
              ),

              if (ref.watch(authNotifierProvider).isDemoMode)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFB84D), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Iconsax.info_circle,
                          color: Color(0xFFFFB84D),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modo demo',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF92400E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Estás viendo datos de demostración',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ProfileIosSection(
                isFirst: true,
                title: 'Cuenta',
                headerColor: sectionHeaderColor,
                cardColor: cardColor,
                borderColor: borderColor,
                tiles: [
                  ProfileOption(
                    style: ProfileOptionStyle.grouped,
                    icon: Iconsax.profile_circle,
                    title: 'Información personal',
                    subtitle: 'Nombre, negocio, teléfono',
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(profile: _profile!),
                        ),
                      );
                      if (updated == true) {
                        _loadProfile();
                      }
                    },
                    textColor: textColor,
                    mutedColor: mutedColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    accentColor: accentColor,
                  ),
                  ProfileOption(
                    style: ProfileOptionStyle.grouped,
                    icon: Iconsax.lock,
                    title: 'Cambiar contraseña',
                    subtitle: 'Actualiza tu contraseña de acceso',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                    textColor: textColor,
                    mutedColor: mutedColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    accentColor: accentColor,
                  ),
                ],
              ),

              if (RoleHelper.isBarber(ref))
                ProfileIosSection(
                  title: 'Tu negocio',
                  headerColor: sectionHeaderColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  tiles: [
                    ProfileOption(
                      style: ProfileOptionStyle.grouped,
                      icon: Iconsax.scan_barcode,
                      title: 'Código QR',
                      subtitle: 'Comparte tu QR para citas',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QrCodeScreen(profile: _profile!),
                          ),
                        );
                      },
                      textColor: textColor,
                      mutedColor: mutedColor,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      accentColor: accentColor,
                    ),
                    ProfileOption(
                      style: ProfileOptionStyle.grouped,
                      icon: Iconsax.link,
                      title: 'URL pública',
                      subtitle: _profile!.qrUrl,
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _profile!.qrUrl));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('URL copiada al portapapeles'),
                            backgroundColor: accentColor,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      textColor: textColor,
                      mutedColor: mutedColor,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      accentColor: accentColor,
                    ),
                    ProfileOption(
                      style: ProfileOptionStyle.grouped,
                      icon: Iconsax.clock,
                      title: 'Horarios de trabajo',
                      subtitle: 'Días y horarios disponibles',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WorkingHoursScreen(),
                          ),
                        );
                      },
                      textColor: textColor,
                      mutedColor: mutedColor,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      accentColor: accentColor,
                    ),
                    ProfileOption(
                      style: ProfileOptionStyle.grouped,
                      icon: Iconsax.link_circle,
                      title: 'Redes sociales',
                      subtitle: 'Enlaces a tu página pública',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SocialLinksScreen(),
                          ),
                        );
                      },
                      textColor: textColor,
                      mutedColor: mutedColor,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      accentColor: accentColor,
                    ),
                    ProfileOption(
                      style: ProfileOptionStyle.grouped,
                      icon: Iconsax.people,
                      title: 'Trabajadores',
                      subtitle: 'Empleados y permisos',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmployeesScreen(),
                          ),
                        );
                      },
                      textColor: textColor,
                      mutedColor: mutedColor,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      accentColor: accentColor,
                    ),
                  ],
                ),

              if (RoleHelper.isBarber(ref))
                ProfileIosSection(
                  title: 'Análisis',
                  headerColor: sectionHeaderColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  tiles: [
                    ProfileOption(
                      style: ProfileOptionStyle.grouped,
                      icon: Iconsax.chart_2,
                      title: 'Estadísticas rápidas',
                      subtitle: 'Citas, ingresos y clientes',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuickStatsScreen(),
                          ),
                        );
                      },
                      textColor: textColor,
                      mutedColor: mutedColor,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      accentColor: accentColor,
                    ),
                    ProfileOption(
                      style: ProfileOptionStyle.grouped,
                      icon: Iconsax.chart_21,
                      title: 'Reportes de empleados',
                      subtitle: 'Rendimiento y actividad',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmployeeReportsScreen(),
                          ),
                        );
                      },
                      textColor: textColor,
                      mutedColor: mutedColor,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      accentColor: accentColor,
                    ),
                    ProfileOption(
                      style: ProfileOptionStyle.grouped,
                      icon: Iconsax.document_download,
                      title: 'Exportar datos',
                      subtitle: 'Reportes y respaldo',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExportDataScreen(),
                          ),
                        );
                      },
                      textColor: textColor,
                      mutedColor: mutedColor,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      accentColor: accentColor,
                    ),
                  ],
                ),

              ProfileIosSection(
                title: 'General',
                headerColor: sectionHeaderColor,
                cardColor: cardColor,
                borderColor: borderColor,
                tiles: [
                  ProfileOption(
                    style: ProfileOptionStyle.grouped,
                    icon: Iconsax.message_question,
                    title: 'Ayuda y soporte',
                    subtitle: 'Preguntas frecuentes y contacto',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportScreen(),
                        ),
                      );
                    },
                    textColor: textColor,
                    mutedColor: mutedColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    accentColor: accentColor,
                  ),
                  ProfileOption(
                    style: ProfileOptionStyle.grouped,
                    icon: Iconsax.setting_2,
                    title: 'Configuración',
                    subtitle: 'Tema, notificaciones e idioma',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    textColor: textColor,
                    mutedColor: mutedColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    accentColor: accentColor,
                  ),
                  ProfileOption(
                    style: ProfileOptionStyle.grouped,
                    icon: Iconsax.info_circle,
                    title: 'Acerca de',
                    subtitle: 'App y desarrolladores',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                    textColor: textColor,
                    mutedColor: mutedColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    accentColor: accentColor,
                  ),
                ],
              ),

              if (RoleHelper.canRequestAccountDeletion(authForDeletion))
                ProfileIosSection(
                  title: 'Privacidad',
                  headerColor: sectionHeaderColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  tiles: [
                    p.deleteAccountOption(
                      pending:
                          authForDeletion.userProfile?.accountDeletionPending == true,
                      scheduledFor: authForDeletion
                          .userProfile?.accountDeletionScheduledForUtc,
                      formatDate: formatProfileAccountDeletionDate,
                      onTap: _onAccountDeletionTap,
                    ),
                  ],
                ),

              ProfileIosSection(
                title: 'Sesión',
                headerColor: sectionHeaderColor,
                cardColor: cardColor,
                borderColor: borderColor,
                tiles: [
                  if (ref.watch(authNotifierProvider).isDemoMode)
                    ProfileOption(
                      style: ProfileOptionStyle.grouped,
                      icon: Iconsax.logout_1,
                      title: 'Salir del demo',
                      subtitle: 'Volver al inicio de sesión',
                      onTap: _exitDemoMode,
                      textColor: const Color(0xFFCA8A04),
                      mutedColor: const Color(0xFFCA8A04),
                      cardColor: cardColor,
                      borderColor: borderColor,
                      accentColor: const Color(0xFFFFB84D),
                      isDestructive: false,
                    ),
                  ProfileOption(
                    style: ProfileOptionStyle.grouped,
                    icon: Iconsax.logout,
                    title: 'Cerrar sesión',
                    subtitle: '',
                    onTap: _logout,
                    textColor: const Color(0xFFEF4444),
                    mutedColor: const Color(0xFFEF4444),
                    cardColor: cardColor,
                    borderColor: borderColor,
                    accentColor: const Color(0xFFEF4444),
                    isDestructive: true,
                  ),
                ],
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../models/barber.dart';
import '../../services/api/barber_service.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'qr_code_screen.dart';
import 'change_password_screen.dart';
import 'about_screen.dart';
import 'working_hours_screen.dart';
import 'quick_stats_screen.dart';
import 'help_support_screen.dart';
import 'export_data_screen.dart';
import 'settings_screen.dart';
import 'employees_screen.dart';
import '../../utils/role_helper.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_option.dart';
import 'widgets/profile_error_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  BarberDto? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
      print('🔵 [Profile] Cargando perfil...');
      final service = ref.read(barberServiceProvider);
      final profile = await service.getProfile();
      print('✅ [Profile] Perfil cargado: ${profile.name}, ${profile.businessName}');
      if (mounted) {
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
      
      print('❌ [Profile] Error HTTP: $statusCode');
      print('📋 [Profile] Error data: $errorData');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = statusCode != null ? 'Error $statusCode: $message' : message;
        });
      }
    } catch (e, stackTrace) {
      print('❌ [Profile] Error al cargar: $e');
      print('📋 [Profile] StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
    final cardColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
    const accentColor = Color(0xFF10B981);

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: accentColor));
    }

    // Si es Employee, mostrar perfil simplificado
    if (RoleHelper.isEmployee(ref)) {
      final authState = ref.read(authNotifierProvider);
      final userProfile = authState.userProfile;
      
      return RefreshIndicator(
        onRefresh: _loadProfile,
        color: accentColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header simplificado para trabajador
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentColor, accentColor.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Iconsax.user, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProfile?.nombreCompleto ?? 'Trabajador',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userProfile?.email ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Opciones disponibles para trabajadores
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Cambiar Contraseña
                    ProfileOption(
                      icon: Iconsax.lock,
                      title: 'Cambiar Contraseña',
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
                    const SizedBox(height: 10),

                    // Ayuda y Soporte
                    ProfileOption(
                      icon: Iconsax.message_question,
                      title: 'Ayuda y Soporte',
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
                    const SizedBox(height: 10),

                    // Configuración
                    ProfileOption(
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
                    const SizedBox(height: 10),

                    // Acerca de
                    ProfileOption(
                      icon: Iconsax.info_circle,
                      title: 'Acerca de',
                      subtitle: 'Información sobre la aplicación y desarrolladores',
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
              ),

              // Botón cerrar sesión
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: borderColor, width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 16),
                  child: ProfileOption(
                    icon: Iconsax.logout,
                    title: 'Cerrar Sesión',
                    subtitle: 'Salir de tu cuenta',
                    onTap: _logout,
                    textColor: const Color(0xFFEF4444),
                    mutedColor: const Color(0xFFEF4444),
                    cardColor: cardColor,
                    borderColor: Colors.transparent,
                    accentColor: const Color(0xFFEF4444),
                    isDestructive: true,
                  ),
                ),
              ),
            ],
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

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: accentColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header con perfil
            ProfileHeader(
              profile: _profile!,
              onProfileUpdated: _loadProfile,
              textColor: textColor,
              mutedColor: mutedColor,
              cardColor: cardColor,
              borderColor: borderColor,
              accentColor: accentColor,
            ),

            // Opciones del menú
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Información Personal
                  ProfileOption(
                    icon: Iconsax.profile_circle,
                    title: 'Información Personal',
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
                  const SizedBox(height: 10),

                  // Código QR (solo para Barber)
                  if (RoleHelper.isBarber(ref)) ...[
                    ProfileOption(
                      icon: Iconsax.scan_barcode,
                      title: 'Código QR',
                      subtitle: 'Comparte tu QR para que los clientes agenden citas',
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
                    const SizedBox(height: 10),
                  ],

                  // Cambiar Contraseña
                  ProfileOption(
                    icon: Iconsax.lock,
                    title: 'Cambiar Contraseña',
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
                  const SizedBox(height: 10),

                  // URL Pública (solo para Barber)
                  if (RoleHelper.isBarber(ref)) ...[
                    ProfileOption(
                      icon: Iconsax.link,
                      title: 'URL Pública',
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
                    const SizedBox(height: 10),
                  ],

                  // Horarios de Trabajo (solo para Barber)
                  if (RoleHelper.isBarber(ref)) ...[
                    ProfileOption(
                      icon: Iconsax.clock,
                      title: 'Horarios de Trabajo',
                      subtitle: 'Configurar días y horarios disponibles',
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
                    const SizedBox(height: 10),
                  ],

                  // Trabajadores (solo para Barber)
                  if (RoleHelper.isBarber(ref)) ...[
                    ProfileOption(
                      icon: Iconsax.people,
                      title: 'Trabajadores',
                      subtitle: 'Gestionar empleados y trabajadores',
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
                    const SizedBox(height: 10),
                  ],

                  // Estadísticas Rápidas (solo para Barber)
                  if (RoleHelper.isBarber(ref)) ...[
                    ProfileOption(
                      icon: Iconsax.chart_2,
                      title: 'Estadísticas Rápidas',
                      subtitle: 'Resumen de citas, ingresos y clientes',
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
                    const SizedBox(height: 10),
                  ],

                  // Ayuda y Soporte
                  ProfileOption(
                    icon: Iconsax.message_question,
                    title: 'Ayuda y Soporte',
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
                  const SizedBox(height: 10),

                  // Exportar Datos (solo para Barber)
                  if (RoleHelper.isBarber(ref)) ...[
                    ProfileOption(
                      icon: Iconsax.document_download,
                      title: 'Exportar Datos',
                      subtitle: 'Exportar reportes y crear backup',
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
                    const SizedBox(height: 10),
                  ],

                  // Configuración
                  ProfileOption(
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
                  const SizedBox(height: 10),

                  // Acerca de
                  ProfileOption(
                    icon: Iconsax.info_circle,
                    title: 'Acerca de',
                    subtitle: 'Información sobre la aplicación y desarrolladores',
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
            ),

            // Botón cerrar sesión
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: borderColor, width: 1),
                  ),
                ),
                padding: const EdgeInsets.only(top: 16),
                child: ProfileOption(
                  icon: Iconsax.logout,
                  title: 'Cerrar Sesión',
                  subtitle: 'Salir de tu cuenta',
                  onTap: _logout,
                  textColor: const Color(0xFFEF4444),
                  mutedColor: const Color(0xFFEF4444),
                  cardColor: cardColor,
                  borderColor: Colors.transparent,
                  accentColor: const Color(0xFFEF4444),
                  isDestructive: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

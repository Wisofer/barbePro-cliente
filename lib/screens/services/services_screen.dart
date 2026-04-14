import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../models/service.dart';
import '../../services/api/service_service.dart';
import '../../services/api/employee_service_service.dart';
import '../../utils/role_helper.dart';
import '../profile/profile_palette.dart';
import 'create_edit_service_screen.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  List<ServiceDto> _services = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      List<ServiceDto> services;
      
      // Los empleados usan el endpoint /employee/services (solo lectura)
      // Los barberos usan el endpoint /barber/services (con permisos completos)
      if (RoleHelper.isEmployee(ref)) {
        final employeeServiceService = ref.read(employeeServiceServiceProvider);
        services = await employeeServiceService.getServices();
      } else {
        final service = ref.read(serviceServiceProvider);
        services = await service.getServices();
      }
      
      if (mounted) {
        setState(() {
          _services = services;
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
        // 404 significa que no hay servicios, no es un error
        if (mounted) {
          setState(() {
            _services = [];
            _isLoading = false;
            _errorMessage = null;
          });
        }
        return;
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

  Future<void> _deleteService(ServiceDto service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          '¿Eliminar servicio?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: Text(
          'Se eliminará "${service.name}". No podrás deshacerlo.',
          style: GoogleFonts.inter(fontSize: 14, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Eliminar',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final serviceApi = ref.read(serviceServiceProvider);
      await serviceApi.deleteService(service.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Servicio eliminado'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        _loadServices();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = ProfilePalette.of(context);
    final groupedBg = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF000000)
        : Colors.white;
    final textColor = p.textColor;
    final mutedColor = p.mutedColor;
    final cardColor = p.cardColor;
    final borderColor = p.borderColor;
    final accentColor = p.accent;
    final isBarber = RoleHelper.isBarber(ref);

    return Scaffold(
      backgroundColor: groupedBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Servicios',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: -0.35,
                    ),
                  ),
                  if (isBarber) ...[
                    const Spacer(),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: accentColor.withValues(alpha: 0.12),
                        foregroundColor: accentColor,
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateEditServiceScreen(),
                          ),
                        );
                        if (result == true && mounted) {
                          _loadServices();
                        }
                      },
                      icon: const Icon(Iconsax.add, size: 22),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: accentColor))
                  : _errorMessage != null
                      ? _ErrorState(
                          errorMessage: _errorMessage!,
                          onRetry: _loadServices,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          accentColor: accentColor,
                        )
                      : _services.isEmpty
                          ? _EmptyState(
                              onAddService: isBarber
                                  ? () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CreateEditServiceScreen(),
                                        ),
                                      );
                                      if (result == true && mounted) {
                                        _loadServices();
                                      }
                                    }
                                  : null,
                              textColor: textColor,
                              mutedColor: mutedColor,
                              accentColor: accentColor,
                            )
                          : RefreshIndicator(
                              onRefresh: _loadServices,
                              color: accentColor,
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                                itemCount: _services.length,
                                itemBuilder: (context, index) {
                                  final service = _services[index];
                                  return _ServiceSimpleRow(
                                    service: service,
                                    textColor: textColor,
                                    mutedColor: mutedColor,
                                    cardColor: cardColor,
                                    borderColor: borderColor,
                                    accentColor: accentColor,
                                    destructive: ProfilePalette.destructive,
                                    onEdit: isBarber
                                        ? () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CreateEditServiceScreen(
                                                  service: service,
                                                ),
                                              ),
                                            );
                                            if (result == true && mounted) {
                                              _loadServices();
                                            }
                                          }
                                        : null,
                                    onDelete: isBarber
                                        ? () => _deleteService(service)
                                        : null,
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onAddService;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;

  const _EmptyState({
    this.onAddService,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: mutedColor.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.scissor,
                  color: mutedColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No hay servicios',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                onAddService != null
                    ? 'Agrega tu primer servicio para comenzar'
                    : 'No hay servicios disponibles',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: mutedColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              if (onAddService != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onAddService,
                  icon: const Icon(Iconsax.add, size: 18),
                  label: const Text('Agregar Servicio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;

  const _ErrorState({
    required this.errorMessage,
    required this.onRetry,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.warning_2, color: const Color(0xFFEF4444), size: 48),
              const SizedBox(height: 20),
              Text(
                'Error al cargar',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                errorMessage,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: mutedColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Iconsax.refresh, size: 18),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila simple: toque en el contenido → editar; icono papelera → modal eliminar.
class _ServiceSimpleRow extends StatelessWidget {
  final ServiceDto service;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;
  final Color destructive;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ServiceSimpleRow({
    required this.service,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
    required this.destructive,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final durationLine = service.isActive
        ? service.formattedDuration
        : '${service.formattedDuration} · inactivo';

    final main = Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 12, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  durationLine,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: service.isActive
                        ? mutedColor
                        : destructive.withValues(alpha: 0.9),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            service.formattedPrice,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: onEdit != null
                    ? Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onEdit,
                          child: main,
                        ),
                      )
                    : main,
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Iconsax.trash,
                    size: 22,
                    color: destructive.withValues(alpha: 0.85),
                  ),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

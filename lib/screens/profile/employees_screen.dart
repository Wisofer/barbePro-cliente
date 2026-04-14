import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../models/employee.dart';
import '../../services/api/employee_service.dart';
import 'create_edit_employee_screen.dart';
import 'widgets/profile_ios_section.dart' show IosGroupedCard;

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  List<EmployeeDto> _employees = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final service = ref.read(employeeServiceProvider);
      final employees = await service.getEmployees();
      if (mounted) {
        setState(() {
          _employees = employees;
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
        // 404 significa que no hay trabajadores, no es un error
        if (mounted) {
          setState(() {
            _employees = [];
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

  Future<void> _deleteEmployee(EmployeeDto employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Desactivar trabajador',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          '¿Estás seguro de que deseas desactivar a "${employee.name}"? El trabajador no podrá acceder a la aplicación.',
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
            child: Text('Desactivar', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final serviceApi = ref.read(employeeServiceProvider);
      await serviceApi.deleteEmployee(employee.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${employee.name} ha sido desactivado'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        _loadEmployees();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al desactivar: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
    const accentColor = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: groupedBg,
      appBar: AppBar(
        backgroundColor: groupedBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Trabajadores',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Iconsax.add, color: accentColor),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateEditEmployeeScreen(),
                ),
              );
              if (result == true) {
                _loadEmployees();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEmployees,
        color: accentColor,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: accentColor))
            : _errorMessage != null
                ? _buildErrorState(textColor, mutedColor, accentColor)
                : _employees.isEmpty
                    ? _buildEmptyState(textColor, mutedColor, accentColor)
                    : _buildEmployeesList(textColor, mutedColor, cardColor, borderColor, accentColor),
      ),
    );
  }

  Widget _buildErrorState(Color textColor, Color mutedColor, Color accentColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.info_circle, color: mutedColor, size: 64),
            const SizedBox(height: 16),
            Text(
              'Error al cargar trabajadores',
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                color: const Color(0xFFDC2626),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadEmployees,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color mutedColor, Color accentColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.people, color: accentColor, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay trabajadores',
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega trabajadores para que puedan ayudarte a gestionar las citas',
              style: GoogleFonts.inter(
                color: mutedColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEditEmployeeScreen(),
                  ),
                );
                if (result == true) {
                  _loadEmployees();
                }
              },
              icon: const Icon(Iconsax.add),
              label: const Text('Agregar Trabajador'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeesList(
    Color textColor,
    Color mutedColor,
    Color cardColor,
    Color borderColor,
    Color accentColor,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 28),
      children: [
        IosGroupedCard(
          cardColor: cardColor,
          child: Column(
            children: [
              for (final entry in _employees.asMap().entries) ...[
                if (entry.key > 0)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                    color: borderColor.withValues(alpha: 0.75),
                  ),
                _EmployeeGroupedRow(
                  employee: entry.value,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  accentColor: accentColor,
                  onEdit: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateEditEmployeeScreen(employee: entry.value),
                      ),
                    );
                    if (result == true && mounted) _loadEmployees();
                  },
                  onDeactivate: () => _deleteEmployee(entry.value),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EmployeeGroupedRow extends StatelessWidget {
  final EmployeeDto employee;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;

  const _EmployeeGroupedRow({
    required this.employee,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
    required this.onEdit,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withValues(alpha: 0.75)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Iconsax.user, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.name,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: employee.isActive
                                ? accentColor.withValues(alpha: 0.12)
                                : mutedColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            employee.isActive ? 'Activo' : 'Inactivo',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: employee.isActive ? accentColor : mutedColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (employee.email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Iconsax.sms, size: 12, color: mutedColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              employee.email,
                              style: GoogleFonts.inter(fontSize: 12, color: mutedColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (employee.phone != null && employee.phone!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Iconsax.call, size: 12, color: mutedColor),
                          const SizedBox(width: 4),
                          Text(
                            employee.phone!,
                            style: GoogleFonts.inter(fontSize: 12, color: mutedColor),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Iconsax.more, color: mutedColor, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'deactivate') onDeactivate();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Iconsax.edit, size: 18, color: accentColor),
                        const SizedBox(width: 8),
                        Text('Editar', style: GoogleFonts.inter()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'deactivate',
                    child: Row(
                      children: [
                        const Icon(Iconsax.trash, size: 18, color: Color(0xFFEF4444)),
                        const SizedBox(width: 8),
                        Text('Desactivar', style: GoogleFonts.inter()),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


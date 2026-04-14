import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../models/employee.dart';
import '../../services/api/employee_service.dart';
import '../../utils/audio_helper.dart';
import 'widgets/profile_ios_section.dart' show IosGroupedCard;

class CreateEditEmployeeScreen extends ConsumerStatefulWidget {
  final EmployeeDto? employee;

  const CreateEditEmployeeScreen({
    super.key,
    this.employee,
  });

  @override
  ConsumerState<CreateEditEmployeeScreen> createState() => _CreateEditEmployeeScreenState();
}

class _CreateEditEmployeeScreenState extends ConsumerState<CreateEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameController.text = widget.employee!.name;
      _emailController.text = widget.employee!.email;
      _phoneController.text = widget.employee!.phone ?? '';
      _isActive = widget.employee!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(employeeServiceProvider);
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();

      if (widget.employee == null) {
        // Crear trabajador
        final password = _passwordController.text.trim();
        if (password.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La contraseña es obligatoria'),
                backgroundColor: Color(0xFFEF4444),
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }

        final request = CreateEmployeeRequest(
          name: name,
          email: email,
          password: password,
          phone: phone,
        );

        await service.createEmployee(request);
        if (mounted) {
          // Reproducir audio de éxito
          AudioHelper.playSuccess();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Trabajador "$name" creado exitosamente'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Actualizar trabajador
        final request = UpdateEmployeeRequest(
          name: name,
          phone: phone,
          isActive: _isActive,
        );

        await service.updateEmployee(widget.employee!.id, request);
        if (mounted) {
          // Reproducir audio de éxito
          AudioHelper.playSuccess();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Trabajador "$name" actualizado exitosamente'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } on DioException catch (e) {
      String errorMessage = 'Error desconocido';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response!.data['message'] ?? e.message ?? errorMessage;
      } else if (e.response?.data is String) {
        errorMessage = e.response!.data as String;
      } else {
        errorMessage = e.message ?? errorMessage;
      }

      if (mounted) {
        // Reproducir audio de error
        AudioHelper.playError();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Reproducir audio de error
        AudioHelper.playError();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
    final isEditing = widget.employee != null;

    return Scaffold(
      backgroundColor: groupedBg,
      appBar: AppBar(
        backgroundColor: groupedBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Editar trabajador' : 'Nuevo trabajador',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  isEditing
                      ? 'Actualiza los datos del trabajador.'
                      : 'Crea una cuenta para que pueda iniciar sesión en la app.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: mutedColor,
                    height: 1.4,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 16, bottom: 6, top: 20),
                child: Text(
                  'DATOS',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: sectionHeaderColor,
                  ),
                ),
              ),
              IosGroupedCard(
                cardColor: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _GroupedTextFormField(
                      controller: _nameController,
                      label: 'Nombre completo',
                      hint: 'Ej: Carlos Rodríguez',
                      icon: Iconsax.user,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      accentColor: accentColor,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        if (value.trim().length < 3) {
                          return 'Mínimo 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                      color: borderColor.withValues(alpha: 0.75),
                    ),
                    _GroupedTextFormField(
                      controller: _emailController,
                      label: 'Correo',
                      hint: 'ejemplo@correo.com',
                      icon: Iconsax.sms,
                      textColor: isEditing ? mutedColor : textColor,
                      mutedColor: mutedColor,
                      accentColor: accentColor,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: isEditing,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El email es obligatorio';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Email no válido';
                        }
                        return null;
                      },
                    ),
                    if (isEditing)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Text(
                          'El correo no se puede cambiar.',
                          style: GoogleFonts.inter(fontSize: 12, color: mutedColor),
                        ),
                      ),
                    if (!isEditing) ...[
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 16,
                        endIndent: 16,
                        color: borderColor.withValues(alpha: 0.75),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.inter(fontSize: 16, color: textColor),
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Contraseña',
                            labelStyle: GoogleFonts.inter(color: mutedColor, fontSize: 13),
                            hintText: 'Mínimo 6 caracteres',
                            hintStyle: GoogleFonts.inter(
                              color: mutedColor.withValues(alpha: 0.7),
                            ),
                            prefixIcon: Icon(Iconsax.lock, color: accentColor, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                                color: mutedColor,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            border: InputBorder.none,
                            errorStyle: GoogleFonts.inter(
                              color: const Color(0xFFEF4444),
                              fontSize: 12,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La contraseña es obligatoria';
                            }
                            if (value.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                      color: borderColor.withValues(alpha: 0.75),
                    ),
                    _GroupedTextFormField(
                      controller: _phoneController,
                      label: 'Teléfono (opcional)',
                      hint: '82310100',
                      icon: Iconsax.call,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      accentColor: accentColor,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),
              if (isEditing) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 16, bottom: 6, top: 22),
                  child: Text(
                    'ESTADO',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: sectionHeaderColor,
                    ),
                  ),
                ),
                IosGroupedCard(
                  cardColor: cardColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cuenta activa',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isActive
                                    ? 'Puede acceder a la aplicación.'
                                    : 'No podrá iniciar sesión.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: mutedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _isActive,
                          activeThumbColor: accentColor,
                          activeTrackColor: accentColor.withValues(alpha: 0.45),
                          onChanged: (value) {
                            setState(() => _isActive = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveEmployee,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isEditing ? 'Guardar' : 'Crear trabajador',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
}

class _GroupedTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;
  final TextInputType? keyboardType;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _GroupedTextFormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
    this.keyboardType,
    this.readOnly = false,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: GoogleFonts.inter(fontSize: 16, color: textColor),
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          labelStyle: GoogleFonts.inter(color: mutedColor, fontSize: 13),
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: mutedColor.withValues(alpha: 0.7)),
          prefixIcon: Icon(icon, color: accentColor, size: 20),
          border: InputBorder.none,
          errorStyle: GoogleFonts.inter(
            color: const Color(0xFFEF4444),
            fontSize: 12,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        validator: validator,
      ),
    );
  }
}


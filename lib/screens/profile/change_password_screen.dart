import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api/barber_service.dart';
import '../../services/api/employee_auth_service.dart';
import '../../utils/role_helper.dart';
import 'widgets/profile_ios_section.dart' show IosGroupedCard;

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final current = _currentPasswordController.text.trim();
      final next = _newPasswordController.text.trim();

      if (RoleHelper.isBarber(ref)) {
        final service = ref.read(barberServiceProvider);
        await service.changePassword(
          currentPassword: current,
          newPassword: next,
        );
      } else if (RoleHelper.isEmployee(ref)) {
        final service = ref.read(employeeAuthServiceProvider);
        await service.changePassword(
          currentPassword: current,
          newPassword: next,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña actualizada exitosamente'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
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
    final mutedColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8);
    final groupedBg = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final sectionHeaderColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D72);
    const accentColor = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: groupedBg,
      appBar: AppBar(
        title: Text(
          'Cambiar contraseña',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        backgroundColor: groupedBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Text(
                  'Usa una contraseña segura que no reutilices en otros sitios.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: mutedColor,
                    height: 1.4,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 16, bottom: 6, top: 8),
                child: Text(
                  'CONTRASEÑA',
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
                  children: [
                    _EmbeddedPasswordField(
                      controller: _currentPasswordController,
                      hintLabel: 'Contraseña actual',
                      obscureText: _obscureCurrent,
                      onToggleVisibility: () => setState(() => _obscureCurrent = !_obscureCurrent),
                      textColor: textColor,
                      mutedColor: mutedColor,
                      accentColor: accentColor,
                      validator: (v) => v == null || v.isEmpty ? 'Requerida' : null,
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                      color: borderColor.withValues(alpha: 0.75),
                    ),
                    _EmbeddedPasswordField(
                      controller: _newPasswordController,
                      hintLabel: 'Nueva contraseña',
                      obscureText: _obscureNew,
                      onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
                      textColor: textColor,
                      mutedColor: mutedColor,
                      accentColor: accentColor,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerida';
                        if (v.length < 6) return 'Mínimo 6 caracteres';
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
                    _EmbeddedPasswordField(
                      controller: _confirmPasswordController,
                      hintLabel: 'Confirmar nueva contraseña',
                      obscureText: _obscureConfirm,
                      onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      textColor: textColor,
                      mutedColor: mutedColor,
                      accentColor: accentColor,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirma la contraseña';
                        if (v != _newPasswordController.text) return 'No coincide';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                            'Guardar',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
}

class _EmbeddedPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hintLabel;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;
  final String? Function(String?)? validator;

  const _EmbeddedPasswordField({
    required this.controller,
    required this.hintLabel,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: GoogleFonts.inter(fontSize: 16, color: textColor),
        decoration: InputDecoration(
          labelText: hintLabel,
          labelStyle: GoogleFonts.inter(color: mutedColor, fontSize: 13),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          prefixIcon: Icon(Iconsax.lock, color: accentColor, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Iconsax.eye_slash : Iconsax.eye,
              color: mutedColor,
              size: 20,
            ),
            onPressed: onToggleVisibility,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../models/barber.dart';
import '../../services/api/barber_service.dart';
import '../../utils/audio_helper.dart';
import 'widgets/profile_ios_section.dart' show IosGroupedCard;

class EditProfileScreen extends ConsumerStatefulWidget {
  final BarberDto profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _businessNameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _businessNameController = TextEditingController(text: widget.profile.businessName ?? '');
    _phoneController = TextEditingController(text: widget.profile.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre es requerido'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El teléfono es requerido'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(barberServiceProvider);
      await service.updateProfile(
        name: _nameController.text.trim(),
        businessName: _businessNameController.text.trim().isEmpty
            ? null
            : _businessNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (mounted) {
        // Reproducir audio de éxito
        AudioHelper.playSuccess();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.pop(context, true);
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Error al actualizar el perfil';
      if (mounted) {
        // Reproducir audio de error
        AudioHelper.playError();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Reproducir audio de error
        AudioHelper.playError();
        
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
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
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
          'Información personal',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                'Los datos se muestran en tu perfil y en la reserva pública.',
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
                children: [
                  _GroupedProfileField(
                    controller: _nameController,
                    label: 'Nombre',
                    icon: Iconsax.user,
                    hintText: 'Tu nombre completo',
                    textColor: textColor,
                    mutedColor: mutedColor,
                    accentColor: accentColor,
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                    color: borderColor.withValues(alpha: 0.75),
                  ),
                  _GroupedProfileField(
                    controller: _businessNameController,
                    label: 'Nombre del negocio (opcional)',
                    icon: Iconsax.shop,
                    hintText: 'Nombre comercial',
                    textColor: textColor,
                    mutedColor: mutedColor,
                    accentColor: accentColor,
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                    color: borderColor.withValues(alpha: 0.75),
                  ),
                  _GroupedProfileField(
                    controller: _phoneController,
                    label: 'Teléfono',
                    icon: Iconsax.call,
                    hintText: 'Tu número',
                    textColor: textColor,
                    mutedColor: mutedColor,
                    accentColor: accentColor,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
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
    );
  }
}

class _GroupedProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hintText;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;
  final TextInputType? keyboardType;

  const _GroupedProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hintText,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(fontSize: 16, color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: mutedColor, fontSize: 13),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          hintText: hintText,
          hintStyle: GoogleFonts.inter(color: mutedColor.withValues(alpha: 0.7)),
          prefixIcon: Icon(icon, color: accentColor, size: 20),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}


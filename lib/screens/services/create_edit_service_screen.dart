import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/service.dart';
import '../../services/api/service_service.dart';
import '../../utils/audio_helper.dart';
import '../profile/profile_palette.dart';
import '../profile/widgets/profile_ios_section.dart' show IosGroupedCard;

class CreateEditServiceScreen extends ConsumerStatefulWidget {
  final ServiceDto? service;

  const CreateEditServiceScreen({
    super.key,
    this.service,
  });

  @override
  ConsumerState<CreateEditServiceScreen> createState() => _CreateEditServiceScreenState();
}

class _CreateEditServiceScreenState extends ConsumerState<CreateEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _priceController.text = widget.service!.price.toStringAsFixed(2);
      _durationController.text = widget.service!.durationMinutes.toString();
      _isActive = widget.service!.isActive;
    } else {
      _durationController.text = '30'; // Valor por defecto
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(serviceServiceProvider);
      final name = _nameController.text.trim();
      final price = double.parse(_priceController.text);
      final durationMinutes = _durationController.text.isEmpty
          ? null
          : int.tryParse(_durationController.text);

      if (widget.service == null) {
        // Crear servicio
        await service.createService(
          name: name,
          price: price,
          durationMinutes: durationMinutes,
        );
        if (mounted) {
          // Reproducir audio de éxito
          AudioHelper.playSuccess();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Servicio creado exitosamente'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Actualizar servicio
        await service.updateService(
          id: widget.service!.id,
          name: name,
          price: price,
          durationMinutes: durationMinutes,
          isActive: _isActive,
        );
        if (mounted) {
          // Reproducir audio de éxito
          AudioHelper.playSuccess();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Servicio actualizado exitosamente'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        // Reproducir audio de error
        AudioHelper.playError();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
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
    final p = ProfilePalette.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final groupedBg = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final sectionHeaderColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D72);
    final textColor = p.textColor;
    final mutedColor = p.mutedColor;
    final cardColor = p.cardColor;
    final borderColor = p.borderColor;
    final accentColor = p.accent;
    final isEditing = widget.service != null;

    return Scaffold(
      backgroundColor: groupedBg,
      appBar: AppBar(
        backgroundColor: groupedBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          color: textColor,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Editar servicio' : 'Nuevo servicio',
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
                  'Los clientes verán nombre, precio y duración al reservar.',
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
                    _ServiceGroupedField(
                      controller: _nameController,
                      label: 'Nombre',
                      hint: 'Ej. Corte de cabello',
                      leadingIcon: Iconsax.scissor,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      accentColor: accentColor,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es obligatorio';
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
                    _ServiceGroupedField(
                      controller: _priceController,
                      label: 'Precio (C\$)',
                      hint: '0.00',
                      textColor: textColor,
                      mutedColor: mutedColor,
                      accentColor: accentColor,
                      leadingIcon: Iconsax.wallet_3,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El precio es obligatorio';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'Precio no válido';
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
                    _ServiceGroupedField(
                      controller: _durationController,
                      label: 'Duración (min)',
                      hint: '30',
                      leadingIcon: Iconsax.clock,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      accentColor: accentColor,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      suffixText: 'min',
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final duration = int.tryParse(value);
                          if (duration == null || duration <= 0) {
                            return 'Duración no válida';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Text(
                  'Si dejas la duración vacía, se usarán 30 minutos.',
                  style: GoogleFonts.inter(fontSize: 12, color: mutedColor),
                ),
              ),
              if (isEditing) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 16, bottom: 6, top: 22),
                  child: Text(
                    'VISIBILIDAD',
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
                                'Servicio activo',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isActive
                                    ? 'Visible en reservas.'
                                    : 'Oculto para los clientes.',
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
                  onPressed: _isLoading ? null : _saveService,
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
                          isEditing ? 'Guardar' : 'Crear servicio',
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

class _ServiceGroupedField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData leadingIcon;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;
  final String? Function(String?)? validator;

  const _ServiceGroupedField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.leadingIcon,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
    this.keyboardType,
    this.inputFormatters,
    this.suffixText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: GoogleFonts.inter(fontSize: 16, color: textColor),
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          labelStyle: GoogleFonts.inter(color: mutedColor, fontSize: 13),
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: mutedColor.withValues(alpha: 0.7)),
          prefixIcon: Icon(leadingIcon, color: accentColor, size: 20),
          suffixText: suffixText,
          suffixStyle: GoogleFonts.inter(color: mutedColor, fontSize: 13),
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


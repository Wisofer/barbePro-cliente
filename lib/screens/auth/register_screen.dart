import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../main_theme.dart';
import '../../models/auth.dart';
import '../../providers/auth_provider.dart';
import '../../utils/audio_helper.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  static const String routeName = '/register';

  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = RegisterRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        businessName: _businessNameController.text.trim().isEmpty
            ? null
            : _businessNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      final authNotifier = ref.read(authNotifierProvider.notifier);
      final success = await authNotifier.register(request);

      if (!mounted) return;

      if (!success) {
        final authState = ref.read(authNotifierProvider);
        AudioHelper.playError();
        setState(() {
          _errorMessage = authState.errorMessage ?? 'Error al registrarse';
        });
      } else {
        AudioHelper.playSuccess();
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      AudioHelper.playError();
      if (mounted) setState(() => _errorMessage = 'Error de conexión');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF10B981);
    const accentLight = Color(0xFF34D399);
    const bgColor = Color(0xFFF0FDF4);
    const cardColor = Colors.white;
    const textColor = Color(0xFF1F2937);
    const mutedColor = Color(0xFF6B7280);
    const borderColor = Color(0xFFD1D5DB);

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final horizontalPadding = isSmallScreen ? 20.0 : 24.0;
    final fieldSpacing = isSmallScreen ? 10.0 : 12.0;
    final buttonHeight = isSmallScreen ? 48.0 : 52.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemMovilTheme.getStatusBarStyle(false),
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            // Fondo igual al login
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withAlpha(5),
                      accentLight.withAlpha(10),
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Header compacto: atrás + título + 1 mes gratis
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Iconsax.arrow_left_2),
                            onPressed: () => Navigator.of(context).pop(),
                            color: textColor,
                            style: IconButton.styleFrom(
                              backgroundColor: cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Crear cuenta',
                              style: GoogleFonts.inter(
                                fontSize: isSmallScreen ? 18 : 20,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Iconsax.gift, size: 14, color: accentColor),
                                const SizedBox(width: 6),
                                Text(
                                  '1 mes de prueba gratis',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: mutedColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Form(
                          key: _formKey,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFECACA)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Iconsax.warning_2, color: Color(0xFFDC2626), size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: const Color(0xFFDC2626),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: fieldSpacing),
                            ],

                            // Card blanca con el formulario (igual estilo que login)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withAlpha(12),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withAlpha(4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildField(
                                    'Nombre',
                                    _nameController,
                                    Iconsax.user,
                                    accentColor,
                                    borderColor,
                                    mutedColor,
                                    textColor,
                                    validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                                  ),
                                  SizedBox(height: fieldSpacing),
                                  _buildField(
                                    'Email',
                                    _emailController,
                                    Iconsax.sms,
                                    accentColor,
                                    borderColor,
                                    mutedColor,
                                    textColor,
                                    hintText: 'tu@email.com',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                                  ),
                                  SizedBox(height: fieldSpacing),
                                  _buildField(
                                    'Contraseña',
                                    _passwordController,
                                    Iconsax.lock,
                                    accentColor,
                                    borderColor,
                                    mutedColor,
                                    textColor,
                                    hintText: 'Mín. 6 caracteres',
                                    obscureText: _obscurePassword,
                                    validator: (v) {
                                      if (v == null || v.length < 6) return 'Mín. 6 caracteres';
                                      return null;
                                    },
                                    suffix: GestureDetector(
                                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                      child: Icon(
                                        _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                                        color: mutedColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: fieldSpacing),
                                  _buildField(
                                    'Teléfono',
                                    _phoneController,
                                    Iconsax.call,
                                    accentColor,
                                    borderColor,
                                    mutedColor,
                                    textColor,
                                    keyboardType: TextInputType.phone,
                                    validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                                  ),
                                  SizedBox(height: fieldSpacing),
                                  _buildField(
                                    'Negocio (opcional)',
                                    _businessNameController,
                                    Iconsax.shop,
                                    accentColor,
                                    borderColor,
                                    mutedColor,
                                    textColor,
                                    hintText: 'Ej. Barbería Central',
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: isSmallScreen ? 18 : 20),

                            SizedBox(
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Crear cuenta',
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Iconsax.arrow_right_3, size: 20),
                                        ],
                                      ),
                              ),
                            ),

                            SizedBox(height: 14),

                            Center(
                              child: GestureDetector(
                                onTap: _isLoading ? null : () => Navigator.of(context).pop(),
                                child: Text(
                                  '¿Ya tienes cuenta? Iniciar sesión',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon,
    Color accentColor,
    Color borderColor,
    Color mutedColor,
    Color textColor, {
    String? hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: GoogleFonts.inter(fontSize: 14, color: textColor, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(fontSize: 13, color: mutedColor.withAlpha(180)),
            prefixIcon: Icon(icon, color: mutedColor, size: 20),
            suffixIcon: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: suffix,
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor.withAlpha(80)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

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
    const bgColor = Colors.white;
    const textColor = Color(0xFF111827);
    const mutedColor = Color(0xFF6B7280);
    const borderColor = Color(0xFFE5E7EB);

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final horizontalPadding = isSmallScreen ? 20.0 : 24.0;
    final fieldSpacing = isSmallScreen ? 12.0 : 14.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemMovilTheme.getStatusBarStyle(false),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(
            'Crear cuenta',
            style: GoogleFonts.inter(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          elevation: 0,
          backgroundColor: bgColor,
          foregroundColor: textColor,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              8,
              horizontalPadding,
              24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                            Text(
                              'Registra tu barberia',
                              textAlign: TextAlign.left,
                              style: GoogleFonts.inter(
                                fontSize: isSmallScreen ? 34 : 36,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                height: 1.08,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Completa tus datos para empezar.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: mutedColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFECACA),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Iconsax.warning_2,
                                      color: Color(0xFFDC2626),
                                      size: 18,
                                    ),
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
                            _buildField(
                              'Nombre*',
                              _nameController,
                              Iconsax.user,
                              borderColor,
                              mutedColor,
                              textColor,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Requerido'
                                  : null,
                            ),
                            SizedBox(height: fieldSpacing),
                            _buildField(
                              'Correo*',
                              _emailController,
                              Iconsax.sms,
                              borderColor,
                              mutedColor,
                              textColor,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Requerido'
                                  : null,
                            ),
                            SizedBox(height: fieldSpacing),
                            _buildField(
                              'Telefono*',
                              _phoneController,
                              Iconsax.call,
                              borderColor,
                              mutedColor,
                              textColor,
                              keyboardType: TextInputType.phone,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Requerido'
                                  : null,
                            ),
                            SizedBox(height: fieldSpacing),
                            _buildField(
                              'Contrasena*',
                              _passwordController,
                              Iconsax.lock,
                              borderColor,
                              mutedColor,
                              textColor,
                              obscureText: _obscurePassword,
                              validator: (v) {
                                if (v == null || v.length < 6) {
                                  return 'Min. 6 caracteres';
                                }
                                return null;
                              },
                              suffix: IconButton(
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Iconsax.eye_slash
                                      : Iconsax.eye,
                                  color: mutedColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            SizedBox(height: fieldSpacing),
                            _buildField(
                              'Nombre de la barberia',
                              _businessNameController,
                              Iconsax.shop,
                              borderColor,
                              mutedColor,
                              textColor,
                            ),
                            SizedBox(height: isSmallScreen ? 18 : 20),
                            SizedBox(
                              height: 58,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'Crear cuenta',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 58,
                              child: OutlinedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: borderColor.withAlpha(180),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  'Ya tengo cuenta',
                                  style: GoogleFonts.inter(
                                    color: accentColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon,
    Color borderColor,
    Color mutedColor,
    Color textColor, {
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            color: mutedColor,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: suffix,
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: borderColor.withAlpha(40)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFF10B981),
              width: 1.3,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFDC2626)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

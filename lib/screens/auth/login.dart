import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../main_theme.dart';
import '../../services/storage/credentials_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _userFocused = false;
  bool _passFocused = false;
  bool _rememberCredentials = false;

  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userFocus = FocusNode();
  final _passFocus = FocusNode();
  final _credentialsStorage = CredentialsStorage();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _userFocus.addListener(() => setState(() => _userFocused = _userFocus.hasFocus));
    _passFocus.addListener(() => setState(() => _passFocused = _passFocus.hasFocus));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final credentials = await _credentialsStorage.loadCredentials();
      if (credentials['username'] != null && credentials['password'] != null) {
        setState(() {
          _userController.text = credentials['username']!;
          _passwordController.text = credentials['password']!;
          _rememberCredentials = true;
        });
      }
    } catch (e) {
      // Ignorar errores al cargar
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      final success = await authNotifier.login(
        _userController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (!success) {
        final authState = ref.read(authNotifierProvider);
        setState(() {
          _errorMessage = authState.errorMessage ?? 'Credenciales inválidas';
        });
      } else {
        if (_rememberCredentials) {
          await _credentialsStorage.saveCredentials(
            _userController.text.trim(),
            _passwordController.text,
          );
        } else {
          await _credentialsStorage.clearCredentials();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const accentColor = Color(0xFF10B981); // Verde barbero
    const accentLight = Color(0xFF34D399);
    const bgColor = Color(0xFFF0FDF4);
    const cardColor = Colors.white;
    const textColor = Color(0xFF1F2937);
    const mutedColor = Color(0xFF6B7280);
    const borderColor = Color(0xFFD1D5DB);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemMovilTheme.getStatusBarStyle(false),
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            // Fondo decorativo con gradiente
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

            // Elementos decorativos de barbería
            Positioned(
              top: -50,
              right: -50,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animationController.value * 0.1,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            accentColor.withAlpha(20),
                            accentColor.withAlpha(5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Icon(
                        Iconsax.scissor,
                        color: accentColor.withAlpha(30),
                        size: 80,
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentLight.withAlpha(15),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Icon(
                  Iconsax.scissor5,
                  color: accentLight.withAlpha(20),
                  size: 60,
                ),
              ),
            ),

            // Contenido principal
            SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Logo y branding
                      _buildHeader(accentColor, textColor, mutedColor),

                      const SizedBox(height: 30),

                      // Card de login
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                              // Título
                          Row(
                            children: [
                              Container(
                                    padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                      color: accentColor.withAlpha(20),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Iconsax.scissor,
                                      color: accentColor,
                                      size: 20,
                                ),
                              ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                          'Bienvenido',
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                            letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                          'Inicia sesión para continuar',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: mutedColor,
                                          ),
                                        ),
                                      ],
                                    ),
                              ),
                            ],
                          ),

                              const SizedBox(height: 24),

                          // Error message
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Row(
                                children: [
                                      const Icon(Iconsax.warning_2, color: Color(0xFFDC2626), size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                            color: const Color(0xFFDC2626),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                                const SizedBox(height: 20),
                          ],

                              // Campo Email
                              _buildTextField(
                                label: 'Email',
                              controller: _userController,
                              focusNode: _userFocus,
                                isFocused: _userFocused,
                                icon: Iconsax.sms,
                                keyboardType: TextInputType.emailAddress,
                                hintText: 'tu@email.com',
                                validator: (v) => v == null || v.isEmpty ? 'El email es requerido' : null,
                                accentColor: accentColor,
                                accentLight: accentLight,
                                textColor: textColor,
                                mutedColor: mutedColor,
                                borderColor: borderColor,
                                cardColor: cardColor,
                          ),

                              const SizedBox(height: 16),

                          // Campo Contraseña
                              _buildTextField(
                                label: 'Contraseña',
                              controller: _passwordController,
                              focusNode: _passFocus,
                                isFocused: _passFocused,
                                icon: Iconsax.lock,
                              obscureText: _obscurePassword,
                                hintText: '••••••••',
                                validator: (v) => v == null || v.isEmpty ? 'La contraseña es requerida' : null,
                                accentColor: accentColor,
                                accentLight: accentLight,
                                textColor: textColor,
                                mutedColor: mutedColor,
                                borderColor: borderColor,
                                cardColor: cardColor,
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                    child: Icon(
                                      _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                                      color: mutedColor,
                                      size: 20,
                                    ),
                                  ),
                          ),

                              const SizedBox(height: 16),

                              // Recordar credenciales
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _rememberCredentials,
                                  onChanged: (value) {
                                        setState(() => _rememberCredentials = value ?? false);
                                  },
                                  activeColor: accentColor,
                                  checkColor: Colors.white,
                                  side: BorderSide(
                                    color: _rememberCredentials ? accentColor : borderColor,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                        setState(() => _rememberCredentials = !_rememberCredentials);
                                  },
                                  child: Text(
                                        'Recordar credenciales',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                              const SizedBox(height: 24),

                          // Botón de login
                          SizedBox(
                            width: double.infinity,
                                height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: accentColor.withAlpha(150),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                      child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                              'Iniciar Sesión',
                                          style: GoogleFonts.inter(
                                                fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                          ),
                                        ),
                                            const SizedBox(width: 10),
                                            const Icon(Iconsax.arrow_right_3, size: 20),
                                      ],
                                    ),
                            ),
                          ),
                            ],
                          ),
                              ),
                          ),

                          const SizedBox(height: 24),

                      // Footer
                      Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                              _buildFeatureBadge(Iconsax.calendar_2, 'Citas', accentColor, mutedColor, borderColor),
                                    const SizedBox(width: 8),
                              _buildFeatureBadge(Iconsax.scissor, 'Servicios', accentColor, mutedColor, borderColor),
                                    const SizedBox(width: 8),
                              _buildFeatureBadge(Iconsax.wallet, 'Finanzas', accentColor, mutedColor, borderColor),
                                  ],
                                ),
                          const SizedBox(height: 12),
                                Text(
                            'Desarrollado por COWIB',
                                  style: GoogleFonts.inter(
                              fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: mutedColor.withAlpha(150),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color accentColor, Color textColor, Color mutedColor) {
    return Column(
      children: [
        // Logo circular con efecto
        Container(
          width: 70,
          height: 70,
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
            boxShadow: [
              BoxShadow(
                color: accentColor.withAlpha(60),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: Image.asset(
              'assets/images/logo3.png',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Iconsax.scissor5,
                  color: Colors.white,
                  size: 35,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'BARBERPRO',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sistema de Gestión Profesional',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: mutedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required IconData icon,
    required Color accentColor,
    required Color accentLight,
    required Color textColor,
    required Color mutedColor,
    required Color borderColor,
    required Color cardColor,
    String? hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFocused ? accentColor : borderColor,
              width: isFocused ? 2 : 1,
            ),
            color: isFocused ? accentLight.withAlpha(30) : cardColor,
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: accentColor.withAlpha(20),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: mutedColor.withAlpha(150),
              ),
              prefixIcon: Icon(
                icon,
                color: isFocused ? accentColor : mutedColor,
                size: 22,
              ),
              suffixIcon: suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: suffixIcon,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureBadge(IconData icon, String label, Color accentColor, Color mutedColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accentColor, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

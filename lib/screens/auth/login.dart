import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:simple_icons/simple_icons.dart';
import '../../main_theme.dart';
import '../../widgets/responsive_centered_body.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth/social_auth_service.dart';
import '../../services/storage/credentials_storage.dart';
import '../../utils/audio_helper.dart';
import 'privacy_security_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _userFocused = false;
  bool _passFocused = false;
  bool _rememberCredentials = false;
  bool _appleSignInAvailable = false;

  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userFocus = FocusNode();
  final _passFocus = FocusNode();
  final _credentialsStorage = CredentialsStorage();
  final _socialAuth = SocialAuthService();

  @override
  void initState() {
    super.initState();
    _userFocus.addListener(
      () => setState(() => _userFocused = _userFocus.hasFocus),
    );
    _passFocus.addListener(
      () => setState(() => _passFocused = _passFocus.hasFocus),
    );
    _loadSavedCredentials();
    _socialAuth.isAppleSignInAvailable().then((v) {
      if (mounted) setState(() => _appleSignInAvailable = v);
    });
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
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
        // Reproducir audio de error
        AudioHelper.playError();

        setState(() {
          _errorMessage = authState.errorMessage ?? 'Credenciales inválidas';
        });
      } else {
        // Reproducir audio de éxito
        AudioHelper.playSuccess();

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
      // Reproducir audio de error
      AudioHelper.playError();

      setState(() {
        _errorMessage = 'Error de conexión';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithSocial(
    Future<String> Function() getIdToken,
    Future<bool> Function(String idToken) loginWithToken,
    String fallbackError,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final idToken = await getIdToken();
      final success = await loginWithToken(idToken);
      if (!mounted) return;
      if (!success) {
        final authState = ref.read(authNotifierProvider);
        AudioHelper.playError();
        setState(() => _errorMessage = authState.errorMessage ?? fallbackError);
      } else {
        AudioHelper.playSuccess();
      }
    } catch (e) {
      if (mounted) {
        AudioHelper.playError();
        setState(
          () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onAppleSignInTap(
    BuildContext context,
    Color borderColor,
    Color mutedColor,
  ) {
    if (_appleSignInAvailable) {
      _signInWithSocial(
        _socialAuth.getAppleIdToken,
        (id) =>
            ref.read(authNotifierProvider.notifier).loginWithApple(idToken: id),
        'Error con Apple',
      );
      return;
    }
    // En Android (y donde no esté disponible), mostrar mensaje claro
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Iniciar sesión con Apple',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Iniciar sesión con Apple no está disponible en este dispositivo. '
          'Puedes usar Google o tu correo y contraseña para acceder a tu cuenta.',
          style: GoogleFonts.inter(fontSize: 14, color: mutedColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Entendido',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enterDemoMode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.enableDemoMode();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al entrar en modo demo: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const accentColor = Color(0xFF10B981);

    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = isSmallScreen ? 20.0 : 24.0;
    final fieldSpacing = isSmallScreen ? 12.0 : 14.0;
    final buttonHeight = isSmallScreen ? 48.0 : 52.0;
    const textColor = Color(0xFF111827);
    const mutedColor = Color(0xFF6B7280);
    const borderColor = Color(0xFFE5E7EB);
    const pageBg = Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemMovilTheme.getStatusBarStyle(false),
      child: Scaffold(
        backgroundColor: pageBg,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: ResponsiveCenteredBody(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: isSmallScreen ? 88 : 96,
                          height: isSmallScreen ? 88 : 96,
                          child: Image.asset(
                            'assets/images/logobarbe.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          'Bienvenido a BarbeNic',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 24 : 27,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Inicia sesion para continuar',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: mutedColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
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
                                      fontSize: 13,
                                      color: const Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        _buildTextField(
                          context: context,
                          label: 'Email',
                          controller: _userController,
                          focusNode: _userFocus,
                          isFocused: _userFocused,
                          icon: Iconsax.sms,
                          keyboardType: TextInputType.emailAddress,
                          hintText: 'tu@email.com',
                          validator: (v) => v == null || v.isEmpty
                              ? 'El email es requerido'
                              : null,
                          accentColor: accentColor,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          borderColor: borderColor,
                        ),
                        SizedBox(height: fieldSpacing),
                        _buildTextField(
                          context: context,
                          label: 'Contraseña',
                          controller: _passwordController,
                          focusNode: _passFocus,
                          isFocused: _passFocused,
                          icon: Iconsax.lock,
                          obscureText: _obscurePassword,
                          hintText: '••••••••',
                          validator: (v) => v == null || v.isEmpty
                              ? 'La contraseña es requerida'
                              : null,
                          accentColor: accentColor,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          borderColor: borderColor,
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Iconsax.eye_slash
                                  : Iconsax.eye,
                              size: 19,
                              color: mutedColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => setState(
                            () => _rememberCredentials = !_rememberCredentials,
                          ),
                          child: Row(
                            children: [
                              Checkbox.adaptive(
                                value: _rememberCredentials,
                                onChanged: (v) => setState(
                                  () => _rememberCredentials = v ?? false,
                                ),
                                activeColor: accentColor,
                                side: BorderSide(color: borderColor),
                              ),
                              Text(
                                'Recordar credenciales',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
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
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Continuar',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Divider(color: borderColor)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                'o continua con',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: mutedColor,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: borderColor)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialButton(
                              onTap: _isLoading
                                  ? null
                                  : () => _signInWithSocial(
                                      _socialAuth.getGoogleIdToken,
                                      (id) => ref
                                          .read(authNotifierProvider.notifier)
                                          .loginWithGoogle(idToken: id),
                                      'Error con Google',
                                    ),
                              icon: Icon(
                                SimpleIcons.google,
                                size: 21,
                                color: SimpleIconColors.google,
                              ),
                              borderColor: borderColor,
                            ),
                            const SizedBox(width: 12),
                            _socialButton(
                              onTap: _isLoading
                                  ? null
                                  : () => _onAppleSignInTap(
                                      context,
                                      borderColor,
                                      mutedColor,
                                    ),
                              icon: Icon(
                                SimpleIcons.apple,
                                size: 21,
                                color: SimpleIconColors.apple,
                              ),
                              borderColor: borderColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.of(
                                    context,
                                  ).pushNamed(RegisterScreen.routeName),
                            child: const Text('¿No tienes cuenta? Regístrate'),
                          ),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.of(
                                    context,
                                  ).pushNamed(PrivacySecurityScreen.routeName),
                            child: Text(
                              'Privacidad y seguridad',
                              style: GoogleFonts.inter(color: mutedColor),
                            ),
                          ),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: _isLoading ? null : _enterDemoMode,
                            child: Text(
                              'Ver demo',
                              style: GoogleFonts.inter(color: accentColor),
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
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required IconData icon,
    required Color accentColor,
    required Color textColor,
    required Color mutedColor,
    required Color borderColor,
    String? hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final inputFontSize = isSmallScreen ? 14.0 : 15.0;
    final hintFontSize = isSmallScreen ? 13.0 : 14.0;
    final iconSize = isSmallScreen ? 20.0 : 22.0;
    final inputPadding = isSmallScreen ? 12.0 : 14.0;
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
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isFocused ? accentColor : borderColor.withAlpha(100),
              width: isFocused ? 2 : 1.5,
            ),
            color: Colors.white,
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: accentColor.withAlpha(15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            style: GoogleFonts.inter(
              fontSize: inputFontSize,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                fontSize: hintFontSize,
                color: mutedColor.withAlpha(150),
              ),
              prefixIcon: Icon(
                icon,
                color: isFocused ? accentColor : mutedColor,
                size: iconSize,
              ),
              suffixIcon: suffixIcon != null
                  ? Padding(
                      padding: EdgeInsets.only(right: isSmallScreen ? 12 : 16),
                      child: suffixIcon,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: inputPadding,
                vertical: inputPadding,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _socialButton({
    required VoidCallback? onTap,
    required Widget icon,
    required Color borderColor,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: icon,
        ),
      ),
    );
  }
}

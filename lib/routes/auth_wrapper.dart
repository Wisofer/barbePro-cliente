import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login.dart';
import '../screens/home_screen.dart';
import '../main_theme.dart';

class AuthWrapper extends StatefulWidget {
  static const String routeName = '/auth-wrapper';

  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    // Mostrar splash por mínimo 2 segundos
    _splashTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar splash por tiempo fijo independientemente del AuthProvider
    if (_showSplash) {
      return const _SplashScreen();
    }

    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);
        
        // Si aún no se ha inicializado, mostrar splash
        if (!authState.isInitialized) {
          return const _SplashScreen();
        }

        // Si está autenticado, ir al home
        if (authState.isAuthenticated) {
          return const HomeScreen();
        }

        // Si no está autenticado, mostrar login
        return const LoginScreen();
      },
    );
  }
}

/// Splash screen simple
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SystemMovilColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o icono de la app
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.apps_rounded,
                size: 60,
                color: SystemMovilColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'System Movil',
              style: SystemMovilTypography.h1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

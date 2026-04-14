import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/trial_expired_provider.dart';
import '../screens/auth/login.dart';
import '../screens/auth/trial_expired_screen.dart';
import '../screens/home_screen.dart';
import '../widgets/splash_screen.dart';

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
      return const SplashScreen();
    }

    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);
        
        // Si aún no se ha inicializado, mostrar splash
        if (!authState.isInitialized) {
          return const SplashScreen();
        }

        if (authState.isAuthenticated) {
          final trialFlag = ref.watch(trialExpiredNotifierProvider);
          final profile = authState.userProfile;
          final sub = authState.subscription;
          final subExpired = sub != null && sub.isExpired && !sub.hasAccess;
          final profileExpired = profile != null && profile.isTrialExpired;
          if (trialFlag || subExpired || profileExpired) {
            return const TrialExpiredScreen();
          }
          return const HomeScreen();
        }

        // Si no está autenticado, mostrar login
        return const LoginScreen();
      },
    );
  }
}

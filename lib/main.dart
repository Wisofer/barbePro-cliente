import 'package:system_movil/services/navigation/navigation_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:system_movil/firebase_options.dart';
import 'package:system_movil/services/notification/flutter_local_notifications.dart';
import 'utils/app_localizations.dart';
import 'utils/snackbar_helper.dart';
import 'providers/settings/settings_notifier.dart';
import 'routes/auth_wrapper.dart';
import 'main_theme.dart';
import 'screens/auth/login.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Asegurar que la UI del sistema sea visible
  SystemChrome.setEnabledSystemUIMode(  
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // ✅ Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // ✅ Inicializar notificaciones locales
    await FlutterLocalNotifications.init();
  } catch (e) {
    // Manejar error silenciosamente - Firebase puede no estar configurado aún
  }

  runApp(const ProviderScope(child: SystemMovilApp()));
}

class SystemMovilApp extends StatelessWidget {
  const SystemMovilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final settings = ref.watch(settingsNotifierProvider);
        return MaterialApp(
          title: 'BarbeNic',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: settings.themeMode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale(settings.language),
          navigatorKey: NavigationService.navigatorKey,
          scaffoldMessengerKey: SnackbarHelper.scaffoldMessengerKey,
          initialRoute: AuthWrapper.routeName,
          routes: {
            AuthWrapper.routeName: (context) => const AuthWrapper(),
            LoginScreen.routeName: (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
          },
          debugShowCheckedModeBanner: false,
          builder: (context, child) => _AuthSideEffects(child: child),
        );
      },
    );
  }
}

class _AuthSideEffects extends ConsumerStatefulWidget {
  const _AuthSideEffects({required this.child});
  final Widget? child;

  @override
  ConsumerState<_AuthSideEffects> createState() => _AuthSideEffectsState();
}

class _AuthSideEffectsState extends ConsumerState<_AuthSideEffects> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: widget.child ?? const SizedBox.shrink(),
    );
  }
}

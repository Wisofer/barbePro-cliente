import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/app_navbar.dart';
import '../widgets/responsive_centered_body.dart';
import '../utils/role_helper.dart';
import '../providers/auth_provider.dart';
import '../providers/pending_appointments_provider.dart';
import '../providers/trial_welcome_shown_provider.dart';
import '../services/storage/trial_welcome_storage.dart';
import '../widgets/trial_welcome_modal.dart';
import 'dashboard/dashboard_screen.dart';
import 'appointments/appointments_screen.dart';
import 'services/services_screen.dart';
import 'finances/finances_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey();
  
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onHomeReady());
  }

  Future<void> _onHomeReady() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    try {
      await ref.read(authNotifierProvider.notifier).initializeNotifications();
    } catch (_) {}
    if (!mounted) return;
    await _maybeShowTrialWelcome();
  }

  Future<void> _maybeShowTrialWelcome() async {
    if (!mounted) return;
    final sub = ref.read(authNotifierProvider).subscription;
    if (sub == null || !sub.isTrial) return;
    final trialEndsAt = sub.trialEndsAt;
    if (trialEndsAt == null || trialEndsAt.isBefore(DateTime.now())) return;
    if (ref.read(trialWelcomeShownProvider)) return;
    final alreadyShown = await TrialWelcomeStorage.getShown();
    if (alreadyShown) return;
    ref.read(trialWelcomeShownProvider.notifier).state = true;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TrialWelcomeModal(
        subscription: sub,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
    if (!mounted) return;
    await TrialWelcomeStorage.setShown(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Cuando la app vuelve al foreground, actualizar contador de pendientes
    if (state == AppLifecycleState.resumed) {
      ref.read(authNotifierProvider.notifier).loadUserProfile();
      ref.read(pendingAppointmentsProvider.notifier).refresh();
    }
  }

  // Mapeo de índices visibles a índices reales de pantallas
  int _getRealIndex(int visibleIndex) {
    final isEmployee = RoleHelper.isEmployee(ref);
    
    if (isEmployee) {
      // Para trabajadores: visibleIndex 0 = Citas (real 1), 1 = Servicios (real 2), 2 = Finanzas (real 3), 3 = Perfil (real 4)
      const employeeMapping = [1, 2, 3, 4];
      return employeeMapping[visibleIndex];
    } else {
      // Para barberos: índice visible = índice real
      return visibleIndex;
    }
  }

  int _getVisibleIndex(int realIndex) {
    final isEmployee = RoleHelper.isEmployee(ref);
    
    if (isEmployee) {
      // Mapeo inverso para trabajadores
      const employeeMapping = {1: 0, 2: 1, 3: 2, 4: 3};
      return employeeMapping[realIndex] ?? 0;
    } else {
      return realIndex;
    }
  }

  void _onTabChanged(int visibleIndex) {
    final realIndex = _getRealIndex(visibleIndex);
    final wasDashboard = _selectedIndex == 0 && !RoleHelper.isEmployee(ref);
    
    setState(() {
      _selectedIndex = realIndex;
    });
    
    // Refrescar dashboard solo si se vuelve a mostrar después de estar en otra pestaña
    if (realIndex == 0 && !wasDashboard && !RoleHelper.isEmployee(ref)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dashboardKey.currentState?.refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEmployee = RoleHelper.isEmployee(ref);
    
    final bgColor = isDark ? const Color(0xFF0A0A0B) : Colors.white;
    
    // Inicializar índice según el rol (solo una vez)
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedIndex = isEmployee ? 1 : 0; // Employee inicia en Citas (1), Barber en Dashboard (0)
            _initialized = true;
          });
        }
      });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemMovilTheme.getStatusBarStyle(isDark),
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header fijo - Solo en Dashboard (y solo para Barber)
              if (_selectedIndex == 0 && RoleHelper.isBarber(ref)) const AppHeader(),

              // Contenido
              Expanded(
                child: ResponsiveCenteredBody(
                  child: Builder(
                    builder: (context) {
                      final isEmployee = RoleHelper.isEmployee(ref);
                      final screens = <Widget>[
                        isEmployee
                            ? const SizedBox.shrink()
                            : DashboardScreen(
                                key: _dashboardKey,
                                onNavigateToAppointments: () {
                                  final visibleIndex = _getVisibleIndex(1);
                                  _onTabChanged(visibleIndex);
                                },
                                onNavigateToServices: () {
                                  final visibleIndex = _getVisibleIndex(2);
                                  _onTabChanged(visibleIndex);
                                },
                                onNavigateToFinances: () {
                                  final visibleIndex = _getVisibleIndex(3);
                                  _onTabChanged(visibleIndex);
                                },
                              ),
                        const AppointmentsScreen(),
                        const ServicesScreen(),
                        const FinancesScreen(),
                        const ProfileScreen(),
                      ];

                      return IndexedStack(
                        index: _selectedIndex,
                        children: screens,
                      );
                    },
                  ),
                ),
              ),

              // Navbar fijo
              AppNavbar(
                currentIndex: _getVisibleIndex(_selectedIndex),
                onTap: _onTabChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

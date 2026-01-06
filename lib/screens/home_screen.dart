import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/app_navbar.dart';
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

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey();

  void _onTabChanged(int index) {
    final wasDashboard = _selectedIndex == 0;
    setState(() {
      _selectedIndex = index;
    });
    // Refrescar dashboard solo si se vuelve a mostrar después de estar en otra pestaña
    if (index == 0 && !wasDashboard) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dashboardKey.currentState?.refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bgColor = isDark ? const Color(0xFF0A0A0B) : const Color(0xFFF0FDF4);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemMovilTheme.getStatusBarStyle(isDark),
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header fijo - Solo en Dashboard
              if (_selectedIndex == 0) const AppHeader(),

              // Contenido
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    DashboardScreen(key: _dashboardKey),
                    const AppointmentsScreen(),
                    const ServicesScreen(),
                    const FinancesScreen(),
                    const ProfileScreen(),
                  ],
                ),
              ),

              // Navbar fijo
              AppNavbar(
                currentIndex: _selectedIndex,
                onTap: _onTabChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

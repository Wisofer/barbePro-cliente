import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/role_helper.dart';

class AppNavbar extends ConsumerWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const AppNavbar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  static const _allItems = [
    _NavItem(icon: Iconsax.home_2, activeIcon: Iconsax.home_25, label: 'Inicio', id: 'dashboard'),
    _NavItem(icon: Iconsax.calendar_2, activeIcon: Iconsax.calendar_25, label: 'Citas', id: 'appointments'),
    _NavItem(icon: Iconsax.scissor, activeIcon: Iconsax.scissor, label: 'Servicios', id: 'services'),
    _NavItem(icon: Iconsax.wallet, activeIcon: Iconsax.wallet, label: 'Finanzas', id: 'finances'),
    _NavItem(icon: Iconsax.profile_circle, activeIcon: Iconsax.profile_circle5, label: 'Perfil', id: 'profile'),
  ];

  List<_NavItem> _getVisibleItems(WidgetRef ref) {
    final isEmployee = RoleHelper.isEmployee(ref);
    
    if (isEmployee) {
      // Trabajadores ven: Citas, Servicios (solo lectura), Finanzas, Perfil
      return _allItems.where((item) => 
        item.id == 'appointments' || 
        item.id == 'services' ||
        item.id == 'finances' || 
        item.id == 'profile'
      ).toList();
    } else {
      // Barberos ven todas las opciones: Inicio, Citas, Servicios, Finanzas, Perfil
      return _allItems;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFD1D5DB);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
    const accentColor = Color(0xFF10B981); // Verde suave

    final visibleItems = _getVisibleItems(ref);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(visibleItems.length, (index) {
              final item = visibleItems[index];
              final isActive = index == currentIndex;

              return _NavItemWidget(
                icon: isActive ? item.activeIcon : item.icon,
                label: item.label,
                isActive: isActive,
                activeColor: accentColor,
                inactiveColor: mutedColor,
                onTap: () => onTap?.call(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String id;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.id,
  });
}

class _NavItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback? onTap;

  const _NavItemWidget({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withAlpha(15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

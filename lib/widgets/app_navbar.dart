import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

class AppNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const AppNavbar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  static const _items = [
    _NavItem(icon: Iconsax.home_2, activeIcon: Iconsax.home_25, label: 'Inicio'),
    _NavItem(icon: Iconsax.calendar_2, activeIcon: Iconsax.calendar_25, label: 'Citas'),
    _NavItem(icon: Iconsax.scissor, activeIcon: Iconsax.scissor, label: 'Servicios'), // Mismo icono, solo cambia color
    _NavItem(icon: Iconsax.wallet, activeIcon: Iconsax.wallet, label: 'Finanzas'), // Mismo icono, solo cambia color
    _NavItem(icon: Iconsax.profile_circle, activeIcon: Iconsax.profile_circle5, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFD1D5DB);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
    const accentColor = Color(0xFF10B981); // Verde suave

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
          children: List.generate(_items.length, (index) {
            final item = _items[index];
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

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
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

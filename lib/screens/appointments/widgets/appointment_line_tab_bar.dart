import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppointmentLineTabBar extends StatefulWidget {
  const AppointmentLineTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.tabs,
    this.tabBadges = const [],
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
    this.isSmallScreen = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<String> tabs;
  final List<int?> tabBadges;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;
  final bool isSmallScreen;

  @override
  State<AppointmentLineTabBar> createState() => _AppointmentLineTabBarState();
}

class _AppointmentLineTabBarState extends State<AppointmentLineTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AppointmentLineTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: widget.tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final isSelected = index == widget.selectedIndex;
            final badge =
                index < widget.tabBadges.length ? widget.tabBadges[index] : null;

            return Expanded(
              child: GestureDetector(
                onTap: () => widget.onTabSelected(index),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: widget.isSmallScreen ? 8 : 10,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              label,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: widget.isSmallScreen ? 13 : 14,
                                fontWeight:
                                    isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected
                                    ? widget.textColor
                                    : widget.mutedColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (badge != null && badge > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                badge > 99 ? '99+' : '$badge',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: widget.isSmallScreen ? 5 : 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        height: 1.5,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? widget.accentColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

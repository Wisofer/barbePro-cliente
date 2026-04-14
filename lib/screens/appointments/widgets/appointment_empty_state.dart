import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class AppointmentListEmptyState extends StatelessWidget {
  const AppointmentListEmptyState({
    super.key,
    required this.selectedTab,
    required this.onAddAppointment,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
    this.isSmallScreen = false,
  });

  final int selectedTab;
  final VoidCallback onAddAppointment;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: mutedColor.withAlpha(10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.calendar_remove,
                        color: mutedColor,
                        size: 56,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No hay citas',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      selectedTab == 0
                          ? 'No tienes citas programadas para hoy'
                          : 'No tienes citas pendientes',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: mutedColor,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: onAddAppointment,
                      icon: const Icon(Iconsax.add, size: 18),
                      label: const Text('Agregar Cita'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

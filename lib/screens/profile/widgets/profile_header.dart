import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/barber.dart';
import '../edit_profile_screen.dart';

class ProfileHeader extends StatelessWidget {
  final BarberDto profile;
  final VoidCallback onProfileUpdated;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar con logo
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor,
                  const Color(0xFF059669),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logobarbe.png',
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Iconsax.scissor5,
                    color: Colors.white,
                    size: 32,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  profile.name,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
                if (profile.email != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Iconsax.sms, size: 14, color: mutedColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          profile.email!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: mutedColor,
                            height: 1.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Iconsax.call, size: 14, color: mutedColor),
                    const SizedBox(width: 6),
                    Text(
                      profile.phone,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: mutedColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Botón editar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(profile: profile),
                  ),
                );
                if (updated == true) {
                  onProfileUpdated();
                }
              },
              icon: Icon(Iconsax.edit_2, color: accentColor, size: 18),
              padding: EdgeInsets.zero,
              tooltip: 'Editar perfil',
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/barber.dart';
import '../edit_profile_screen.dart';

class ProfileHeader extends StatelessWidget {
  final BarberDto profile;
  final VoidCallback onProfileUpdated;
  /// Cambiar foto (galería/cámara); si es null no se muestra el badge de cámara.
  final VoidCallback? onPhotoTap;
  /// Ver foto en pantalla completa cuando ya hay imagen.
  final VoidCallback? onPhotoViewTap;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;
  final Color accentColor;
  /// Sin borde inferior; para tarjeta redondeada sobre fondo agrupado (estilo iOS).
  final bool iosGrouped;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
    this.onPhotoTap,
    this.onPhotoViewTap,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
    this.iosGrouped = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: iosGrouped ? 16 : 20,
        vertical: iosGrouped ? 18 : 20,
      ),
      decoration: BoxDecoration(
        color: iosGrouped ? Colors.transparent : cardColor,
        border: iosGrouped
            ? null
            : Border(
                bottom: BorderSide(color: borderColor, width: 1),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  final hasPhoto = profile.profileImageUrl != null &&
                      profile.profileImageUrl!.isNotEmpty;
                  if (hasPhoto && onPhotoViewTap != null) {
                    onPhotoViewTap!();
                  } else if (onPhotoTap != null) {
                    onPhotoTap!();
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
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
                        color: accentColor.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: profile.profileImageUrl != null &&
                            profile.profileImageUrl!.isNotEmpty
                        ? Image.network(
                            profile.profileImageUrl!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderAvatar();
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.white,
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: accentColor,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                ),
                              );
                            },
                          )
                        : _buildPlaceholderAvatar(),
                  ),
                ),
              ),
              if (onPhotoTap != null)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: GestureDetector(
                    onTap: onPhotoTap,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Iconsax.camera,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  profile.name,
                  style: GoogleFonts.inter(
                    fontSize: iosGrouped ? 17 : 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.2,
                    letterSpacing: -0.3,
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

  Widget _buildPlaceholderAvatar() {
    return Container(
      color: Colors.white,
      child: Image.asset(
        'assets/images/logobarbe.png',
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Iconsax.scissor5,
            color: Colors.white,
            size: 28,
          );
        },
      ),
    );
  }
}

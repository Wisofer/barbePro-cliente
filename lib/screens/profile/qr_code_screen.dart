import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../models/barber.dart';
import '../../models/auth.dart';
import '../../services/api/barber_service.dart';
import 'widgets/profile_ios_section.dart';

class QrCodeScreen extends ConsumerStatefulWidget {
  final BarberDto profile;

  const QrCodeScreen({super.key, required this.profile});

  @override
  ConsumerState<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends ConsumerState<QrCodeScreen> {
  QrResponse? _qrData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQrCode();
  }

  Future<void> _loadQrCode() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(barberServiceProvider);
      final qrData = await service.getQrCode();
      if (mounted) {
        setState(() {
          _qrData = qrData;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.data?['message'] ?? 'Error al cargar el QR'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _shareQr() async {
    if (_qrData == null) return;
    
    try {
      // Decodificar el Base64 del QR
      final base64String = _qrData!.qrCode;
      
      // Remover el prefijo "data:image/png;base64," si existe
      final cleanBase64 = base64String.contains(',') 
          ? base64String.split(',').last 
          : base64String;
      
      // Decodificar Base64 a bytes
      final bytes = base64Decode(cleanBase64);
      
      // Obtener directorio temporal
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png');
      
      // Escribir el archivo
      await file.writeAsBytes(bytes);
      
      // Crear XFile para compartir
      final xFile = XFile(file.path);
      
      // Texto del mensaje
      final message = 'Escanea este código QR para agendar tu cita con ${widget.profile.name}\n\n${_qrData!.url}';
      
      // Compartir la imagen PNG con el mensaje
      await Share.shareXFiles(
        [xFile],
        text: message,
        subject: 'Código QR - ${widget.profile.businessName ?? widget.profile.name}',
      );
      
      // Limpiar archivo temporal después de compartir (opcional, se limpia automáticamente)
      // await file.delete();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir el QR: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8);
    final groupedBg = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final sectionHeaderColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D72);
    const accentColor = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: groupedBg,
      appBar: AppBar(
        title: Text(
          'Código QR',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        backgroundColor: groupedBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading && _qrData != null)
            IconButton(
              icon: const Icon(Iconsax.refresh),
              onPressed: _loadQrCode,
              tooltip: 'Actualizar',
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : _qrData == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.info_circle, color: mutedColor, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No se pudo cargar el código QR',
                          style: GoogleFonts.inter(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadQrCode,
                          icon: const Icon(Iconsax.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileIosSection(
                        isFirst: true,
                        title: 'Reserva',
                        headerColor: sectionHeaderColor,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        tiles: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Los clientes escanean el código para abrir tu enlace de reserva.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: mutedColor,
                                height: 1.45,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: QrImageView(
                                data: _qrData!.url,
                                version: QrVersions.auto,
                                size: 240,
                                backgroundColor: Colors.white,
                                eyeStyle: QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: accentColor,
                                ),
                                dataModuleStyle: QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ProfileIosSection(
                        title: 'Enlace',
                        headerColor: sectionHeaderColor,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        tiles: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  widget.profile.businessName ?? widget.profile.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                SelectableText(
                                  _qrData!.url,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: mutedColor,
                                    height: 1.35,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _shareQr,
                            icon: const Icon(Iconsax.send_2, size: 18),
                            label: Text(
                              'Compartir',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}


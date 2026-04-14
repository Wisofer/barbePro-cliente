import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import '../../services/api/export_service.dart';
import 'widgets/ios_grouped_row.dart';
import 'widgets/profile_ios_section.dart';

class ExportDataScreen extends ConsumerStatefulWidget {
  const ExportDataScreen({super.key});

  @override
  ConsumerState<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends ConsumerState<ExportDataScreen> {
  bool _isExporting = false;
  String? _exportingType;

  Future<void> _exportReport(String type, String format) async {
    setState(() {
      _isExporting = true;
      _exportingType = type;
    });

    try {
      final service = ref.read(exportServiceProvider);
      File? file;

      switch (type) {
        case 'Citas':
          file = await service.exportAppointments(format: format);
          break;
        case 'Financiero':
          file = await service.exportFinances(format: format);
          break;
        case 'Clientes':
          file = await service.exportClients(format: format);
          break;
        case 'Backup Completo':
          file = await service.exportBackup();
          break;
      }

      if (mounted && file != null) {
        setState(() {
          _isExporting = false;
          _exportingType = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reporte de $type generado exitosamente'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );

        // Compartir archivo
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Reporte $type - BarbeNic',
        );
      }
    } on DioException catch (e) {
      String message = 'Error al exportar el reporte';
      
      // Manejar diferentes tipos de respuesta de error
      if (e.response?.data != null) {
        try {
          // Si data es una lista de bytes (Uint8List), decodificarla
          if (e.response!.data is List<int>) {
            final bytes = e.response!.data as List<int>;
            final jsonString = utf8.decode(bytes);
            final jsonData = json.decode(jsonString);
            message = jsonData['message'] ?? message;
          } 
          // Si data es un Map, extraer el mensaje directamente
          else if (e.response!.data is Map) {
            message = e.response!.data['message'] ?? message;
          }
          // Si data es un String, usarlo directamente
          else if (e.response!.data is String) {
            message = e.response!.data;
          }
        } catch (decodeError) {
          // Si falla la decodificación, usar mensaje por defecto
          message = 'Error del servidor. Por favor, intenta más tarde.';
        }
      }
      
      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportingType = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportingType = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _showFormatDialog(String type) async {
    final format = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Seleccionar Formato',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.document),
              title: const Text('CSV'),
              onTap: () => Navigator.pop(context, 'csv'),
            ),
            ListTile(
              leading: const Icon(Iconsax.document),
              title: const Text('Excel'),
              onTap: () => Navigator.pop(context, 'excel'),
            ),
            if (type != 'Backup Completo')
              ListTile(
                leading: const Icon(Iconsax.document),
                title: const Text('PDF'),
                onTap: () => Navigator.pop(context, 'pdf'),
              ),
          ],
        ),
      ),
    );

    if (format != null) {
      await _exportReport(type, format);
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

    Widget? trailingFor(String type) {
      final loading = _isExporting && _exportingType == type;
      if (loading) {
        return const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: accentColor,
          ),
        );
      }
      return Icon(
        Iconsax.arrow_right_3,
        color: mutedColor.withValues(alpha: 0.5),
        size: 16,
      );
    }

    return Scaffold(
      backgroundColor: groupedBg,
      appBar: AppBar(
        title: Text(
          'Exportar datos',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        backgroundColor: groupedBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                'Genera archivos para revisar o respaldar tu información.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: mutedColor,
                  height: 1.4,
                ),
              ),
            ),
            ProfileIosSection(
              isFirst: true,
              title: 'Reportes',
              headerColor: sectionHeaderColor,
              cardColor: cardColor,
              borderColor: borderColor,
              tiles: [
                IosGroupedRow(
                  icon: Iconsax.document_download,
                  title: 'Citas',
                  subtitle: (_isExporting && _exportingType == 'Citas')
                      ? 'Exportando…'
                      : 'Todas las citas del periodo',
                  trailing: trailingFor('Citas'),
                  onTap: (_isExporting && _exportingType == 'Citas')
                      ? null
                      : () => _showFormatDialog('Citas'),
                  accentColor: accentColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
                IosGroupedRow(
                  icon: Iconsax.wallet_money,
                  title: 'Financiero',
                  subtitle: (_isExporting && _exportingType == 'Financiero')
                      ? 'Exportando…'
                      : 'Ingresos y egresos',
                  trailing: trailingFor('Financiero'),
                  onTap: (_isExporting && _exportingType == 'Financiero')
                      ? null
                      : () => _showFormatDialog('Financiero'),
                  accentColor: accentColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
                IosGroupedRow(
                  icon: Iconsax.profile_2user,
                  title: 'Clientes',
                  subtitle: (_isExporting && _exportingType == 'Clientes')
                      ? 'Exportando…'
                      : 'Lista de clientes',
                  trailing: trailingFor('Clientes'),
                  onTap: (_isExporting && _exportingType == 'Clientes')
                      ? null
                      : () => _showFormatDialog('Clientes'),
                  accentColor: accentColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
              ],
            ),
            ProfileIosSection(
              title: 'Respaldo',
              headerColor: sectionHeaderColor,
              cardColor: cardColor,
              borderColor: borderColor,
              tiles: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Copia de seguridad completa de tus datos (JSON).',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: mutedColor,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: (_isExporting && _exportingType == 'Backup Completo')
                              ? null
                              : () => _exportReport('Backup Completo', 'json'),
                          icon: (_isExporting && _exportingType == 'Backup Completo')
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Iconsax.document_cloud, size: 20),
                          label: Text(
                            (_isExporting && _exportingType == 'Backup Completo')
                                ? 'Exportando…'
                                : 'Crear backup',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../models/barber.dart';
import '../../services/api/barber_service.dart';
import 'widgets/profile_ios_section.dart' show IosGroupedCard;

/// Plataformas sugeridas (API acepta cualquier string hasta 50 caracteres)
const List<String> kPlatformOptions = [
  'Facebook',
  'Instagram',
  'TikTok',
  'YouTube',
  'X',
  'Otro',
];

/// Icono por plataforma (chips y tarjetas)
IconData _iconForPlatformName(String platform) {
  final p = platform.toLowerCase();
  if (p.contains('facebook')) return Iconsax.link_1;
  if (p.contains('instagram')) return Iconsax.instagram;
  if (p.contains('tiktok')) return Iconsax.video_play;
  if (p.contains('whatsapp')) return Iconsax.message;
  if (p.contains('youtube')) return Iconsax.play_circle;
  if (p == 'x' || p.contains('twitter')) return Iconsax.link_1;
  if (p.contains('linkedin')) return Iconsax.link_1;
  return Iconsax.link_1;
}

class SocialLinksScreen extends ConsumerStatefulWidget {
  const SocialLinksScreen({super.key});

  @override
  ConsumerState<SocialLinksScreen> createState() => _SocialLinksScreenState();
}

class _SocialLinksScreenState extends ConsumerState<SocialLinksScreen> {
  List<SocialLinkDto> _links = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSocialLinks();
  }

  Future<void> _loadSocialLinks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(barberServiceProvider);
      final list = await service.getSocialLinks();
      if (mounted) {
        setState(() {
          _links = list;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      String message = 'Error al cargar las redes sociales';
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      } else if (data is String) {
        message = data;
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = statusCode != null ? 'Error $statusCode: $message' : message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  static bool _isValidUrl(String url) {
    final t = url.trim();
    if (t.isEmpty) return false;
    return t.startsWith('http://') || t.startsWith('https://');
  }

  Future<void> _showAddOrEditSheet({SocialLinkDto? existing, int? index}) async {
    final isOther = existing != null && !kPlatformOptions.contains(existing.platform) && existing.platform.isNotEmpty;
    final platformController = TextEditingController(text: isOther ? existing.platform : '');
    final urlController = TextEditingController(text: existing?.url ?? '');
    String selectedPlatform = existing == null
        ? kPlatformOptions.first
        : (kPlatformOptions.contains(existing.platform) ? existing.platform : 'Otro');

    if (!mounted) return;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF18181B) : Colors.white;
    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
    const accentColor = Color(0xFF10B981);

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final showOtherField = selectedPlatform == 'Otro';
            return Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: mutedColor.withAlpha(120),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Header con gradiente
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accentColor.withAlpha(35),
                                accentColor.withAlpha(15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Iconsax.link_circle,
                                size: 40,
                                color: accentColor,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                existing == null ? 'Añadir red social' : 'Editar enlace',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Aparecerá en tu página de reservas',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: mutedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Plataforma
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Elige la plataforma',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: kPlatformOptions.map((platform) {
                              final isSelected = selectedPlatform == platform;
                              return _PlatformChip(
                                label: platform,
                                isSelected: isSelected,
                                onTap: () => setSheetState(() => selectedPlatform = platform),
                                accentColor: accentColor,
                                textColor: textColor,
                                mutedColor: mutedColor,
                              );
                            }).toList(),
                          ),
                        ),
                        if (showOtherField) ...[
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              controller: platformController,
                              style: GoogleFonts.inter(color: textColor),
                              decoration: InputDecoration(
                                labelText: 'Nombre de la plataforma',
                                hintText: 'Ej: Pinterest, Telegram...',
                                labelStyle: GoogleFonts.inter(color: mutedColor),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              maxLength: 50,
                              onChanged: (_) => setSheetState(() {}),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        // URL
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Enlace de tu perfil',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: urlController,
                                  style: GoogleFonts.inter(color: textColor),
                                  decoration: InputDecoration(
                                    hintText: 'Pega aquí la URL (https://...)',
                                    hintStyle: GoogleFonts.inter(color: mutedColor, fontSize: 14),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    counterText: '',
                                  ),
                                  keyboardType: TextInputType.url,
                                  maxLength: 500,
                                  onChanged: (_) => setSheetState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: accentColor.withAlpha(40),
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () async {
                                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                                    final text = data?.text;
                                    if (text != null && text.isNotEmpty) {
                                      urlController.text = text;
                                      setSheetState(() {});
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    child: Icon(Iconsax.document_copy, color: accentColor, size: 22),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, top: 4),
                          child: Text(
                            '${urlController.text.length}/500',
                            style: GoogleFonts.inter(fontSize: 12, color: mutedColor),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Botón principal
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          child: ElevatedButton(
                            onPressed: () {
                              final urlText = urlController.text.trim();
                              final platformName = showOtherField
                                  ? platformController.text.trim()
                                  : selectedPlatform;
                              if (platformName.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Elige o escribe el nombre de la plataforma'),
                                    backgroundColor: const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              if (urlText.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('La URL no puede estar vacía'),
                                    backgroundColor: const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              if (!_isValidUrl(urlText)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('La URL debe comenzar con http:// o https://'),
                                    backgroundColor: const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              Navigator.pop(context, {'platform': platformName, 'url': urlText});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              existing == null ? 'Añadir enlace' : 'Guardar cambios',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
      },
    );

    if (result == null || !mounted) return;

    final platformName = result['platform']!.trim();
    final urlText = result['url']!.trim();
    if (platformName.isEmpty || urlText.isEmpty) return;

    setState(() {
      if (index != null && index >= 0 && index < _links.length) {
        final updated = SocialLinkDto(
          id: _links[index].id,
          platform: platformName,
          url: urlText,
          sortOrder: index,
        );
        _links = [
          ..._links.sublist(0, index),
          updated,
          ..._links.sublist(index + 1),
        ];
      } else {
        final newId = _links.isEmpty ? 1 : (_links.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
        _links = [
          ..._links,
          SocialLinkDto(id: newId, platform: platformName, url: urlText, sortOrder: _links.length),
        ];
      }
    });
  }

  void _removeAt(int index) {
    setState(() {
      _links = [..._links.sublist(0, index), ..._links.sublist(index + 1)];
      for (int i = 0; i < _links.length; i++) {
        _links[i] = SocialLinkDto(
          id: _links[i].id,
          platform: _links[i].platform,
          url: _links[i].url,
          sortOrder: i,
        );
      }
    });
  }

  Future<void> _save() async {
    final toSend = _links
        .where((e) => e.url.trim().isNotEmpty)
        .map((e) => {'platform': e.platform.trim(), 'url': e.url.trim()})
        .toList();

    setState(() => _isSaving = true);

    try {
      final service = ref.read(barberServiceProvider);
      final saved = await service.updateSocialLinks(toSend);
      if (mounted) {
        setState(() {
          _links = saved;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Redes sociales guardadas correctamente'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      String message = 'Error al guardar';
      if (data is Map) {
        if (data['message'] != null) message = data['message'].toString();
        if (data['errors'] != null) message = 'Errores de validación: ${data['errors']}';
      } else if (data is String) {
        message = data;
      }
      if (statusCode == 400) {
        message = 'Datos inválidos. Revisa plataforma y URL.';
      }
      if (statusCode == 401) {
        message = 'Sesión expirada. Inicia sesión de nuevo.';
      }
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
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

    if (_isLoading) {
      return Scaffold(
        backgroundColor: groupedBg,
        appBar: AppBar(
          title: Text(
            'Redes sociales',
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
        body: const Center(child: CircularProgressIndicator(color: accentColor)),
      );
    }

    return Scaffold(
      backgroundColor: groupedBg,
      appBar: AppBar(
        title: Text(
          'Redes sociales',
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
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  )
                : Text(
                    'Guardar',
                    style: GoogleFonts.inter(color: accentColor, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
      body: _errorMessage != null && _links.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.info_circle, color: mutedColor, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar redes sociales',
                      style: GoogleFonts.inter(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: GoogleFonts.inter(color: mutedColor, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadSocialLinks,
                      icon: const Icon(Iconsax.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      (MediaQuery.of(context).padding.top + kToolbarHeight) -
                      32,
                ),
                child: Column(
                  mainAxisAlignment: _links.isEmpty ? MainAxisAlignment.center : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_links.isEmpty) ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Aún no tienes redes. Se mostrarán en tu página de reservas.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: mutedColor,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
                              FilledButton.icon(
                                onPressed: () => _showAddOrEditSheet(),
                                icon: const Icon(Iconsax.add, size: 20),
                                label: const Text('Añadir red social'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Text(
                          'Se muestran en tu página pública. Pulsa Guardar para aplicar los cambios.',
                          style: GoogleFonts.inter(fontSize: 14, color: mutedColor, height: 1.4),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 16, bottom: 6, top: 20),
                        child: Text(
                          'ENLACES',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: sectionHeaderColor,
                          ),
                        ),
                      ),
                      IosGroupedCard(
                        cardColor: cardColor,
                        child: Column(
                          children: [
                            for (final entry in _links.asMap().entries) ...[
                              if (entry.key > 0)
                                Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  indent: 16,
                                  endIndent: 16,
                                  color: borderColor.withValues(alpha: 0.75),
                                ),
                              _SocialLinkGroupedRow(
                                link: entry.value,
                                onTap: () => _showAddOrEditSheet(
                                  existing: entry.value,
                                  index: entry.key,
                                ),
                                onDelete: () => _removeAt(entry.key),
                                textColor: textColor,
                                mutedColor: mutedColor,
                                accentColor: accentColor,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _AddNetworkButton(
                          onPressed: () => _showAddOrEditSheet(),
                          accentColor: accentColor,
                          isDark: isDark,
                          isEmpty: false,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

class _AddNetworkButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color accentColor;
  final bool isDark;
  final bool isEmpty;

  const _AddNetworkButton({
    required this.onPressed,
    required this.accentColor,
    required this.isDark,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accentColor.withAlpha(isDark ? 35 : 25),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.add_circle, color: accentColor, size: 22),
              const SizedBox(width: 10),
              Text(
                'Añadir otra red social',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;

  const _PlatformChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? accentColor.withAlpha(35) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
          child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accentColor : mutedColor.withAlpha(100),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconForPlatformName(label),
                size: 18,
                color: isSelected ? accentColor : mutedColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? accentColor : textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLinkGroupedRow extends StatelessWidget {
  final SocialLinkDto link;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;

  const _SocialLinkGroupedRow({
    required this.link,
    required this.onTap,
    required this.onDelete,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconForPlatformName(link.platform), color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.platform,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      link.url,
                      style: GoogleFonts.inter(fontSize: 12, color: mutedColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.trash),
                onPressed: onDelete,
                color: const Color(0xFFEF4444),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

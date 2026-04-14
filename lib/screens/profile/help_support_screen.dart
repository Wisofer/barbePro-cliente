import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import '../../models/help_support.dart';
import '../../services/api/help_support_service.dart';
import 'widgets/ios_grouped_row.dart';
import 'widgets/profile_ios_section.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  HelpSupportDto? _helpSupport;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHelpSupport();
  }

  Future<void> _loadHelpSupport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(helpSupportServiceProvider);
      final helpSupport = await service.getHelpSupport();

      if (mounted) {
        setState(() {
          _helpSupport = helpSupport;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      String message = 'Error al cargar la ayuda';

      if (statusCode == 404) {
        message = 'Endpoint no encontrado. Verifica la configuración del servidor.';
      } else if (e.response?.data is Map) {
        message = e.response?.data['message'] ?? message;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
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
          'Ayuda y soporte',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accentColor))
          : _helpSupport == null
              ? _ErrorBody(
                  textColor: textColor,
                  mutedColor: mutedColor,
                  errorMessage: _errorMessage,
                  accentColor: accentColor,
                  onRetry: _loadHelpSupport,
                )
              : RefreshIndicator(
                  onRefresh: _loadHelpSupport,
                  color: accentColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ProfileIosSection(
                          isFirst: true,
                          title: 'Contacto',
                          headerColor: sectionHeaderColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          tiles: [
                            IosGroupedRow(
                              icon: Iconsax.sms,
                              title: 'Email',
                              subtitle: _helpSupport!.contact.email,
                              trailing: Icon(
                                Iconsax.arrow_right_3,
                                color: mutedColor.withValues(alpha: 0.5),
                                size: 16,
                              ),
                              onTap: () => _launchUrl(
                                'mailto:${_helpSupport!.contact.email}?subject=Soporte BarbeNic',
                              ),
                              accentColor: accentColor,
                              textColor: textColor,
                              mutedColor: mutedColor,
                            ),
                            IosGroupedRow(
                              icon: Iconsax.global,
                              title: 'Sitio web',
                              subtitle: _helpSupport!.contact.website,
                              trailing: Icon(
                                Iconsax.arrow_right_3,
                                color: mutedColor.withValues(alpha: 0.5),
                                size: 16,
                              ),
                              onTap: () => _launchUrl(_helpSupport!.contact.website),
                              accentColor: accentColor,
                              textColor: textColor,
                              mutedColor: mutedColor,
                            ),
                            ..._helpSupport!.contact.phones.map(
                              (phone) => IosGroupedRow(
                                icon: Iconsax.call,
                                title: 'Teléfono',
                                subtitle: phone,
                                trailing: Icon(
                                  Iconsax.arrow_right_3,
                                  color: mutedColor.withValues(alpha: 0.5),
                                  size: 16,
                                ),
                                onTap: () => _launchUrl('tel:$phone'),
                                accentColor: accentColor,
                                textColor: textColor,
                                mutedColor: mutedColor,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 16,
                            bottom: 6,
                            top: 22,
                          ),
                          child: Text(
                            'PREGUNTAS FRECUENTES',
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
                              for (int i = 0; i < _helpSupport!.faqs.length; i++) ...[
                                _FaqTile(
                                  faq: _helpSupport!.faqs[i],
                                  textColor: textColor,
                                  mutedColor: mutedColor,
                                  borderColor: borderColor,
                                ),
                                if (i < _helpSupport!.faqs.length - 1)
                                  Divider(
                                    height: 1,
                                    thickness: 0.5,
                                    indent: 16,
                                    endIndent: 16,
                                    color: borderColor.withValues(alpha: 0.75),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final Color textColor;
  final Color mutedColor;
  final String? errorMessage;
  final Color accentColor;
  final VoidCallback onRetry;

  const _ErrorBody({
    required this.textColor,
    required this.mutedColor,
    required this.errorMessage,
    required this.accentColor,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.info_circle, color: mutedColor, size: 56),
            const SizedBox(height: 16),
            Text(
              'No se pudo cargar la ayuda',
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: GoogleFonts.inter(
                  color: mutedColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final FaqDto faq;
  final Color textColor;
  final Color mutedColor;
  final Color borderColor;

  const _FaqTile({
    required this.faq,
    required this.textColor,
    required this.mutedColor,
    required this.borderColor,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: widget.textColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                    color: widget.mutedColor,
                    size: 18,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                Text(
                  widget.faq.answer,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: widget.mutedColor,
                    height: 1.5,
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

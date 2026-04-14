import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/appointment.dart';
import '../../services/api/appointment_service.dart';
import '../../services/api/employee_appointment_service.dart';
import '../../utils/responsive_breakpoints.dart';
import '../../utils/role_helper.dart';
import '../../providers/pending_appointments_provider.dart';
import 'appointment_detail_screen.dart';
import 'appointment_history_screen.dart';
import 'create_appointment_screen.dart';
import 'widgets/appointment_empty_state.dart';
import 'widgets/appointment_error_state.dart';
import 'widgets/appointment_line_tab_bar.dart';
import 'widgets/appointment_list_card.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  List<AppointmentDto> _todayAppointments = [];
  List<AppointmentDto> _pendingAppointments = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedTab = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTab);
    _loadAppointments();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pendingAppointmentsProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      late final List<AppointmentDto> todayList;
      late final List<AppointmentDto> pendingList;

      if (RoleHelper.isEmployee(ref)) {
        final service = ref.read(employeeAppointmentServiceProvider);
        final results = await Future.wait<List<AppointmentDto>>([
          service.getAppointments(date: dateStr),
          service.getAppointments(status: 'Pending'),
        ]);
        todayList = results[0];
        pendingList = results[1];
      } else {
        final service = ref.read(appointmentServiceProvider);
        final results = await Future.wait<List<AppointmentDto>>([
          service.getAppointments(date: dateStr),
          service.getAppointments(status: 'Pending'),
        ]);
        todayList = results[0];
        pendingList = results[1];
      }

      if (mounted) {
        setState(() {
          _todayAppointments = todayList;
          _pendingAppointments = pendingList;
          _isLoading = false;
          _errorMessage = null;
        });
        ref.read(pendingAppointmentsProvider.notifier).refresh();
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;

      if (statusCode == 404) {
        if (mounted) {
          setState(() {
            _todayAppointments = [];
            _pendingAppointments = [];
            _isLoading = false;
            _errorMessage = null;
          });
        }
        return;
      }

      String message;
      if (errorData is Map<String, dynamic>) {
        message = errorData['message'] ?? e.message ?? 'Error desconocido';
      } else if (errorData is String) {
        message = errorData;
      } else {
        message = e.message ?? 'Error desconocido';
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              statusCode != null ? 'Error $statusCode: $message' : message;
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

  Widget _buildAppointmentListContent({
    required List<AppointmentDto> list,
    required int tabIndex,
    required Color textColor,
    required Color mutedColor,
    required Color cardColor,
    required Color borderColor,
    required Color accentColor,
    required bool isSmallScreen,
    required double listPadding,
    required double cardSpacing,
  }) {
    if (list.isEmpty) {
      return AppointmentListEmptyState(
        selectedTab: tabIndex,
        onAddAppointment: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateAppointmentScreen(),
            ),
          );
          if (result == true) {
            _loadAppointments();
          }
        },
        textColor: textColor,
        mutedColor: mutedColor,
        accentColor: accentColor,
        isSmallScreen: isSmallScreen,
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAppointments,
      color: accentColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(listPadding),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final apt = list[index];
          return Padding(
            padding: EdgeInsets.only(bottom: cardSpacing),
            child: AppointmentListCard(
              appointment: apt,
              textColor: textColor,
              mutedColor: mutedColor,
              cardColor: cardColor,
              borderColor: borderColor,
              accentColor: accentColor,
              isSmallScreen: isSmallScreen,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentDetailScreen(
                      appointment: apt,
                    ),
                  ),
                );
                if (result == true) {
                  _loadAppointments();
                }
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final w = context.screenWidth;
    final isSmallScreen = w < AppBreakpoints.compactWidth;
    final isMediumScreen =
        w >= AppBreakpoints.compactWidth && w < AppBreakpoints.tabletWidth;
    final isExpandedLayout = context.isExpandedWidth;

    final textColor = isDark ? const Color(0xFFFAFAFA) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
    final cardColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
    final bgColor = isDark ? const Color(0xFF0A0A0B) : Colors.white;
    const accentColor = Color(0xFF10B981);
    final pendingCount = ref.watch(pendingAppointmentsProvider);

    final double horizontalPadding = isSmallScreen
        ? 16
        : (isMediumScreen
            ? 18
            : (isExpandedLayout ? 24 : 20));
    final double verticalSpacing = isSmallScreen ? 10 : 12;
    final double titleFontSize =
        isSmallScreen ? 20 : (isMediumScreen ? 22 : 24);
    final double subtitleFontSize = isSmallScreen ? 11 : 12;
    final double iconSize = isSmallScreen ? 32 : 36;
    final double iconInnerSize = isSmallScreen ? 16 : 18;
    final double listPadding = isSmallScreen
        ? 12
        : (isExpandedLayout ? 20 : 16);
    final double cardSpacing = isSmallScreen ? 10 : 12;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                isSmallScreen ? 12 : 16,
                horizontalPadding,
                verticalSpacing,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Citas',
                          style: GoogleFonts.inter(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 1 : 2),
                        Text(
                          _selectedTab == 0
                              ? 'Citas de hoy'
                              : 'Citas pendientes',
                          style: GoogleFonts.inter(
                            fontSize: subtitleFontSize,
                            color: mutedColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppointmentHistoryScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: mutedColor.withAlpha(15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Iconsax.document_text,
                          color: textColor,
                          size: iconInnerSize,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 10),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateAppointmentScreen(),
                          ),
                        );
                        if (result == true) {
                          _loadAppointments();
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: accentColor.withAlpha(15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Iconsax.add,
                          color: accentColor,
                          size: iconInnerSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: AppointmentLineTabBar(
                selectedIndex: _selectedTab,
                onTabSelected: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                  );
                },
                tabs: const ['Hoy', 'Pendientes'],
                tabBadges: [null, pendingCount > 0 ? pendingCount : null],
                accentColor: accentColor,
                textColor: textColor,
                mutedColor: mutedColor,
                isSmallScreen: isSmallScreen,
              ),
            ),
            SizedBox(height: verticalSpacing),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: accentColor))
                  : _errorMessage != null
                      ? AppointmentListErrorState(
                          errorMessage: _errorMessage!,
                          onRetry: _loadAppointments,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          accentColor: accentColor,
                          isSmallScreen: isSmallScreen,
                        )
                      : PageView(
                          controller: _pageController,
                          onPageChanged: (i) {
                            setState(() => _selectedTab = i);
                          },
                          children: [
                            _buildAppointmentListContent(
                              list: _todayAppointments,
                              tabIndex: 0,
                              textColor: textColor,
                              mutedColor: mutedColor,
                              cardColor: cardColor,
                              borderColor: borderColor,
                              accentColor: accentColor,
                              isSmallScreen: isSmallScreen,
                              listPadding: listPadding,
                              cardSpacing: cardSpacing,
                            ),
                            _buildAppointmentListContent(
                              list: _pendingAppointments,
                              tabIndex: 1,
                              textColor: textColor,
                              mutedColor: mutedColor,
                              cardColor: cardColor,
                              borderColor: borderColor,
                              accentColor: accentColor,
                              isSmallScreen: isSmallScreen,
                              listPadding: listPadding,
                              cardSpacing: cardSpacing,
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

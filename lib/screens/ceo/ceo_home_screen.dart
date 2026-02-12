import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sbmg/screens/citizen/scheme_details_screen.dart';
import 'package:sbmg/widgets/common/banner_carousel.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:csv/csv.dart';
import '../../utils/api_error_utils.dart';
import '../../utils/download_helper.dart';
import '../../config/connstants.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../providers/ceo_provider.dart';
import '../../models/scheme_model.dart';
import '../../models/event_model.dart';
import '../../models/contractor_model.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../screens/common/unified_select_location_screen.dart';
import 'ceo_select_location_screen.dart';
import 'ceo_gp_attendance_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../citizen/gp_master_data_details_screen.dart';
import '../citizen/language_screen.dart';
import '../citizen/notifications_screen.dart';

class CeoHomeScreen extends StatefulWidget {
  /// When true, this screen is shown inside [CeoShellScreen]. Bottom nav is provided by the shell.
  final bool isEmbeddedInShell;

  const CeoHomeScreen({super.key, this.isEmbeddedInShell = false});

  @override
  State<CeoHomeScreen> createState() => _CeoHomeScreenState();
}

class _CeoHomeScreenState extends State<CeoHomeScreen> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();
  BuildContext? _parentContext;

  @override
  void initState() {
    super.initState();
    _parentContext = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CeoProvider>().loadAllData();
    });
  }

  Future<void> _selectDateRange(CeoProvider provider) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: provider.fromDate != null && provider.toDate != null
          ? DateTimeRange(start: provider.fromDate!, end: provider.toDate!)
          : null,
    );

    if (picked != null) {
      provider.updateDateRange(picked.start, picked.end);
      await provider.loadComplaintsAnalytics();
    }
  }

  Future<void> _exportToCSV(CeoProvider provider) async {
    if (provider.fromDate == null || provider.toDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.pleaseSelectDateRangeFirst,
            ),
            backgroundColor: const Color(0xFF6B7280),
          ),
        );
      }
      return;
    }
    try {
      // Request storage permission for Android
      await DownloadHelper.requestStoragePermission();

      // Create CSV data
      final csvData = [
        ['Metric', 'Count', 'Date Range'],
        [
          'Total Reported Complaints',
          provider.analytics['totalComplaints'].toString(),
          provider.dateRangeText,
        ],
        [
          'Open Complaints',
          provider.analytics['openComplaints'].toString(),
          provider.dateRangeText,
        ],
        [
          'Resolved complaints',
          (provider.analytics['resolvedComplaints'] +
                  provider.analytics['verifiedComplaints'] +
                  provider.analytics['closedComplaints'])
              .toString(),
          provider.dateRangeText,
        ],
      ];

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(csvData);

      // Create filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'ceo_complaints_report_$timestamp.csv';

      // Download to Downloads folder
      final filePath = await DownloadHelper.downloadToDownloadsFolder(
        fileName: fileName,
        content: csvString,
      );

      // Show success message
      if (mounted) {
        if (filePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.csvExportedToDownloads(fileName),
              ),
              backgroundColor: const Color(0xFF009B56),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          throw Exception('Failed to save file to Downloads folder');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorExportingCsv(e.toString()),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _parentContext = context;
    return Consumer<CeoProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: Column(
              children: [
                _buildTopHeader(provider),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => provider.refresh(),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const BannerCarousel(
                            imagePaths: [
                              'assets/images/dash1.jpeg',
                              'assets/images/dash2.jpeg',
                              'assets/images/dash3.jpeg',
                              'assets/images/dash4.jpeg',
                              'assets/images/dash5.jpeg',
                            ],
                          ),
                          Image.asset('assets/images/Group.png'),
                          // Overview Section
                          _buildOverviewSection(provider),

                          SizedBox(height: 24.h),

                          // Inspection Section
                          _buildInspectionSection(provider),
                          // View GP Master Data
                          _buildGpMasterDataSection(),

                          SizedBox(height: 24.h),

                          // Featured Schemes Section
                          _buildFeaturedSchemesSection(provider),

                          SizedBox(height: 24.h),

                          // Events Section
                          _buildEventsSection(provider),

                          SizedBox(height: 24.h),

                          _buildSocialMediaSection(),

                          SizedBox(height: 24.h),

                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom nav is provided by CeoShellScreen when isEmbeddedInShell
          bottomNavigationBar: widget.isEmbeddedInShell
              ? null
              : CustomBottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() => _selectedIndex = index);
                    switch (index) {
                      case 0:
                        break;
                      case 1:
                        Navigator.pushNamed(context, '/ceo-complaints');
                        break;
                      case 2:
                        Navigator.pushNamed(context, '/ceo-monitoring');
                        break;
                      case 3:
                        Navigator.pushNamed(context, '/ceo-settings');
                        break;
                    }
                  },
                  items: [
                    BottomNavItem(
                      iconPath: 'assets/icons/bottombar/home.png',
                      label: AppLocalizations.of(context)!.home,
                    ),
                    BottomNavItem(
                      iconPath: 'assets/icons/bottombar/complaints.png',
                      label: AppLocalizations.of(context)!.complaints,
                    ),
                    BottomNavItem(
                      iconPath: 'assets/icons/bottombar/inspection.png',
                      label: AppLocalizations.of(context)!.inspection,
                    ),
                    BottomNavItem(
                      iconPath: 'assets/icons/bottombar/settings.png',
                      label: AppLocalizations.of(context)!.settings,
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildTopHeader(CeoProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.ceo,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF111827),
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                provider.locationPath.isNotEmpty
                    ? provider.locationPath
                    : provider.districtName,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                  letterSpacing: 0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const UnifiedSelectLocationScreen(userRole: 'ceo'),
                    ),
                  );

                  if (result != null) {
                    // Save the location for HOME page (block/GP optional for CEO)
                    final authService = AuthService();
                    await authService.savePageLocation('ceo', 'home', result);
                    // Reload data based on new location
                    if (mounted) {
                      context.read<CeoProvider>().loadAllData();
                    }
                  }
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Icon(
                    Icons.location_on,
                    size: 24,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  final locale = Provider.of<LocaleProvider>(
                    context,
                    listen: false,
                  ).locale;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Localizations(
                        locale: locale,
                        delegates: const [
                          AppLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        child: const NotificationsScreen(),
                      ),
                    ),
                  );
                },
                icon: Image.asset(
                  'assets/icons/Vector.png',
                  width: 24.w,
                  height: 24.h,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              IconButton(
                onPressed: () {
                  final locale = Provider.of<LocaleProvider>(
                    context,
                    listen: false,
                  ).locale;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Localizations(
                        locale: locale,
                        delegates: const [
                          AppLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        child: const LanguageScreen(),
                      ),
                    ),
                  );
                },
                icon: Image.asset(
                  'assets/icons/Translate.png',
                  width: 24.w,
                  height: 24.h,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Removed unused methods: _buildBannerSection, _buildDot, _buildLogoContainer

  Widget _buildOverviewSection(CeoProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.overview,
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111827),
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 16.h),

          // Date Range Picker and Export Button
          Row(
            children: [
              // Date Range Picker
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDateRange(provider),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16.sp,
                          color: const Color(0xFF6B7280),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          provider.dateRangeText,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF374151),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Export Button
              Tooltip(
                message: provider.fromDate != null && provider.toDate != null
                    ? AppLocalizations.of(context)!.export
                    : AppLocalizations.of(
                        context,
                      )!.selectDateRangeToEnableExport,
                child: Opacity(
                  opacity: provider.fromDate != null && provider.toDate != null
                      ? 1.0
                      : 0.5,
                  child: GestureDetector(
                    onTap: () {
                      if (provider.fromDate == null ||
                          provider.toDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.pleaseSelectDateRangeFirst,
                            ),
                            backgroundColor: const Color(0xFF6B7280),
                          ),
                        );
                        return;
                      }
                      _exportToCSV(provider);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF009B56),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.download,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            AppLocalizations.of(context)!.export,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),
          // Total Reported Complaints
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.totalReportedComplaint,
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF717680),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Tooltip(
                          message: AppLocalizations.of(
                            context,
                          )!.tooltipTotalReportedComplaintDescription,
                          child: GestureDetector(
                            onTap: () {
                              final l10n = AppLocalizations.of(context)!;
                              _showInfoDialog(
                                context,
                                l10n.totalReportedComplaint,
                                l10n.tooltipTotalReportedComplaintDescription,
                              );
                            },
                            child: Icon(
                              Icons.info_outline,
                              size: 16.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      provider.isComplaintsLoading
                          ? '...'
                          : provider.analytics['totalComplaints'].toString(),
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // Open and Disposed Complaints
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  AppLocalizations.of(context)!.openComplaint,
                  provider.isComplaintsLoading
                      ? '...'
                      : provider.analytics['openComplaints'].toString(),
                  'assets/icons/hourglass.png',
                  Colors.black,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildOverviewCard(
                  AppLocalizations.of(context)!.resolvedComplaints,
                  provider.isComplaintsLoading
                      ? '...'
                      : (provider.analytics['resolvedComplaints'] +
                                provider.analytics['verifiedComplaints'] +
                                provider.analytics['closedComplaints'])
                            .toString(),
                  'assets/icons/Icon.png',
                  Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGpMasterDataSection() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GpMasterDataDetailsScreen(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 56,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF009B56),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 22.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      l10n.viewGpMasterData,
                      style: TextStyle(
                        fontFamily: 'Noto Sans',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20.sp, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionSection(CeoProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Actionable Cards Row
          Row(
            children: [
              Expanded(
                child: _buildInspectionActionCard(
                  AppLocalizations.of(
                    context,
                  )!.checkContractorSupervisorAttendance,
                  Icons.calendar_today,
                  'attendance',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildInspectionActionCard(
                  AppLocalizations.of(context)!.contractorDetails,
                  Icons.business,
                  'contractor',
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // View Rankings of GP Card
          _buildRankingsCard(),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildRankingsCard() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const CeoSelectLocationScreen(actionType: 'ranking'),
          ),
        );

        if (result == null) {
          return;
        }

        final blockId = result['blockId'] as int?;
        final blockName = result['blockName'] as String?;
        final districtId = result['districtId'] as int?;

        if (blockId == null || districtId == null) {
          return;
        }

        Navigator.pushNamed(
          context,
          '/ceo-gp-ranking',
          arguments: {
            'districtId': districtId,
            'blockId': blockId,
            'blockName': blockName,
          },
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFF18a558), // Medium green background
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon with light green background
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFFe8f5e9), // Light green background
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Icon(
                Icons.emoji_events, // Ribbon/medal icon
                color: const Color(0xFF18a558),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            // Text
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.viewRankingsOfGp,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            // Right arrow
            Icon(Icons.chevron_right, color: Colors.white, size: 20.sp),
          ],
        ),
      ),
    );
  }

  // Removed unused _buildInspectionSummaryCard method

  Widget _buildInspectionActionCard(
    String text,
    IconData icon,
    String actionType,
  ) {
    return GestureDetector(
      onTap: () {
        print('🎯 Tapped on: $text');
        _openLocationSelection(actionType);
      },
      child: Container(
        height: 150.h, // Fixed height for both cards
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon
            Container(
              width: 45.w,
              height: 45.h,
              decoration: BoxDecoration(
                color: const Color(0xFF009B56).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF009B56), size: 24.sp),
            ),

            // Title
            Expanded(
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                    letterSpacing: 0,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF009B56),
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLocationSelection(String actionType) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => CeoSelectLocationScreen(actionType: actionType),
      ),
    );

    if (result == null) {
      return;
    }

    final gpId = result['gpId'] as int?;
    final gpName = (result['gpName'] as String?) ?? '';
    final blockId = result['blockId'] as int?;
    final districtId = result['districtId'] as int?;

    if (gpId == null || gpName.isEmpty) {
      return;
    }

    if (actionType == 'contractor') {
      _loadAndShowContractorDetails(gpId, gpName);
    } else if (actionType == 'attendance') {
      _navigateToAttendance(
        gpId,
        gpName,
        blockId: blockId,
        districtId: districtId,
      );
    }
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: const Color(0xFF6B7280),
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.ok,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    dynamic icon, // Can be IconData or String (asset path)
    Color color,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final bool isResolvedCard =
        title.toLowerCase().contains('resolved') ||
        title.toLowerCase().contains('disposed');
    final bool isOpenCard = title.toLowerCase().contains('open');

    String tooltipMessage = '';
    if (isResolvedCard) {
      tooltipMessage = l10n.tooltipResolvedComplaintsDescription;
    } else if (isOpenCard) {
      tooltipMessage = l10n.tooltipOpenComplaintDescription;
    }

    return Container(
      height: 100.h, // Fixed height for consistent sizing
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF717680),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (tooltipMessage.isNotEmpty) ...[
                      SizedBox(width: 4.w),
                      Tooltip(
                        message: tooltipMessage,
                        child: GestureDetector(
                          onTap: () =>
                              _showInfoDialog(context, title, tooltipMessage),
                          child: Icon(
                            Icons.info_outline,
                            size: 14.sp,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // PLACEHOLDER_POSITIONED
          // Icon positioned in bottom-right corner with white overlay fade
          Positioned(
            bottom: 0,
            right: 8.w,
            child: Opacity(
              opacity: 0.3, // Fade effect with white overlay
              child: icon is String
                  ? Image.asset(icon, width: 60.w, height: 60.h)
                  : Icon(icon, color: color, size: 60.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSchemesSection(CeoProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.featuredScheme,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF111827),
                  letterSpacing: 0,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/schemes');
                },
                child: Text(
                  AppLocalizations.of(context)!.viewAll,
                  style: const TextStyle(
                    color: Color(0xFF009B56),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal Scrollable Schemes
        SizedBox(
          height: 200.h,
          child: provider.isSchemesLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF009B56),
                    ),
                  ),
                )
              : provider.schemes.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.noSchemesAvailable,
                    style: TextStyle(color: const Color(0xFF9CA3AF)),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: provider.schemes.length,
                  itemBuilder: (context, index) {
                    return _buildSchemeCard(provider.schemes[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSchemeCard(Scheme scheme) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SchemeDetailsScreen(scheme: scheme),
          ),
        );
      },
      child: Container(
        width: 350.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: scheme.media.isNotEmpty
                    ? Image.network(
                        ApiConstants.getMediaUrl(scheme.media.first.mediaUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Suppress error logs for 404s since we have fallback
                          return Image.asset(
                            'assets/images/schemes.png',
                            fit: BoxFit.cover,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/schemes.png',
                        fit: BoxFit.cover,
                      ),
              ),
              // Gradient overlay with scheme name
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    scheme.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsSection(CeoProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${provider.events.length} ${provider.events.length != 1 ? l10n.eventsPlural : l10n.events}',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF111827),
                  letterSpacing: 0,
                  height: 1.0,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/events');
                },
                child: Text(
                  l10n.viewAll,
                  style: const TextStyle(
                    color: Color(0xFF009B56),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Events List
        provider.isEventsLoading
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF009B56),
                    ),
                  ),
                ),
              )
            : provider.events.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Text(
                    l10n.noEventsAvailable,
                    style: const TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.events.length > 15
                    ? 15
                    : provider.events.length,
                itemBuilder: (context, index) {
                  return _buildEventCard(provider.events[index], index);
                },
              ),
      ],
    );
  }

  Widget _buildEventCard(Event event, int index) {
    return GestureDetector(
      onTap: () {
        _showEventDetails(event);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Banner with eventbanner.png
            Container(
              height: 120.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
                child: Stack(
                  children: [
                    // Background Image
                    Positioned.fill(
                      child: event.media.isNotEmpty
                          ? Image.network(
                              ApiConstants.getMediaUrl(
                                event.media.first.mediaUrl,
                              ),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Suppress error logs for 404s since we have fallback
                                return Image.asset(
                                  'assets/images/eventbanner.png',
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/eventbanner.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Event Details
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C3E50),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 110.w),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16.sp,
                              color: const Color(0xFF009B56),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                '${_formatDate(event.startTime, includeYear: false)} - ${_formatDate(event.endTime)}',
                                style: TextStyle(
                                  fontFamily: 'Noto Sans',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    event.description ?? '',
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Event Image
                Container(
                  height: 200.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    child: event.media.isNotEmpty
                        ? Image.network(
                            ApiConstants.getMediaUrl(
                              event.media.first.mediaUrl,
                            ),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/eventbanner.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/eventbanner.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                // Event Details
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18.sp,
                              color: const Color(0xFF009B56),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                '${_formatDate(event.startTime)} - ${_formatDate(event.endTime)}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (event.description != null &&
                            event.description!.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Text(
                            event.description!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF111827),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date, {bool includeYear = true}) {
    if (includeYear) {
      return '${date.day}/${date.month}/${date.year}';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  void _navigateToAttendance(
    int gpId,
    String gpName, {
    int? blockId,
    int? districtId,
  }) {
    final navContext = _parentContext ?? context;
    Navigator.push(
      navContext,
      MaterialPageRoute(
        builder: (_) => CeoGpAttendanceScreen(
          gpId: gpId,
          gpName: gpName,
          blockId: blockId,
          districtId: districtId,
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.connectWithSwachhRajasthan,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(
                  assetPath: 'assets/images/InstagramLogo.png',
                  platform: 'Instagram',
                  url: 'https://instagram.com/SwachhRajasthan_',
                ),
                SizedBox(width: 20.w),
                _buildSocialIcon(
                  assetPath: 'assets/images/XLogo.png',
                  platform: 'X',
                  url: 'https://x.com/SwachRajasthan',
                ),
                SizedBox(width: 20.w),
                _buildSocialIcon(
                  assetPath: 'assets/images/FacebookLogo.png',
                  platform: 'Facebook',
                  url: 'https://www.facebook.com/share/16UZeZDuvF/',
                ),
                SizedBox(width: 20.w),
                _buildSocialIcon(
                  assetPath: 'assets/images/YoutubeLogo.png',
                  platform: 'YouTube',
                  url: 'https://youtube.com/@swachhrajasthan',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon({
    required String assetPath,
    required String platform,
    required String url,
  }) {
    return GestureDetector(
      onTap: () => _launchSocialLink(url, platform),
      child: SizedBox(width: 40, height: 40, child: Image.asset(assetPath)),
    );
  }

  Future<void> _launchSocialLink(String url, String platform) async {
    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        _showLinkError(platform);
      }
    } catch (_) {
      if (mounted) {
        _showLinkError(platform);
      }
    }
  }

  void _showLinkError(String platform) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Could not open $platform link.'),
          backgroundColor: Colors.red,
        ),
      );
  }

  Future<void> _loadAndShowContractorDetails(int gpId, String gpName) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF009B56)),
          ),
        ),
      );

      // Fetch contractor details
      final contractor = await _apiService.getContractorByGpId(gpId);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show contractor details in bottom sheet
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _GPContractorDetailsBottomSheet(
            contractorDetails: contractor,
            gpName: gpName,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyApiMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _GPContractorDetailsBottomSheet extends StatelessWidget {
  final ContractorDetails? contractorDetails;
  final String? gpName;

  const _GPContractorDetailsBottomSheet({this.contractorDetails, this.gpName});

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (_) {
      return dateString;
    }
  }

  String _calculateDuration(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return 'N/A';
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      final duration = end.difference(start);
      final months = (duration.inDays / 30).round();
      return '$months months';
    } catch (_) {
      return 'N/A';
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.all(20.r),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.contractorDetails,
                    style: const TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF111827)),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              if (contractorDetails != null) ...[
                if (gpName != null && gpName!.isNotEmpty) ...[
                  _buildDetailRow(
                    AppLocalizations.of(context)!.gramPanchayat,
                    gpName!,
                  ),
                  SizedBox(height: 16.h),
                ],
                _buildDetailRow(
                  l10n.agencyName,
                  contractorDetails!.agency.name,
                ),
                SizedBox(height: 16.h),
                _buildDetailRow(l10n.personName, contractorDetails!.personName),
                SizedBox(height: 16.h),
                _buildDetailRow(
                  l10n.personPhone,
                  contractorDetails!.personPhone,
                ),
                SizedBox(height: 16.h),
                _buildDetailRow(
                  l10n.workOrderDate,
                  _formatDate(contractorDetails!.contractStartDate),
                ),
                SizedBox(height: 16.h),
                _buildDetailRow(
                  l10n.durationOfWork,
                  _calculateDuration(
                    contractorDetails!.contractStartDate,
                    contractorDetails!.contractEndDate,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildDetailRow(
                  l10n.annualContractAmount,
                  '₹ ${contractorDetails!.workOrderAmount.toStringAsFixed(2)}',
                ),
                SizedBox(height: 16.h),
                _buildDetailRow(
                  l10n.frequencyOfWork,
                  contractorDetails!.cleaningFrequency.toUpperCase() ==
                          'FORTNIGHTLY'
                      ? '—'
                      : contractorDetails!.cleaningFrequency,
                ),
              ] else ...[
                Text(
                  AppLocalizations.of(context)!.noContractorDetailsAvailable,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
              ],

              SizedBox(height: 30.h),

              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009B56),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.close,
                    style: const TextStyle(
                      fontFamily: 'Noto Sans',
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
    );
  }
}

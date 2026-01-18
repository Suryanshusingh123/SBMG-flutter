import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/connstants.dart';
import '../../models/scheme_model.dart';
import '../../models/event_model.dart';
import '../../models/contractor_model.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../widgets/common/banner_carousel.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/vdo_provider.dart';
import '../citizen/language_screen.dart';
import '../citizen/notifications_screen.dart';
import '../citizen/scheme_details_screen.dart';
import 'village_master_data_form_screen.dart';
import 'attendance_log_screen.dart';
import 'package:intl/intl.dart';

class VdoHomeScreen extends StatefulWidget {
  const VdoHomeScreen({super.key});

  @override
  State<VdoHomeScreen> createState() => _VdoHomeScreenState();
}

class _VdoHomeScreenState extends State<VdoHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load all data using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VdoProvider>();
      provider.loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Prevent back navigation - user should logout instead
        _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Top Header
              _buildTopHeader(),

              // Main Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<VdoProvider>().refresh();
                  },
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

                        SizedBox(height: 20.h),

                        // Overview Section
                        _buildOverviewSection(),

                        SizedBox(height: 24.h),

                        // Inspection Section
                        _buildInspectionSection(),

                        SizedBox(height: 14.h),

                        // Start GP Master Data Button
                        _buildStartVillageMasterDataButton(),

                        SizedBox(height: 24.h),

                        // Featured Schemes Section
                        _buildFeaturedSchemesSection(),

                        SizedBox(height: 24.h),

                        // Events Section
                        _buildEventsSection(),

                        SizedBox(height: 24.h),

                        // Social Media Icons
                        _buildSocialMediaSection(),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom Navigation Bar
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildTopHeader() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(16.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.vdo,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF111827),
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 2.h),
              Consumer<VdoProvider>(
                builder: (context, provider, child) {
                  return Text(
                    provider.villageName,
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                icon: Stack(
                  children: [
                    Image.asset(
                      'assets/icons/Vector.png',
                      width: 24,
                      height: 24,
                      color: const Color(0xFF2C3E50),
                    ),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageScreen(),
                    ),
                  );
                },
                icon: Image.asset(
                  'assets/icons/Translate.png',
                  width: 24,
                  height: 24,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToComplaints(BuildContext context, int tabIndex) {
    context.read<VdoProvider>().setComplaintsTab(tabIndex);
    Navigator.pushNamed(context, '/vdo-complaints');
  }

  Widget _buildOverviewSection() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.overview,
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
          Consumer<VdoProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _showDateRangePicker(context, provider);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
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
                            Expanded(
                              child: Text(
                                provider.dateRangeText,
                                style: TextStyle(
                                  fontFamily: 'Noto Sans',
                                  fontSize: 12.sp,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              size: 16.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _handleExport(context, provider);
                    },
                    icon: const Icon(Icons.file_download, size: 18),
                    label: Text(l10n.export),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009B56),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16.h),
          // Total Complaints Card
          Consumer<VdoProvider>(
            builder: (context, provider, child) {
              return GestureDetector(
                onTap: () => _navigateToComplaints(context, 0),
                child: Container(
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
                            children: [
                              Text(
                                l10n.totalReportedComplaint,
                                style: TextStyle(
                                  fontFamily: 'Noto Sans',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF717680),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.info_outline,
                                size: 16.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            provider.isComplaintsLoading
                                ? '...'
                                : provider.analytics['totalComplaints']
                                      .toString(),
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
              );
            },
          ),
          SizedBox(height: 12.h),
          // Open and Resolved Complaints
          Row(
            children: [
              Expanded(child: _buildOverviewCard(l10n.openComplaint, context)),
              SizedBox(width: 12.w),
              Expanded(child: _buildOverviewCard(l10n.resolved, context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String title, BuildContext context) {
    return Consumer<VdoProvider>(
      builder: (context, provider, child) {
        final l10n = AppLocalizations.of(context)!;
        final value = title == l10n.openComplaint
            ? provider.analytics['openComplaints'].toString()
            : provider.analytics['resolvedComplaints'].toString();

        final icon = title == l10n.openComplaint
            ? 'assets/icons/hourglass.png'
            : 'assets/icons/Icon.png';

        final isLoading = provider.isComplaintsLoading;
        final targetTab = title == l10n.openComplaint ? 0 : 1;

        return GestureDetector(
          onTap: () => _navigateToComplaints(context, targetTab),
          child: Container(
            height: 100,
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
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF717680),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        isLoading ? '...' : value,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 8,
                  child: Opacity(
                    opacity: 0.3,
                    child: Image.asset(icon, width: 60, height: 60),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInspectionSection() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.inspection,
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111827),
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 10.h),
          Consumer<VdoProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  Expanded(
                    child: _buildInspectionCard(
                      l10n.thisMonth,
                      provider.thisMonthInspections,
                      context,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildInspectionCard(
                      l10n.total,
                      provider.totalInspections,
                      context,
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.people,
                  title: l10n.checkVendorSupervisorAttendance,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VdoAttendanceLogScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.business,
                  title: l10n.updateContractorDetails,
                  onTap: () {
                    _handleShowContractorDetails();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionCard(String title, int value, BuildContext context) {
    return Container(
      height: 100,
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
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF717680),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 8,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset('assets/icons/pdf.png', width: 60, height: 60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
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
              width: 48,
              height: 48,
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
                  title,
                  style: const TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
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
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartVillageMasterDataButton() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VillageMasterDataFormScreen(),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xffFACC15), // Yellow background
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
              Expanded(
                child: Text(
                  l10n.startVillageMasterData,
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 20.sp, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSchemesSection() {
    final l10n = AppLocalizations.of(context)!;

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
                l10n.featuredScheme,
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
        // Horizontal Scrollable Schemes
        SizedBox(
          height: 200,
          child: Consumer<VdoProvider>(
            builder: (context, provider, child) {
              if (provider.isSchemesLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF009B56),
                    ),
                  ),
                );
              }

              if (provider.schemes.isEmpty) {
                return const Center(
                  child: Text(
                    'No schemes available',
                    style: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: provider.schemes.length,
                itemBuilder: (context, index) {
                  return _buildSchemeCard(provider.schemes[index]);
                },
              );
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
            builder: (context) => SchemeDetailsScreen(
              scheme: scheme,
            ),
          ),
        );
      },
      child: Container(
        width: 350,
        margin: const EdgeInsets.only(right: 16),
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
                          print('❌ Error loading home scheme image: $error');
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

  Widget _buildEventsSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer<VdoProvider>(
                builder: (context, provider, child) {
                  return Text(
                    '${provider.events.length} ${provider.events.length != 1 ? l10n.eventsPlural : l10n.events}',
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF111827),
                      letterSpacing: 0,
                      height: 1.0,
                    ),
                  );
                },
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
        Consumer<VdoProvider>(
          builder: (context, provider, child) {
            if (provider.isEventsLoading) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF009B56),
                    ),
                  ),
                ),
              );
            }

            if (provider.events.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Text(
                    l10n.noEventsAvailable,
                    style: const TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.events.length > 15
                  ? 15
                  : provider.events.length,
              itemBuilder: (context, index) {
                return _buildEventCard(provider.events[index], index);
              },
            );
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
          // Event Banner
          Container(
            height: 120,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
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
                ],
              ),
            ),
          ),
          // Event Details
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
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
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Color(0xFF009B56),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              '${_formatDate(event.startTime, includeYear: false)} - ${_formatDate(event.endTime)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
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
                if (event.description != null)
                  Text(
                    event.description!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade500,
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
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
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
                            ApiConstants.getMediaUrl(event.media.first.mediaUrl),
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
                              icon: Icon(Icons.close, color: Colors.grey.shade600),
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
                        if (event.description != null && event.description!.isNotEmpty) ...[
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

  Widget _buildSocialMediaSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
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

  Widget _buildBottomNavigationBar() {
    final l10n = AppLocalizations.of(context)!;

    return CustomBottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        if (index == _selectedIndex) return;

        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/vdo-complaints');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/vdo-inspection');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/vdo-settings');
            break;
        }
      },
      items: [
        BottomNavItem(iconPath: 'assets/icons/bottombar/home.png', label: l10n.home),
        BottomNavItem(iconPath: 'assets/icons/bottombar/complaints.png', label: l10n.complaints),
        BottomNavItem(iconPath: 'assets/icons/bottombar/inspection.png', label: l10n.inspection),
        BottomNavItem(iconPath: 'assets/icons/bottombar/settings.png', label: l10n.settings),
      ],
    );
  }

  String _formatDate(DateTime date, {bool includeYear = true}) {
    if (includeYear) {
      return DateFormat('MMM d yyyy').format(date);
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  void _showDateRangePicker(BuildContext context, VdoProvider provider) async {
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
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Text(
            'Exit App',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          content: Text(
            'Are you sure you want to exit the app?',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Exit the app
                SystemNavigator.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009B56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Exit',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleExport(BuildContext context, VdoProvider provider) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF009B56)),
              ),
              SizedBox(height: 16.h),
              Text(
                'Exporting data...',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 14.sp,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Call export function
      final filePath = await provider.exportAnalyticsToCsv();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (filePath != null && context.mounted) {
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            title: Text(
              'Export Successful',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            content: Text(
              'CSV file saved successfully!\n\nLocation: $filePath',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009B56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (context.mounted) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            title: Text(
              'Export Failed',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            content: Text(
              'Failed to export data. Please try again.',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            title: Text(
              'Export Failed',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            content: Text(
              'Error: $e',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _handleShowContractorDetails() async {
    try {
      // Get GP/Village ID from auth storage
      final auth = AuthService();
      final villageId = await auth.getVillageId();
      // Use stored GP/Village ID
      final int? intGpId = villageId;
      if (intGpId == null) {
        throw Exception('Invalid GP/Village ID');
      }

      // Fetch contractor details by GP ID
      final contractor = await ApiService().getContractorByGpId(intGpId);

      // Show bottom sheet with details
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) =>
              _VdoContractorDetailsBottomSheet(contractorDetails: contractor),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading contractor details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _VdoContractorDetailsBottomSheet extends StatefulWidget {
  final ContractorDetails? contractorDetails;

  const _VdoContractorDetailsBottomSheet({this.contractorDetails});

  @override
  State<_VdoContractorDetailsBottomSheet> createState() =>
      _VdoContractorDetailsBottomSheetState();
}

class _VdoContractorDetailsBottomSheetState
    extends State<_VdoContractorDetailsBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditMode = false;
  bool _isLoading = false;

  // Current contractor details (can be updated)
  late ContractorDetails? _currentContractorDetails;

  // Form controllers
  late final TextEditingController _nameController;
  late final TextEditingController _workOrderDateController;

  // Dropdown values
  String? _selectedDuration;
  String? _selectedFrequency;

  // Date values
  DateTime? _startDate;
  DateTime? _endDate;

  // Duration options
  final List<String> _durationOptions = [
    '3 months',
    '6 months',
    '12 months',
    '18 months',
    '24 months',
  ];

  // Frequency options
  final List<String> _frequencyOptions = [
    'Daily',
    '2 times a day',
    '3 times a day',
    'Weekly',
    'Monthly',
  ];

  @override
  void initState() {
    super.initState();
    _currentContractorDetails = widget.contractorDetails;
    _loadExistingData();
  }

  void _loadExistingData() {
    final details = _currentContractorDetails ?? widget.contractorDetails;
    if (details != null) {
      _nameController = TextEditingController(text: details.personName);

      // Parse and set dates
      try {
        _startDate = DateTime.parse(details.contractStartDate);
        _workOrderDateController = TextEditingController(
          text: _formatDateForDisplay(_startDate!),
        );

        if (details.contractEndDate != null) {
          _endDate = DateTime.parse(details.contractEndDate!);
        }
      } catch (e) {
        print('Error parsing dates: $e');
        _startDate = null;
        _workOrderDateController = TextEditingController();
      }

      // Set duration based on dates
      if (_startDate != null && _endDate != null) {
        final duration = _endDate!.difference(_startDate!);
        final months = (duration.inDays / 30).round();
        final calculatedDuration = '$months months';
        if (_durationOptions.contains(calculatedDuration)) {
          _selectedDuration = calculatedDuration;
        } else {
          _selectedDuration = _findClosestDurationOption(months);
        }
      }

      // Set frequency from model
      if (_frequencyOptions.contains(details.workFrequency)) {
        _selectedFrequency = details.workFrequency;
      }
    } else {
      _nameController = TextEditingController();
      _workOrderDateController = TextEditingController();
    }
  }

  String? _findClosestDurationOption(int months) {
    final availableMonths = [3, 6, 12, 18, 24];
    int? closest;
    int minDiff = 999;

    for (final available in availableMonths) {
      final diff = (months - available).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = available;
      }
    }

    return closest != null ? '$closest months' : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _workOrderDateController.dispose();
    super.dispose();
  }

  String _formatDateForDisplay(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  String _formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        _workOrderDateController.text = _formatDateForDisplay(picked);

        // Recalculate end date if duration is selected
        if (_selectedDuration != null) {
          final months = int.tryParse(
            _selectedDuration!.replaceAll(' months', ''),
          );
          if (months != null) {
            _endDate = DateTime(picked.year, picked.month + months, picked.day);
          }
        }
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final details = widget.contractorDetails;
    if (details == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contractor details not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select work order date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select duration'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Calculate end date if not set
    if (_endDate == null && _startDate != null && _selectedDuration != null) {
      final months = int.tryParse(_selectedDuration!.replaceAll(' months', ''));
      if (months != null) {
        _endDate = DateTime(
          _startDate!.year,
          _startDate!.month + months,
          _startDate!.day,
        );
      }
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select duration to calculate end date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final villageId = await authService.getVillageId();
      final gpId = villageId;

      if (gpId == null) {
        throw Exception('Invalid GP/Village ID');
      }

      // Update contractor details
      final updatedContractor = await ApiService().updateContractor(
        contractorId: details.id,
        agencyId: details.agency.id,
        personName: _nameController.text.trim(),
        personPhone: details.personPhone,
        gpId: gpId,
        contractStartDate: _formatDateForApi(_startDate!),
        contractEndDate: _formatDateForApi(_endDate!),
      );

      // Update the form controllers with saved values
      _nameController.text = updatedContractor.personName;
      try {
        _startDate = DateTime.parse(updatedContractor.contractStartDate);
        _workOrderDateController.text = _formatDateForDisplay(_startDate!);
        if (updatedContractor.contractEndDate != null) {
          _endDate = DateTime.parse(updatedContractor.contractEndDate!);
        }
      } catch (e) {
        print('Error parsing updated dates: $e');
      }

      // Update duration and frequency based on updated dates
      if (_startDate != null && _endDate != null) {
        final duration = _endDate!.difference(_startDate!);
        final months = (duration.inDays / 30).round();
        final calculatedDuration = '$months months';
        if (_durationOptions.contains(calculatedDuration)) {
          _selectedDuration = calculatedDuration;
        } else {
          _selectedDuration = _findClosestDurationOption(months);
        }
      }

      setState(() {
        _isLoading = false;
        _isEditMode = false;
        // Update current contractor details with the saved data
        _currentContractorDetails = updatedContractor;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contractor details updated successfully!'),
            backgroundColor: Color(0xFF009B56),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating contractor details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _currentContractorDetails ?? widget.contractorDetails;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.all(20.r),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.vendorDetails,
                  style: const TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                if (!_isEditMode)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isEditMode = true;
                      });
                    },
                    icon: const Icon(Icons.edit, color: Color(0xFF111827)),
                  ),
              ],
            ),

            SizedBox(height: 24.h),
            if (details != null) ...[
              if (!_isEditMode) ...[
                // Read-only view
                _buildDetailRow(
                  AppLocalizations.of(context)!.name,
                  details.personName,
                ),
                SizedBox(height: 16.h),

                _buildDetailRow(
                  AppLocalizations.of(context)!.workOrderDate,
                  _formatDateForDisplay(
                    DateTime.parse(details.contractStartDate),
                  ),
                ),
                SizedBox(height: 16.h),

                _buildDetailRow(
                  AppLocalizations.of(context)!.annualContractAmount,
                  '₹ 12 Crore',
                ),
                SizedBox(height: 16.h),

                _buildDetailRow(
                  AppLocalizations.of(context)!.durationOfWork,
                  _calculateDuration(
                    details.contractStartDate,
                    details.contractEndDate,
                  ),
                ),
                SizedBox(height: 16.h),

                _buildDetailRow(
                  AppLocalizations.of(context)!.frequencyOfWork,
                  details.workFrequency,
                ),

                SizedBox(height: 30.h),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
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
                      AppLocalizations.of(context)!.close,
                      style: const TextStyle(
                        fontFamily: 'Noto Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Edit mode
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field
                      _buildFormField(
                        label: AppLocalizations.of(context)!.name,
                        controller: _nameController,
                        placeholder: 'Enter contractor name',
                      ),

                      SizedBox(height: 20.h),

                      // Work Order Date Field
                      _buildFormField(
                        label: 'Panchayat',
                        controller: _workOrderDateController,
                        placeholder: 'Work Order date',
                        suffixIcon: Icons.calendar_today,
                        onTap: _selectStartDate,
                      ),

                      SizedBox(height: 20.h),

                      // Duration Dropdown
                      _buildDropdownField(
                        label: AppLocalizations.of(context)!.durationOfWork,
                        value: _selectedDuration,
                        placeholder: 'Select duration',
                        items: _durationOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedDuration = value;
                            // Calculate end date based on duration
                            if (_startDate != null && value != null) {
                              final months = int.tryParse(
                                value.replaceAll(' months', ''),
                              );
                              if (months != null) {
                                _endDate = DateTime(
                                  _startDate!.year,
                                  _startDate!.month + months,
                                  _startDate!.day,
                                );
                              }
                            }
                          });
                        },
                      ),

                      SizedBox(height: 20.h),

                      // Frequency Dropdown
                      _buildDropdownField(
                        label: AppLocalizations.of(context)!.frequencyOfWork,
                        value: _selectedFrequency,
                        placeholder: 'Select duration',
                        items: _frequencyOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedFrequency = value;
                          });
                        },
                      ),

                      SizedBox(height: 30.h),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF009B56),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Save',
                                  style: TextStyle(
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
              ],
            ] else ...[
              const Text('No contractor details found'),
              SizedBox(height: 20.h),
            ],
          ],
        ),
      ),
    );
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

  String _calculateDuration(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) {
      return 'N/A';
    }
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      final duration = end.difference(start);
      final months = (duration.inDays / 30).round();
      return '$months months';
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    IconData? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          onTap: onTap,
          readOnly: onTap != null,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF009B56)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey.shade600, size: 20.sp)
                : null,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String placeholder,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF009B56)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a value';
            }
            return null;
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sbmg/screens/bdo/select_gp_screen.dart';
import 'package:sbmg/screens/bdo/gp_ranking_screen.dart';

import '../../widgets/common/banner_carousel.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../l10n/app_localizations.dart';
import '../../models/scheme_model.dart';
import '../../models/event_model.dart';
import '../../config/connstants.dart';
import '../../providers/bdo_provider.dart';
import '../citizen/language_screen.dart';
import '../citizen/notifications_screen.dart';
import '../citizen/scheme_details_screen.dart';

class BdoHomeScreen extends StatefulWidget {
  const BdoHomeScreen({super.key});

  @override
  State<BdoHomeScreen> createState() => _BdoHomeScreenState();
}

class _BdoHomeScreenState extends State<BdoHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BdoProvider>().loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<BdoProvider>().refresh();
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
                        _buildOverviewSection(),
                        SizedBox(height: 24.h),
                        _buildInspectionSection(),
                        SizedBox(height: 24.h),
                        _buildFeaturedSchemesSection(),
                        SizedBox(height: 24.h),
                        _buildEventsSection(),
                        SizedBox(height: 24.h),
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
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: EdgeInsets.all(16.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "BDO",
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF111827),
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 2),
              Consumer<BdoProvider>(
                builder: (context, provider, child) {
                  return Text(
                    '${provider.districtName} • ${provider.blockName}',
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
          Consumer<BdoProvider>(
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
                  SizedBox(
                    width: 140,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Export for BDO coming soon
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Export coming soon')),
                        );
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
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16.h),
          Consumer<BdoProvider>(
            builder: (context, provider, child) {
              return Container(
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
              );
            },
          ),
          SizedBox(height: 12.h),
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
    return Consumer<BdoProvider>(
      builder: (context, provider, child) {
        final value = title == AppLocalizations.of(context)!.openComplaint
            ? provider.analytics['openComplaints'].toString()
            : provider.analytics['resolvedComplaints'].toString();

        final icon = title == AppLocalizations.of(context)!.openComplaint
            ? 'assets/icons/hourglass.png'
            : 'assets/icons/Icon.png';

        final isLoading = provider.isComplaintsLoading;

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
          Consumer<BdoProvider>(
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
                        builder: (context) =>
                            const SelectGpScreen(forAttendance: true),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.business,
                  title: "Contractor details",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectGpScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GpRankingScreen(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              decoration: BoxDecoration(
                color: const Color(0xFF009B56),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.white),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'View Rankings of GP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF009B56).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF009B56), size: 24.sp),
            ),
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

  Widget _buildFeaturedSchemesSection() {
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
        SizedBox(
          height: 200,
          child: Consumer<BdoProvider>(
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
              Positioned.fill(
                child: scheme.media.isNotEmpty
                    ? Image.network(
                        ApiConstants.getMediaUrl(scheme.media.first.mediaUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
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
              Consumer<BdoProvider>(
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
        Consumer<BdoProvider>(
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
                return _buildEventCard(provider.events[index]);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventCard(Event event) {
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
              'Connect with Swachh Rajasthan',
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

  Widget _buildBottomNavigationBar() {
    final l10n = AppLocalizations.of(context)!;

    return CustomBottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/bdo-complaints');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/bdo-monitoring');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/bdo-settings');
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

  void _showDateRangePicker(BuildContext context, BdoProvider provider) async {
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
}

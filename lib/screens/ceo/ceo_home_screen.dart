import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:sbmg/screens/citizen/scheme_details_screen.dart';
import 'package:sbmg/services/bookmark_service.dart';
import 'package:sbmg/widgets/common/banner_carousel.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../config/connstants.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../providers/ceo_provider.dart';
import '../../models/scheme_model.dart';
import '../../models/event_model.dart';
import '../../models/contractor_model.dart';
import '../../models/geography_model.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../widgets/common/bottom_sheet_picker.dart';
// import 'ceo_gp_ranking_screen.dart';
// import 'ceo_gp_attendance_screen.dart';

class CeoHomeScreen extends StatefulWidget {
  const CeoHomeScreen({super.key});

  @override
  State<CeoHomeScreen> createState() => _CeoHomeScreenState();
}

class _CeoHomeScreenState extends State<CeoHomeScreen> {
  int _selectedIndex = 0;
  final BookmarkService _bookmarkService = BookmarkService();
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
    try {
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

      // Get downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir == null) {
        throw Exception('Could not access downloads directory');
      }

      // Create filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'bdo_complaints_report_$timestamp.csv';
      final file = File('${downloadsDir.path}/$fileName');

      // Write CSV file
      await file.writeAsString(csvString);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'CSV file exported successfully to Downloads folder: $fileName',
            ),
            backgroundColor: const Color(0xFF009B56),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting CSV: $e'),
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
                          const BannerCarousel(),
                          Image.asset('assets/images/Group.png'),
                          // Overview Section
                          _buildOverviewSection(provider),

                          const SizedBox(height: 24),

                          // Inspection Section
                          _buildInspectionSection(provider),

                          const SizedBox(height: 24),

                          // Featured Schemes Section
                          _buildFeaturedSchemesSection(provider),

                          const SizedBox(height: 24),

                          // Events Section
                          _buildEventsSection(provider),

                          const SizedBox(height: 24),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });

              switch (index) {
                case 0:
                  // Already on home screen, do nothing
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
            items: const [
              BottomNavItem(icon: Icons.home, label: 'Home'),
              BottomNavItem(icon: Icons.report_problem, label: 'Complaint'),
              BottomNavItem(icon: Icons.checklist, label: 'Inspection'),
              BottomNavItem(icon: Icons.settings, label: 'Settings'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopHeader(CeoProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CEO',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                provider.districtName,
                style: const TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Image.asset(
                  'assets/icons/Vector.png',
                  width: 24,
                  height: 24,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              IconButton(
                onPressed: () {
                  // Language selection
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

  // Removed unused methods: _buildBannerSection, _buildDot, _buildLogoContainer

  Widget _buildOverviewSection(CeoProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),

          // Date Range Picker and Export Button
          Row(
            children: [
              // Date Range Picker
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDateRange(provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.dateRangeText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF374151),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Export Button
              GestureDetector(
                onTap: () => _exportToCSV(provider),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF009B56),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.download, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Export',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Total Reported Complaints
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                        const Text(
                          'Total Reported Complaint',
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF717680),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.isComplaintsLoading
                          ? '...'
                          : provider.analytics['totalComplaints'].toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Open and Disposed Complaints
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  'Open Complaint',
                  provider.isComplaintsLoading
                      ? '...'
                      : provider.analytics['openComplaints'].toString(),
                  'assets/icons/hourglass.png',
                  Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  'Resolved complaints',
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

  Widget _buildInspectionSection(CeoProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Actionable Cards Row
          Row(
            children: [
              Expanded(
                child: _buildInspectionActionCard(
                  'Check Vender / Supervisor attendance',
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInspectionActionCard(
                  'Contractor details',
                  Icons.business,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // View Rankings of GP Card
          _buildRankingsCard(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRankingsCard() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF18a558), // Medium green background
          borderRadius: BorderRadius.circular(12),
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFe8f5e9), // Light green background
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: const Icon(
                Icons.emoji_events, // Ribbon/medal icon
                color: Color(0xFF18a558),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Text
            const Expanded(
              child: Text(
                'View Rankings of GP',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            // Right arrow
            const Icon(Icons.chevron_right, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  // Removed unused _buildInspectionSummaryCard method

  Widget _buildInspectionActionCard(String text, IconData icon) {
    return GestureDetector(
      onTap: () {
        print('🎯 Tapped on: $text');
        if (text == 'Contractor details') {
          _showGPSelctionBottomSheet('contractor');
        } else if (text == 'Check Vender / Supervisor attendance') {
          _showGPSelctionBottomSheet('attendance');
        }
      },
      child: Container(
        height: 150, // Fixed height for both cards
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF009B56).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF009B56), size: 24),
            ),

            // Title
            Expanded(
              child: Center(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 13,
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
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    dynamic icon, // Can be IconData or String (asset path)
    Color color,
  ) {
    return Container(
      height: 100, // Fixed height for consistent sizing
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF717680),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // Icon positioned in bottom-right corner with white overlay fade
          Positioned(
            bottom: 0,
            right: 8,
            child: Opacity(
              opacity: 0.3, // Fade effect with white overlay
              child: icon is String
                  ? Image.asset(icon, width: 60, height: 60)
                  : Icon(icon, color: color, size: 60),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Scheme',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                  letterSpacing: 0,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/schemes');
                },
                child: const Text(
                  'View all',
                  style: TextStyle(
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
          height: 200,
          child: provider.isSchemesLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF009B56),
                    ),
                  ),
                )
              : provider.schemes.isEmpty
              ? const Center(
                  child: Text(
                    'No schemes available',
                    style: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
      onTap: () {},
      child: Container(
        width: 350,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
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
                  padding: const EdgeInsets.all(16),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${provider.events.length} Event${provider.events.length != 1 ? 's' : ''}',
            style: const TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
              letterSpacing: 0,
              height: 1.0,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Events List
        provider.isEventsLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF009B56),
                    ),
                  ),
                ),
              )
            : provider.events.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No events available',
                    style: TextStyle(color: Color(0xFF9CA3AF)),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
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

                  // Bookmark Button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _bookmarkService.toggleEventBookmark(event);
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _bookmarkService.isEventBookmarked(event.id)
                              ? const Color(0xFF009B56)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _bookmarkService.isEventBookmarked(event.id)
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: _bookmarkService.isEventBookmarked(event.id)
                              ? Colors.white
                              : const Color(0xFF4CAF50),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Event Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 110),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Color(0xFF009B56),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${_formatDate(event.startTime, includeYear: false)} - ${_formatDate(event.endTime)}',
                              style: const TextStyle(
                                fontFamily: 'Noto Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B7280),
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
                const SizedBox(height: 8),
                Text(
                  event.description ?? '',
                  style: const TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
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
    );
  }

  String _formatDate(DateTime date, {bool includeYear = true}) {
    if (includeYear) {
      return '${date.day}/${date.month}/${date.year}';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  void _showGPSelctionBottomSheet(String actionType) async {
    // Show bottom sheet to select block first
    await _showBlockSelectionBottomSheet(actionType);
  }

  Future<void> _showBlockSelectionBottomSheet(String actionType) async {
    final AuthService authService = AuthService();
    final districtId = await authService.getDistrictId();

    if (districtId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('District ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final blocks = await _apiService.getBlocks(districtId: districtId);

    BottomSheetPicker.show<Block>(
      context: context,
      title: 'Select Block',
      items: blocks,
      itemBuilder: (block) => block.name,
      selectedItem: null,
      onSelected: (block) {
        _showGPSelectionBottomSheet(actionType, districtId, block.id);
      },
      isLoading: false,
      showSearch: true,
      searchHint: 'Search Block...',
    );
  }

  Future<void> _showGPSelectionBottomSheet(
    String actionType,
    int districtId,
    int blockId,
  ) async {
    final gps = await _apiService.getGramPanchayats(
      districtId: districtId,
      blockId: blockId,
    );

    BottomSheetPicker.show<GramPanchayat>(
      context: context,
      title: 'Select Gram Panchayat',
      items: gps,
      itemBuilder: (gp) => gp.name,
      selectedItem: null,
      onSelected: (gp) {
        if (actionType == 'contractor') {
          _loadAndShowContractorDetails(gp.id, gp.name);
        } else if (actionType == 'attendance') {
          _navigateToAttendance(gp.id, gp.name);
        }
      },
      isLoading: false,
      showSearch: true,
      searchHint: 'Search Gram Panchayat...',
    );
  }

  void _navigateToAttendance(int gpId, String gpName) {
    print('🚀 _navigateToAttendance called with gpId: $gpId, gpName: $gpName');
    try {
      final navContext = _parentContext ?? context;
      print('📱 Using context: $_parentContext');
      Navigator.push(
        navContext,
        MaterialPageRoute(
          builder: (context) {
            print('📱 Building CeoGpAttendanceScreen with gpId: $gpId');
            // TODO: Implement CeoGpAttendanceScreen
            return Scaffold(
              body: Center(
                child: Text('GP Attendance for $gpName (ID: $gpId)'),
              ),
            );
          },
        ),
      );
      print('✅ Navigation completed');
    } catch (e, stackTrace) {
      print('❌ Error navigating to attendance: $e');
      print('📚 Stack trace: $stackTrace');
    }
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
            content: Text('Error loading contractor details: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Contractor Details',
                  style: TextStyle(
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

            const SizedBox(height: 20),

            // View Mode - Display details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: contractorDetails != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (gpName != null) ...[
                          _buildDetailRow('Gram Panchayat', gpName!),
                          const SizedBox(height: 20),
                        ],
                        _buildDetailRow(
                          'Agency Name',
                          contractorDetails!.agency.name,
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                          'Contact Person',
                          contractorDetails!.personName,
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                          'Contact Phone',
                          contractorDetails!.personPhone,
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                          'Agency Phone',
                          contractorDetails!.agency.phone,
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                          'Agency Email',
                          contractorDetails!.agency.email,
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                          'Contract Start Date',
                          contractorDetails!.contractStartDate,
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                          'Contract End Date',
                          contractorDetails!.contractEndDate ?? 'N/A',
                        ),
                      ],
                    )
                  : const Text(
                      'No contractor details available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
            ),

            const SizedBox(height: 30),

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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Close',
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

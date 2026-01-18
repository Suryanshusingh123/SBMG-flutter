import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sbmg/screens/citizen/scheme_details_screen.dart';
import '../../config/connstants.dart';
import '../../models/scheme_model.dart';
import '../../models/event_model.dart';
import '../../services/api_services.dart';
import '../../services/bookmark_service.dart';
import '../../services/complaints_service.dart';
import '../../services/auth_services.dart';
import '../../widgets/common/banner_carousel.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../l10n/app_localizations.dart';
import '../citizen/language_screen.dart';
import '../citizen/notifications_screen.dart';

class SupervisorHomeScreen extends StatefulWidget {
  const SupervisorHomeScreen({super.key});

  @override
  State<SupervisorHomeScreen> createState() => _SupervisorHomeScreenState();
}

class _SupervisorHomeScreenState extends State<SupervisorHomeScreen> {
  int _selectedIndex = 0;
  List<Scheme> _schemes = [];
  List<Event> _events = [];
  bool _isSchemesLoading = true;
  bool _isEventsLoading = true;
  bool _isComplaintsLoading = true;
  final BookmarkService _bookmarkService = BookmarkService();
  final ComplaintsService _complaintsService = ComplaintsService();

  // Analytics data from API
  Map<String, dynamic> _analytics = {
    'totalComplaints': 0,
    'openComplaints': 0,
    'resolvedComplaints': 0,
    'verifiedComplaints': 0,
    'closedComplaints': 0,
    'todaysComplaints': 0,
  };

  // Today's complaints data
  List<dynamic> _todaysComplaints = [];

  // GP/Village name
  String? _gpName;
  bool _isLoadingGpName = false;

  @override
  void initState() {
    super.initState();
    _loadSchemes();
    _loadEvents();
    _loadComplaintsAnalytics();
    _loadGpName();
  }

  Future<void> _loadSchemes() async {
    try {
      setState(() => _isSchemesLoading = true);
      final schemes = await ApiService().getSchemes(limit: 5);
      setState(() {
        _schemes = schemes;
        _isSchemesLoading = false;
      });
    } catch (e) {
      setState(() => _isSchemesLoading = false);
    }
  }

  Future<void> _loadEvents() async {
    try {
      setState(() => _isEventsLoading = true);
      final events = await ApiService().getEvents(limit: 12);
      setState(() {
        _events = events;
        _isEventsLoading = false;
      });
    } catch (e) {
      setState(() => _isEventsLoading = false);
    }
  }

  Future<void> _loadComplaintsAnalytics() async {
    try {
      setState(() => _isComplaintsLoading = true);
      final response = await _complaintsService.getComplaintsWithAnalytics();

      if (response['success'] == true) {
        final complaints = response['complaints'] as List<dynamic>;
        final todaysComplaints = _filterTodaysComplaints(complaints);

        setState(() {
          _analytics = response['analytics'];
          _todaysComplaints = todaysComplaints;
          _isComplaintsLoading = false;
        });
      } else {
        setState(() => _isComplaintsLoading = false);
        print('Error loading complaints analytics: ${response['message']}');
      }
    } catch (e) {
      setState(() => _isComplaintsLoading = false);
      print('Error loading complaints analytics: $e');
    }
  }

  Future<void> _loadGpName() async {
    try {
      setState(() => _isLoadingGpName = true);
      final authService = AuthService();
      final villageId = await authService.getVillageId();

      if (villageId != null) {
        final gp = await ApiService().getGramPanchayatById(villageId);
        setState(() {
          _gpName = gp.name;
          _isLoadingGpName = false;
        });
        print('✅ GP Name loaded: ${gp.name}');
      } else {
        print('⚠️ No village ID found');
        setState(() => _isLoadingGpName = false);
      }
    } catch (e) {
      print('❌ Error loading GP name: $e');
      setState(() => _isLoadingGpName = false);
      // Set a default placeholder if loading fails
      _gpName = 'Gram Panchayat';
    }
  }

  List<dynamic> _filterTodaysComplaints(List<dynamic> complaints) {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);

    print('🔍 Filtering today\'s complaints:');
    print('📅 Today (UTC): $today');
    print('📊 Total complaints to filter: ${complaints.length}');

    final todaysComplaints = complaints.where((complaint) {
      if (complaint['created_at'] != null) {
        try {
          final createdAt = DateTime.parse(complaint['created_at']).toUtc();
          final complaintDate = DateTime.utc(
            createdAt.year,
            createdAt.month,
            createdAt.day,
          );

          final isToday = complaintDate.isAtSameMomentAs(today);
          print(
            '📝 Complaint ${complaint['id']}: ${complaint['created_at']} -> $complaintDate (isToday: $isToday)',
          );

          return isToday;
        } catch (e) {
          print('❌ Error parsing date: ${complaint['created_at']} - $e');
          return false;
        }
      }
      return false;
    }).toList();

    print('✅ Today\'s complaints found: ${todaysComplaints.length}');
    return todaysComplaints;
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
                    await _loadComplaintsAnalytics();
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

                        SizedBox(height: 24.h),

                        // Overview Section
                        _buildOverviewSection(),

                        SizedBox(height: 24.h),

                        // Today's Complaints Section
                        _buildTodaysComplaintsSection(),

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
                l10n.supervisor,
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
                _isLoadingGpName
                    ? l10n.loading
                    : (_gpName ?? 'Gram Panchayat Name'),
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
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
                icon: Image.asset(
                  'assets/icons/Vector.png',
                  width: 24,
                  height: 24,
                  color: const Color(0xFF2C3E50),
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

  // Removed unused _buildSwachhBharatBanner method

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
                      _isComplaintsLoading
                          ? '...'
                          : _analytics['totalComplaints'].toString(),
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
                  l10n.openComplaint,
                  _isComplaintsLoading
                      ? '...'
                      : _analytics['openComplaints'].toString(),
                  'assets/icons/hourglass.png',
                  Colors.black,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildOverviewCard(
                  l10n.disposedComplaints,
                  _isComplaintsLoading
                      ? '...'
                      : (_analytics['resolvedComplaints'] +
                                _analytics['verifiedComplaints'] +
                                _analytics['closedComplaints'])
                            .toString(),
                  'assets/icons/Icon.png',
                  Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Today's Complaints
          Container(
            width: double.infinity,
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
                      Row(
                        children: [
                          Text(
                            l10n.todayComplaints,
                            style: TextStyle(
                              fontFamily: 'Noto Sans',
                              fontSize: 12.sp,
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
                      Text(
                        _isComplaintsLoading
                            ? '...'
                            : _analytics['todaysComplaints'].toString(),
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Icon positioned in bottom-right corner
                Positioned(
                  bottom: 0,
                  right: 8,
                  child: Image.asset(
                    'assets/icons/todayscomplaint.png',
                    width: 90,
                    height: 90,
                  ),
                ),
              ],
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
    final bool isResolvedCard = title.toLowerCase().contains('resolved') || 
                                 title.toLowerCase().contains('disposed');
    
    return Container(
      height: 100, // Fixed height for consistent sizing
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
                    if (isResolvedCard) ...[
                      SizedBox(width: 4.w),
                      Tooltip(
                        message: 'Resolved count includes: Resolved + Verified + Closed complaints',
                        preferBelow: false,
                        child: Icon(
                          Icons.info_outline,
                          size: 14.sp,
                          color: const Color(0xFF6B7280),
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
          // Icon positioned in bottom-right corner with white overlay fade
          Positioned(
            bottom: 0,
            right: 8,
            child: Opacity(
              opacity: 0.3, // Fade effect with white overlay
              child: icon is String
                  ? Image.asset(icon, width: 60, height: 60)
                  : Icon(icon, color: color, size: 60.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysComplaintsSection() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.todayComplaints,
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111827),
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 16.h),

          // Show loading or real data
          if (_isComplaintsLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_todaysComplaints.isEmpty)
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Text(
                  l10n.noComplaintsForToday,
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            )
          else
            ..._todaysComplaints.asMap().entries.map((entry) {
              final index = entry.key;
              final complaint = entry.value;
              return Column(
                children: [
                  _buildComplaintCardFromData(complaint),
                  if (index < _todaysComplaints.length - 1)
                    SizedBox(height: 12.h),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildComplaintCardFromData(Map<String, dynamic> complaint) {
    // Extract data from API response
    final complaintType = complaint['complaint_type'] ?? 'Unknown';
    final description = complaint['description'] ?? 'No description';
    final villageName = complaint['village_name'] ?? '';
    final blockName = complaint['block_name'] ?? '';
    final districtName = complaint['district_name'] ?? '';
    final location = '$villageName, $blockName, $districtName'
        .replaceAll(RegExp(r',\s*,'), ',')
        .trim();

    // Format date
    String formattedDate = 'Today';
    if (complaint['created_at'] != null) {
      try {
        final createdAt = DateTime.parse(complaint['created_at']);
        formattedDate = '${createdAt.day}/${createdAt.month}/${createdAt.year}';
      } catch (e) {
        formattedDate = 'Today';
      }
    }

    // Get first media URL or use default
    String imageUrl = 'assets/images/road.png';
    if (complaint['media_urls'] != null &&
        complaint['media_urls'] is List &&
        (complaint['media_urls'] as List).isNotEmpty) {
      final mediaUrl = complaint['media_urls'][0] as String;
      imageUrl = ApiConstants.getMediaUrl(mediaUrl);
    }

    return _buildComplaintCard(
      complaintType,
      description,
      location,
      formattedDate,
      'Updates', // We'll use map icon instead
      imageUrl,
    );
  }

  Widget _buildComplaintCard(
    String type,
    String description,
    String location,
    String date,
    String updates,
    String imagePath,
  ) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Stack(
              children: [
                imagePath.startsWith('http')
                    ? Image.network(
                        imagePath,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/road.png',
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        imagePath,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      date,
                      style: TextStyle(
                        fontFamily: 'Noto Sans',
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF009B56),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Image.asset('assets/icons/map.png', width: 16, height: 16),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16.sp,
                      color: const Color(0xFF6B7280),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF374151),
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

        // Horizontal Scrollable Schemes
        SizedBox(
          height: 200,
          child: _isSchemesLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF009B56),
                    ),
                  ),
                )
              : _schemes.isEmpty
              ? Center(
                  child: Text(
                    l10n.noSchemesAvailable,
                    style: const TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _schemes.length,
                  itemBuilder: (context, index) {
                    return _buildSchemeCard(_schemes[index]);
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
          child: Text(
            '${_events.length} ${_events.length != 1 ? l10n.eventsPlural : l10n.events}',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
              letterSpacing: 0,
              height: 1.0,
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Events List
        _isEventsLoading
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF009B56),
                    ),
                  ),
                ),
              )
            : _events.isEmpty
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
                itemCount: _events.length > 15 ? 15 : _events.length,
                itemBuilder: (context, index) {
                  return _buildEventCard(_events[index], index);
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              print('❌ Error loading event image: $error');
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
                          borderRadius: BorderRadius.circular(8.r),
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
                          size: 20.sp,
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
            padding: EdgeInsets.all(12.r),
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
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
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
                            color: Color(0xFF009B56),
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
    return CustomBottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        // Navigate to different screens based on selection
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            Navigator.pushNamed(context, '/supervisor-complaints');
            break;
          case 2:
            Navigator.pushNamed(context, '/supervisor-attendance');
            break;
          case 3:
            Navigator.pushNamed(context, '/supervisor-settings');
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
          iconPath: 'assets/icons/bottombar/attendance.png',
          label: AppLocalizations.of(context)!.attendance,
        ),
        BottomNavItem(
          iconPath: 'assets/icons/bottombar/settings.png',
          label: AppLocalizations.of(context)!.settings,
        ),
      ],
    );
  }

  String _formatDate(DateTime date, {bool includeYear = true}) {
    if (includeYear) {
      return '${date.day}/${date.month}/${date.year}';
    } else {
      return '${date.day}/${date.month}';
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
}

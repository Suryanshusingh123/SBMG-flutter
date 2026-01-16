import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../../config/connstants.dart';
import '../../l10n/app_localizations.dart';
import '../../models/complaint_model.dart';
import '../../providers/citizen_auth_provider.dart';
import '../../providers/citizen_complaints_provider.dart';
import '../../widgets/common/auth_required_screen.dart';
import '../../theme/citizen_colors.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../widgets/common/date_filter_bottom_sheet.dart';
import '../../utils/date_time_utils.dart';
import 'complaint_details_screen.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  int _selectedIndex = 1; // My Complaint tab is selected
  String _selectedStatus = 'Open'; // Default to Open tab
  int _selectedStatusIndex = 0;
  bool _hasLoadedComplaints = false; // Flag to prevent multiple API calls
  String _sortOrder = 'newest'; // 'newest' or 'oldest'
  DateTime? _filterDate;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  final Map<String, String> _reverseGeocodedAddresses = {};
  final Set<String> _pendingReverseGeocode = {};
  final Set<String> _failedReverseGeocode = {};

  @override
  void initState() {
    super.initState();

    // Load complaints after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadComplaintsIfNeeded();
    });
  }

  void _loadComplaintsIfNeeded() {
    final authProvider = context.read<AuthProvider>();
    final complaintsProvider = context.read<ComplaintsProvider>();

    print('🔍 _loadComplaintsIfNeeded called');
    print('🔍 isLoggedIn: ${authProvider.isLoggedIn}');
    print('🔍 token: ${authProvider.token != null}');
    print('🔍 isLoadingComplaints: ${complaintsProvider.isLoadingComplaints}');
    print('🔍 hasLoadedComplaints: $_hasLoadedComplaints');

    if (authProvider.isLoggedIn &&
        authProvider.token != null &&
        !complaintsProvider.isLoadingComplaints &&
        !_hasLoadedComplaints) {
      print('🚀 Loading complaints...');
      _hasLoadedComplaints = true;
      complaintsProvider.loadMyComplaints(token: authProvider.token!);
    }
  }

  void _refreshComplaints() {
    final authProvider = context.read<AuthProvider>();
    final complaintsProvider = context.read<ComplaintsProvider>();

    if (authProvider.isLoggedIn &&
        authProvider.token != null &&
        !complaintsProvider.isLoadingComplaints) {
      complaintsProvider.loadMyComplaints(token: authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ComplaintsProvider>(
      builder: (context, authProvider, complaintsProvider, child) {
        // Load complaints when authentication is complete and user is logged in
        if (!authProvider.isCheckingAuth &&
            authProvider.isLoggedIn &&
            !_hasLoadedComplaints &&
            !complaintsProvider.isLoadingComplaints) {
          print('🔄 Consumer2: Triggering complaint load');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadComplaintsIfNeeded();
          });
        }

        // Show loading while checking authentication
        if (authProvider.isCheckingAuth) {
          return Scaffold(
            backgroundColor: CitizenColors.background(context),
            body: const Center(
              child: CircularProgressIndicator(color: Color(0xFF009B56)),
            ),
          );
        }

        // Show auth required screen if not logged in
        if (!authProvider.isLoggedIn) {
          return AuthRequiredScreen(
            title: AppLocalizations.of(context)!.myComplaint,
            message: AppLocalizations.of(context)!.toViewYourComplaintStatus,
          );
        }

        return _buildComplaintsScreen(complaintsProvider);
      },
    );
  }

  Widget _buildComplaintsScreen(ComplaintsProvider complaintsProvider) {
    // Show loading indicator while complaints are being fetched
    if (complaintsProvider.isLoadingComplaints) {
      return Scaffold(
        backgroundColor: CitizenColors.background(context),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF009B56)),
        ),
      );
    }

    // Filter complaints based on selected status
    // For citizen flow: resolved and verified are considered "open"
    List<ComplaintModel>
    filteredComplaints = complaintsProvider.complaints.where((complaint) {
      final complaintStatus = complaint.status.toLowerCase();

      // Filter by status
      final statusMatches = _selectedStatus == 'Open'
          ? complaintStatus == 'open' ||
                complaintStatus == 'verified' ||
                complaintStatus == 'resolved'
          : complaintStatus == 'closed';

      if (!statusMatches) return false;

      // Filter by date if single date filter is applied (Day)
      if (_filterDate != null) {
        final complaintDate = complaint.createdAt.toUtc();
        final filterDate = _filterDate!.toUtc();
        return complaintDate.year == filterDate.year &&
            complaintDate.month == filterDate.month &&
            complaintDate.day == filterDate.day;
      }

      // Filter by date range if range filter is applied (Week, Month, Year, Custom)
      if (_filterStartDate != null && _filterEndDate != null) {
        final complaintDate = complaint.createdAt.toUtc();
        final startDate = DateTime.utc(
          _filterStartDate!.year,
          _filterStartDate!.month,
          _filterStartDate!.day,
        );
        final endDate = DateTime.utc(
          _filterEndDate!.year,
          _filterEndDate!.month,
          _filterEndDate!.day,
          23,
          59,
          59,
        );
        return (complaintDate.isAfter(startDate.subtract(const Duration(seconds: 1))) ||
                complaintDate.isAtSameMomentAs(startDate)) &&
            (complaintDate.isBefore(endDate) ||
                complaintDate.isAtSameMomentAs(endDate));
      }

      return true;
    }).toList();

    // Sort complaints based on sort order (including time)
    if (_sortOrder == 'newest') {
      filteredComplaints.sort((a, b) {
        // createdAt is already DateTime, compare with time included
        final dateA = a.createdAt.toUtc();
        final dateB = b.createdAt.toUtc();
        return dateB.compareTo(dateA); // Newest first (descending)
      });
    } else {
      filteredComplaints.sort((a, b) {
        // createdAt is already DateTime, compare with time included
        final dateA = a.createdAt.toUtc();
        final dateB = b.createdAt.toUtc();
        return dateA.compareTo(dateB); // Oldest first (ascending)
      });
    }

    print('📊 Total complaints: ${complaintsProvider.complaints.length}');
    print('📊 Filtered complaints: ${filteredComplaints.length}');
    print('📊 Selected status: $_selectedStatus');
    print('📊 Sort order: $_sortOrder');

    return Scaffold(
      backgroundColor: CitizenColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),

            // Status Tabs
            _buildStatusTabs(complaintsProvider),

            // Complaints List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _refreshComplaints();
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: filteredComplaints.length,
                  itemBuilder: (context, index) {
                    return _buildComplaintCard(filteredComplaints[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Navigate to different screens based on selection
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/citizen-dashboard');
              break;
            case 1:
              // Already on My Complaints
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/schemes');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/settings');
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
            label: AppLocalizations.of(context)!.myComplaint,
          ),
          BottomNavItem(
            iconPath: 'assets/icons/bottombar/schemes.png',
            label: AppLocalizations.of(context)!.schemes,
          ),
          BottomNavItem(
            iconPath: 'assets/icons/bottombar/settings.png',
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final primaryTextColor = CitizenColors.textPrimary(context);
    final secondaryTextColor = CitizenColors.textSecondary(context);
    return Container(
      padding: EdgeInsets.all(16.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.myComplaint,
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
          ),
          Row(
            children: [
              // Calendar icon with count
              GestureDetector(
                onTap: _showDateFilter,
                child: Icon(
                  Icons.calendar_today,
                  size: 24.sp,
                  color: secondaryTextColor,
                ),
              ),
              SizedBox(width: 12.w),
              // Sort icon
              GestureDetector(
                onTap: _showSortOptions,
                child: Icon(
                  Icons.swap_vert,
                  size: 24.sp,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs(ComplaintsProvider complaintsProvider) {
    final l10n = AppLocalizations.of(context)!;
    
    // Filter complaints by date range first
    List<ComplaintModel> dateFilteredComplaints = complaintsProvider.complaints.where((complaint) {
      // Filter by date if single date filter is applied (Day)
      if (_filterDate != null) {
        final complaintDate = complaint.createdAt.toUtc();
        final filterDate = _filterDate!.toUtc();
        return complaintDate.year == filterDate.year &&
            complaintDate.month == filterDate.month &&
            complaintDate.day == filterDate.day;
      }

      // Filter by date range if range filter is applied (Week, Month, Year, Custom)
      if (_filterStartDate != null && _filterEndDate != null) {
        final complaintDate = complaint.createdAt.toUtc();
        final startDate = DateTime.utc(
          _filterStartDate!.year,
          _filterStartDate!.month,
          _filterStartDate!.day,
        );
        final endDate = DateTime.utc(
          _filterEndDate!.year,
          _filterEndDate!.month,
          _filterEndDate!.day,
          23,
          59,
          59,
        );
        return (complaintDate.isAfter(startDate.subtract(const Duration(seconds: 1))) ||
                complaintDate.isAtSameMomentAs(startDate)) &&
            (complaintDate.isBefore(endDate) ||
                complaintDate.isAtSameMomentAs(endDate));
      }

      return true;
    }).toList();
    
    // Count: open, verified, and resolved are all considered "open"
    // Ensure count is always calculated, even when list is empty
    final openCount = dateFilteredComplaints.isEmpty
        ? 0
        : dateFilteredComplaints.where((c) {
            final status = c.status.toLowerCase();
            return status == 'open' || status == 'verified' || status == 'resolved';
          }).length;
    final closedCount = dateFilteredComplaints.isEmpty
        ? 0
        : dateFilteredComplaints
            .where((c) => c.status.toLowerCase() == 'closed')
            .length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(child: _buildStatusTab(l10n.open, openCount, 0)),
          SizedBox(width: 16.w),
          Expanded(child: _buildStatusTab(l10n.closed, closedCount, 1)),
        ],
      ),
    );
  }

  Widget _buildStatusTab(String status, int count, int index) {
    final isSelected = _selectedStatusIndex == index;
    final secondaryTextColor = CitizenColors.textSecondary(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatusIndex = index;
          _selectedStatus = status;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF009B56) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected) ...[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF009B56),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
            ],
            Text(
              status,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF009B56)
                    : secondaryTextColor,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '($count)',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF009B56)
                    : secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(ComplaintModel complaint) {
    final primaryTextColor = CitizenColors.textPrimary(context);
    final secondaryTextColor = CitizenColors.textSecondary(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ComplaintDetailsScreen(complaintId: complaint.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: CitizenColors.surface(context),
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
            // Complaint Image
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: Colors.grey.shade300,
              ),
              child: Stack(
                children: [
                  // Complaint image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: complaint.imagePaths.isNotEmpty
                        ? Image.network(
                            complaint.imagePaths.first,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade400,
                                child: const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade300,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade400,
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                  // Date badge
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: CitizenColors.surface(context),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        _formatDate(complaint.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Complaint Details
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: CitizenColors.surface(context),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Complaint Type and Updates
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
                      Flexible(
                        child: Text(
                          complaint.type,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '| ${_getUpdateCount(complaint)} Update${_getUpdateCount(complaint) > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: secondaryTextColor,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          _getLocationDisplay(complaint),
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Divider(color: Colors.grey.shade200, thickness: 1),
                  // Description
                  Text(
                    complaint.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats date and time in IST (Indian Standard Time)
  /// Format: "MMM d, yyyy, h:mm a" (e.g., "Jan 15, 2024, 2:30 PM")
  String _formatDate(DateTime date) {
    return DateTimeUtils.formatDateTimeIST(date);
  }

  int _getUpdateCount(ComplaintModel complaint) {
    final status = complaint.status.toLowerCase();

    switch (status) {
      case 'open':
        return 1;
      case 'resolved':
        return 2;
      case 'verified':
        return 3;
      case 'closed':
        return 4;
      default:
        return 1;
    }
  }

  bool _hasValidCoordinates(ComplaintModel complaint) {
    if (complaint.imageLocations.isEmpty) {
      return false;
    }

    final loc = complaint.imageLocations.first;
    final lat = loc.latitude;
    final long = loc.longitude;

    return !lat.isNaN &&
        !long.isNaN &&
        lat != 0.0 &&
        long != 0.0 &&
        lat <= 90 &&
        lat >= -90 &&
        long <= 180 &&
        long >= -180;
  }

  Future<void> _fetchReverseGeocodedAddress(ComplaintModel complaint) async {
    if (!_hasValidCoordinates(complaint)) {
      return;
    }

    if (_reverseGeocodedAddresses.containsKey(complaint.id) ||
        _failedReverseGeocode.contains(complaint.id) ||
        _pendingReverseGeocode.contains(complaint.id)) {
      return;
    }

    final loc = complaint.imageLocations.first;
    _pendingReverseGeocode.add(complaint.id);

    try {
      final placemarks = await placemarkFromCoordinates(
        loc.latitude,
        loc.longitude,
      );

      if (!mounted) return;

      if (placemarks.isEmpty) {
        _failedReverseGeocode.add(complaint.id);
        return;
      }

      final place = placemarks.first;
      final parts = <String>[];

      void addIfNotEmpty(String? value) {
        if (value != null) {
          final trimmed = value.trim();
          if (trimmed.isNotEmpty && !parts.contains(trimmed)) {
            parts.add(trimmed);
          }
        }
      }

      addIfNotEmpty(place.street);
      addIfNotEmpty(place.subLocality);
      addIfNotEmpty(place.locality);
      addIfNotEmpty(place.subAdministrativeArea);
      addIfNotEmpty(place.administrativeArea);
      addIfNotEmpty(place.postalCode);
      addIfNotEmpty(place.country);

      final formattedAddress = parts.isNotEmpty
          ? parts.join(', ')
          : '${loc.latitude}, ${loc.longitude}';

      setState(() {
        _reverseGeocodedAddresses[complaint.id] = formattedAddress;
        _failedReverseGeocode.remove(complaint.id);
      });
    } catch (e) {
      debugPrint('❌ Error reverse geocoding complaint ${complaint.id}: $e');
      _failedReverseGeocode.add(complaint.id);
    } finally {
      _pendingReverseGeocode.remove(complaint.id);
    }
  }

  String _getLocationDisplay(ComplaintModel complaint) {
    print('📍 Incoming complaint: ${complaint.id}');
    print('📍 Stored address: ${_reverseGeocodedAddresses[complaint.id]}');
    print('📍 Raw location field: ${complaint.location}');
    print('📍 District: ${complaint.districtName}');
    print('📍 Block: ${complaint.blockName}');
    print('📍 Village: ${complaint.villageName}');

    // Priority 1: Reverse geocode if coordinates are available
    if (_hasValidCoordinates(complaint)) {
      final cachedAddress = _reverseGeocodedAddresses[complaint.id];

      if (cachedAddress != null && cachedAddress.isNotEmpty) {
        print('✅ Using cached reverse-geocoded address: $cachedAddress');
        return cachedAddress;
      }

      _fetchReverseGeocodedAddress(complaint);
      print('⏳ Reverse geocoding in progress for complaint ${complaint.id}');
    }

    // Priority 2: Display location field value
    if (complaint.location != null && complaint.location!.isNotEmpty) {
      print('✅ Using location field: ${complaint.location}');
      return complaint.location!;
    }

    // Priority 3: Display district, block, and village name
    final parts = <String>[];
    if (complaint.districtName != null && complaint.districtName!.isNotEmpty) {
      parts.add(complaint.districtName!);
    }
    if (complaint.blockName != null && complaint.blockName!.isNotEmpty) {
      parts.add(complaint.blockName!);
    }
    if (complaint.villageName != null && complaint.villageName!.isNotEmpty) {
      parts.add(complaint.villageName!);
    }

    if (parts.isNotEmpty) {
      final fallback = parts.join(' | ');
      print('✅ Using district|block|village: $fallback');
      return fallback;
    }

    // If reverse geocoding is underway, show placeholder
    if (_hasValidCoordinates(complaint)) {
      print('⌛ Showing address placeholder while reverse geocoding');
      return 'Fetching address...';
    }

    // Fallback
    print('❌ No location data available');
    return 'Location not available';
  }

  void _showSortOptions() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: CitizenColors.surface(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),

            // Sort options
            _buildSortOption(l10n.newestFirst, _sortOrder == 'newest', () {
              setState(() {
                _sortOrder = 'newest';
              });
              Navigator.pop(context);
            }),
            SizedBox(height: 12.h),
            _buildSortOption(l10n.oldestFirst, _sortOrder == 'oldest', () {
              setState(() {
                _sortOrder = 'oldest';
              });
              Navigator.pop(context);
            }),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primaryColor : Colors.black,
                ),
              ),
            ),
            if (isSelected) ...[
              Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 16.w),
            ],
          ],
        ),
      ),
    );
  }

  void _showDateFilter() {
    showDateFilterBottomSheet(
      context: context,
      onApply: (filterType, selectedDate, startDate, endDate) {
        // Handle date filter application
        print('📅 Date filter applied:');
        print('   Filter type: $filterType');
        print('   Selected date: $selectedDate');
        print('   Start date: $startDate');
        print('   End date: $endDate');

        setState(() {
          _filterDate = selectedDate;
          _filterStartDate = startDate;
          _filterEndDate = endDate;
        });
      },
    );
  }
}

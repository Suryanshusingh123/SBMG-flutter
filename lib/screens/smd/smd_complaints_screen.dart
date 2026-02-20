import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/api_complaint_model.dart';
import '../../providers/smd_complaints_provider.dart';
import '../../utils/location_display_helper.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../widgets/common/date_filter_bottom_sheet.dart';
import '../../config/connstants.dart';
import '../../services/auth_services.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/common/unified_select_location_screen.dart';
import '../../providers/smd_provider.dart';
import 'smd_complaint_details_screen.dart';

class SmdComplaintsScreen extends StatefulWidget {
  /// When true, this screen is shown inside [SmdShellScreen]; bottom nav is provided by the shell.
  final bool isEmbeddedInShell;

  const SmdComplaintsScreen({super.key, this.isEmbeddedInShell = false});

  @override
  State<SmdComplaintsScreen> createState() => _SmdComplaintsScreenState();
}

class _SmdComplaintsScreenState extends State<SmdComplaintsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 1; // Complaint tab is selected
  DateTime? _filterDate;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String _sortOrder = 'newest';
  Map<String, dynamic>? _complaintLocation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Check for block and GP selection every time screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndSelectLocation());
  }

  Future<void> _checkAndSelectLocation() async {
    if (!mounted) return;
    
    final districtId = await _authService.getSmdSelectedDistrictId();
    
    if (districtId == null) {
      // No district selected, go to district selection
      Navigator.pushReplacementNamed(context, '/smd-district-selection');
      return;
    }
    
    // Load saved location for COMPLAINTS page if available
    // Fallback to old inspection location for backward compatibility
    var savedLocation = await _authService.getPageLocation('smd', 'complaints');
    savedLocation ??= await _authService.getInspectionLocation('smd');
    if (savedLocation != null) {
      setState(() {
        _complaintLocation = savedLocation;
      });
    }
    
    // Load complaints
    context.read<SmdComplaintsProvider>().loadComplaints();
  }

  Widget _buildErrorState(SmdComplaintsProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            provider.errorMessage ?? AppLocalizations.of(context)!.somethingWentWrong,
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => provider.loadComplaints(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF009B56),
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SmdComplaintsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(provider),

                // Status Tabs
                _buildStatusTabs(provider),

                // Complaints List
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.errorMessage != null
                      ? _buildErrorState(provider)
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildComplaintsList(
                              provider.openComplaints,
                              provider,
                            ),
                            _buildComplaintsList(
                              provider.resolvedComplaints,
                              provider,
                            ),
                            _buildComplaintsList(
                              provider.verifiedComplaints,
                              provider,
                            ),
                            _buildComplaintsList(
                              provider.closedComplaints,
                              provider,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          // Bottom nav is provided by SmdShellScreen when isEmbeddedInShell
          bottomNavigationBar: widget.isEmbeddedInShell
              ? null
              : CustomBottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: _onBottomNavTap,
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

  String _getDisplayMonth() {
    if (_filterDate != null) {
      return DateFormat('MMMM').format(_filterDate!);
    }
    if (_filterStartDate != null) {
      return DateFormat('MMMM').format(_filterStartDate!);
    }
    return DateFormat('MMMM').format(DateTime.now());
  }

  Widget _buildHeader(SmdComplaintsProvider provider) {
    final totalComplaints = provider.complaints.length;
    return Container(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.complaintCount(totalComplaints),
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Consumer<SmdProvider>(
                    builder: (context, smdProvider, child) {
                      String locationText;
                      if (_complaintLocation != null) {
                        final parts = <String>[];
                        if (_complaintLocation!['districtName'] != null) {
                          parts.add(_complaintLocation!['districtName'] as String);
                        }
                        if (_complaintLocation!['blockName'] != null) {
                          parts.add(_complaintLocation!['blockName'] as String);
                        }
                        if (_complaintLocation!['gpName'] != null) {
                          parts.add(_complaintLocation!['gpName'] as String);
                        }
                        locationText = parts.isNotEmpty ? parts.join(' • ') : smdProvider.locationPath;
                      } else {
                        locationText = smdProvider.locationPath.isNotEmpty 
                            ? smdProvider.locationPath 
                            : provider.villageName;
                      }
                      
                      return Text(
                        '$locationText • ${_getDisplayMonth()}',
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4B5563),
                          letterSpacing: 0,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UnifiedSelectLocationScreen(userRole: 'smd'),
                        ),
                      );
                      if (result is Map<String, dynamic> && result['districtId'] != null) {
                        print('📍 Location changed - New location: $result');
                        print('   - District ID: ${result['districtId']}');
                        print('   - Block ID: ${result['blockId']}');
                        print('   - GP ID: ${result['gpId']}');
                        
                        // Save the location for COMPLAINTS page
                        await _authService.savePageLocation('smd', 'complaints', result);
                        
                        // Also update the old district ID storage for backward compatibility
                        if (result['districtId'] != null) {
                          await _authService.setSmdSelectedDistrictId(result['districtId'] as int);
                        }
                        
                        // Verify it was saved correctly
                        final saved = await _authService.getInspectionLocation('smd');
                        print('💾 Verified saved location: $saved');
                        if (saved == null) {
                          print('❌ ERROR: Location was not saved correctly!');
                          return;
                        }
                        
                        // Update state
                        setState(() {
                          _complaintLocation = result;
                        });
                        
                        // Reload complaints with new location
                        if (mounted) {
                          context.read<SmdComplaintsProvider>().loadComplaints();
                        }
                      } else {
                        print('⚠️ Location change cancelled or invalid result: $result');
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Icon(
                        Icons.location_on,
                        size: 24.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showDateFilter,
                    child: Icon(
                      Icons.calendar_today,
                      size: 24.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _showSortOptions,
                    child: Icon(
                      Icons.swap_vert,
                      size: 24.sp,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getFilteredCount(List<ApiComplaintModel> complaints) {
    List<ApiComplaintModel> filtered = List.from(complaints);

    if (_filterDate != null) {
      filtered = filtered.where((complaint) {
        try {
          final complaintDate = DateTime.parse(complaint.createdAt).toUtc();
          final filterDate = DateTime.utc(
            _filterDate!.year,
            _filterDate!.month,
            _filterDate!.day,
          );
          return complaintDate.year == filterDate.year &&
              complaintDate.month == filterDate.month &&
              complaintDate.day == filterDate.day;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    if (_filterStartDate != null && _filterEndDate != null) {
      filtered = filtered.where((complaint) {
        try {
          final complaintDate = DateTime.parse(complaint.createdAt).toUtc();
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
        } catch (e) {
          return false;
        }
      }).toList();
    }

    return filtered.length;
  }

  Widget _buildStatusTabs(SmdComplaintsProvider provider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: Color(0xFF009B56), width: 3),
        ),
        labelColor: const Color(0xFF111827),
        unselectedLabelColor: const Color(0xFF9CA3AF),
        labelStyle: TextStyle(
          fontFamily: 'Noto Sans',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Noto Sans',
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        tabs: [
          _buildTab(
            AppLocalizations.of(context)!.openCount(_getFilteredCount(provider.openComplaints)),
            _tabController.index == 0,
          ),
          _buildTab(
            AppLocalizations.of(context)!.resolvedCount(_getFilteredCount(provider.resolvedComplaints)),
            _tabController.index == 1,
          ),
          _buildTab(
            AppLocalizations.of(context)!.verifiedCount(_getFilteredCount(provider.verifiedComplaints)),
            _tabController.index == 2,
          ),
          _buildTab(
            AppLocalizations.of(context)!.disposedComplaintsCount(_getFilteredCount(provider.closedComplaints)),
            _tabController.index == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text),
          SizedBox(width: 8.w),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF009B56) : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsList(
    List<dynamic> complaints,
    SmdComplaintsProvider provider,
  ) {
    // Apply date filters
    List<ApiComplaintModel> filteredComplaints = List<ApiComplaintModel>.from(complaints);

    // Remove duplicate complaints based on ID
    final Map<int, ApiComplaintModel> uniqueComplaints = {};
    for (final complaint in filteredComplaints) {
      if (!uniqueComplaints.containsKey(complaint.id)) {
        uniqueComplaints[complaint.id] = complaint;
      }
    }
    filteredComplaints = uniqueComplaints.values.toList();

    // Apply date filters
    if (_filterDate != null) {
      filteredComplaints = filteredComplaints.where((complaint) {
        try {
          final complaintDate = DateTime.parse(complaint.createdAt).toUtc();
          // Create UTC date using just the year, month, day components to avoid timezone issues
          final filterDate = DateTime.utc(
            _filterDate!.year,
            _filterDate!.month,
            _filterDate!.day,
          );
          return complaintDate.year == filterDate.year &&
              complaintDate.month == filterDate.month &&
              complaintDate.day == filterDate.day;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    if (_filterStartDate != null && _filterEndDate != null) {
      filteredComplaints = filteredComplaints.where((complaint) {
        try {
          final complaintDate = DateTime.parse(complaint.createdAt).toUtc();
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
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Sort complaints based on sort order
    if (_sortOrder == 'newest') {
      filteredComplaints.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.createdAt).toUtc();
          final dateB = DateTime.parse(b.createdAt).toUtc();
          return dateB.compareTo(dateA); // Newest first (descending)
        } catch (e) {
          return b.createdAt.compareTo(a.createdAt); // Fallback to string comparison
        }
      });
    } else {
      filteredComplaints.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.createdAt).toUtc();
          final dateB = DateTime.parse(b.createdAt).toUtc();
          return dateA.compareTo(dateB); // Oldest first (ascending)
        } catch (e) {
          return a.createdAt.compareTo(b.createdAt); // Fallback to string comparison
        }
      });
    }

    if (filteredComplaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64.sp,
              color: const Color(0xFF9CA3AF),
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context)!.noComplaintsFound,
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: filteredComplaints.length,
      itemBuilder: (context, index) {
        return _buildComplaintCard(filteredComplaints[index], provider);
      },
    );
  }

  Widget _buildComplaintCard(
    ApiComplaintModel complaint,
    SmdComplaintsProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final locationText = LocationDisplayHelper.buildDisplay(
      cacheKey: 'smd-${complaint.id}',
      latitude: complaint.latitude,
      longitude: complaint.longitude,
      locationField: complaint.location,
      district: complaint.districtName,
      block: complaint.blockName,
      village: complaint.villageName,
      scheduleUpdate: () {
        // Location will be cached and shown on next rebuild
        // No need to trigger setState which causes rendering conflicts
      },
      unavailableLabel: l10n.locationNotAvailable,
    );
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SmdComplaintDetailsScreen(complaint: complaint.toMap()),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
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
                  complaint.hasMedia
                      ? Image.network(
                          ApiConstants.getMediaUrl(complaint.firstMediaUrl),
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/road.png',
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/road.png',
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        complaint.formattedDate,
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
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider.getComplaintTypeDisplayName(complaint),
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111827),
                            letterSpacing: 0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Image.asset(
                        'assets/icons/map.png',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_pin,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          locationText,
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Divider(color: Colors.grey.shade200, thickness: 2),

                  // Description
                  Text(
                    complaint.description,
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0,
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

  void _showDateFilter() {
    showDateFilterBottomSheet(
      context: context,
      onApply: (filterType, selectedDate, startDate, endDate) {
        setState(() {
          _filterDate = selectedDate;
          _filterStartDate = startDate;
          _filterEndDate = endDate;
        });
      },
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            _buildSortOption(AppLocalizations.of(context)!.newestFirst, _sortOrder == 'newest', () {
              setState(() {
                _sortOrder = 'newest';
              });
              Navigator.pop(context);
            }),
            SizedBox(height: 12.h),
            _buildSortOption(AppLocalizations.of(context)!.oldestFirst, _sortOrder == 'oldest', () {
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

  Widget _buildSortOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF009B56).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF009B56)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF009B56)
                      : const Color(0xFF111827),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: const Color(0xFF009B56),
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/smd-dashboard');
        break;
      case 1:
        // Already on complaints screen, do nothing
        break;
      case 2:
        Navigator.pushNamed(context, '/smd-monitoring');
        break;
      case 3:
        Navigator.pushNamed(context, '/smd-settings');
        break;
    }
  }
}

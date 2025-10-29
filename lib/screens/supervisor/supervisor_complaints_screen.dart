import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../config/connstants.dart';
import '../../models/api_complaint_model.dart';
import '../../providers/supervisor_complaints_provider.dart';
import '../../services/auth_services.dart';
import '../../services/api_services.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../widgets/common/date_filter_bottom_sheet.dart';
import '../../l10n/app_localizations.dart';
import 'complaint_details_screen.dart';

class SupervisorComplaintsScreen extends StatefulWidget {
  const SupervisorComplaintsScreen({super.key});

  @override
  State<SupervisorComplaintsScreen> createState() =>
      _SupervisorComplaintsScreenState();
}

class _SupervisorComplaintsScreenState
    extends State<SupervisorComplaintsScreen> {
  String _selectedStatus = 'Open'; // Default to Open tab
  String _sortOrder = 'newest'; // 'newest' or 'oldest'
  int _selectedIndex = 1; // Complaints tab is selected
  bool _hasLoadedComplaints = false;
  String? _gpName;
  DateTime? _filterDate;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadComplaints();
    });
  }

  void _loadComplaints() {
    if (!_hasLoadedComplaints) {
      _hasLoadedComplaints = true;
      context.read<SupervisorComplaintsProvider>().loadComplaints();
      _loadGpName();
    }
  }

  Future<void> _loadGpName() async {
    try {
      final authService = AuthService();
      final villageId = await authService.getVillageId();

      if (villageId != null) {
        final gp = await ApiService().getGramPanchayatById(villageId);
        setState(() {
          _gpName = gp.name;
        });
      }
    } catch (e) {
      print('❌ Error loading GP name: $e');
      setState(() {
        _gpName = 'Gram Panchayat';
      });
    }
  }

  String _getCurrentMonth() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[DateTime.now().month - 1];
  }

  String _getDisplayMonth() {
    // If a date filter is applied, show the month of the selected date
    if (_filterDate != null) {
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return months[_filterDate!.month - 1];
    }

    // If a date range is applied, show the month of the start date
    if (_filterStartDate != null) {
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return months[_filterStartDate!.month - 1];
    }

    // Otherwise, show current month
    return _getCurrentMonth();
  }

  void _refreshComplaints() {
    context.read<SupervisorComplaintsProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(context),

            // Status Tabs
            _buildStatusTabs(context),

            // Complaints List
            Expanded(child: _buildComplaintsList(context)),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Navigate to different screens based on selection
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/supervisor-dashboard');
              break;
            case 1:
              // Already on complaints
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/supervisor-attendance');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/supervisor-settings');
              break;
          }
        },
        items: [
          BottomNavItem(
            icon: Icons.home,
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavItem(
            icon: Icons.list_alt,
            label: AppLocalizations.of(context)!.complaints,
          ),
          BottomNavItem(
            icon: Icons.people,
            label: AppLocalizations.of(context)!.attendance,
          ),
          BottomNavItem(
            icon: Icons.settings,
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final provider = context.watch<SupervisorComplaintsProvider>();
    final totalComplaints = provider.complaints.length;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n.complaints} ($totalComplaints)',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              Row(
                children: [
                  // Calendar icon
                  GestureDetector(
                    onTap: _showDateFilter,
                    child: Icon(
                      Icons.calendar_today,
                      size: 20.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Sort icon
                  GestureDetector(
                    onTap: _showSortOptions,
                    child: Icon(
                      Icons.swap_vert,
                      size: 20.sp,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            '${_gpName ?? 'Gram Panchayat'} • ${_getDisplayMonth()}',
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs(BuildContext context) {
    final provider = context.watch<SupervisorComplaintsProvider>();

    return SizedBox(
      height: 56.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        children: [
          _buildTab(
            context,
            AppLocalizations.of(context)!.open,
            provider.openComplaints.length,
            _selectedStatus == 'Open',
            0,
          ),
          SizedBox(width: 12.w),
          _buildTab(
            context,
            AppLocalizations.of(context)!.resolved,
            provider.resolvedComplaints.length,
            _selectedStatus == 'Resolved',
            1,
          ),
          SizedBox(width: 12.w),
          _buildTab(
            context,
            AppLocalizations.of(context)!.verified,
            provider.verifiedComplaints.length,
            _selectedStatus == 'Verified',
            2,
          ),
          SizedBox(width: 12.w),
          _buildTab(
            context,
            AppLocalizations.of(context)!.complaintClosed,
            provider.closedComplaints.length,
            _selectedStatus == 'Closed',
            3,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String status,
    int count,
    bool isSelected,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF009B56) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green dot indicator for active tab
            if (isSelected) ...[
              Container(
                width: 6.w,
                height: 6.h,
                decoration: const BoxDecoration(
                  color: Color(0xFF009B56),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              status,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF009B56)
                    : const Color(0xFF6B7280),
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              '($count)',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF009B56)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintsList(BuildContext context) {
    final provider = context.watch<SupervisorComplaintsProvider>();

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF009B56)),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.w, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              provider.errorMessage!,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _refreshComplaints,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    List<ApiComplaintModel> filteredComplaints = [];

    switch (_selectedStatus) {
      case 'Open':
        filteredComplaints = provider.openComplaints;
        break;
      case 'Resolved':
        filteredComplaints = provider.resolvedComplaints;
        break;
      case 'Verified':
        filteredComplaints = provider.verifiedComplaints;
        break;
      case 'Closed':
        filteredComplaints = provider.closedComplaints;
        break;
    }

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
          final complaintDate = DateTime.parse(complaint.createdAt);
          return complaintDate.year == _filterDate!.year &&
              complaintDate.month == _filterDate!.month &&
              complaintDate.day == _filterDate!.day;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    if (_filterStartDate != null && _filterEndDate != null) {
      filteredComplaints = filteredComplaints.where((complaint) {
        try {
          final complaintDate = DateTime.parse(complaint.createdAt);
          return complaintDate.isAfter(
                _filterStartDate!.subtract(const Duration(days: 1)),
              ) &&
              complaintDate.isBefore(
                _filterEndDate!.add(const Duration(days: 1)),
              );
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Sort complaints based on sort order
    if (_sortOrder == 'newest') {
      filteredComplaints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      filteredComplaints.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    if (filteredComplaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64.w, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'No ${_selectedStatus.toLowerCase()} complaints',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _refreshComplaints();
      },
      color: const Color(0xFF009B56),
      child: ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: filteredComplaints.length,
        itemBuilder: (context, index) {
          return _buildComplaintCard(filteredComplaints[index]);
        },
      ),
    );
  }

  Widget _buildComplaintCard(ApiComplaintModel complaint) {
    final firstMediaUrl = complaint.hasMedia ? complaint.firstMediaUrl : null;
    final mediaUrl = firstMediaUrl != null
        ? ApiConstants.getMediaUrl(firstMediaUrl)
        : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SupervisorComplaintDetailsScreen(complaintId: complaint.id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Complaint Image
            Container(
              height: 200.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
                color: Colors.grey.shade300,
              ),
              child: Stack(
                children: [
                  // Complaint image
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                    child: mediaUrl != null
                        ? Image.network(
                            mediaUrl,
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
                                    color: const Color(0xFF009B56),
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
                  // Date badge - white with dark text
                  Positioned(
                    bottom: 12.h,
                    right: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        _formatDate(complaint.createdAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
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
                  // Complaint Type and Location Icon
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFF009B56),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          complaint.complaintType,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      if (complaint.latitude != null &&
                          complaint.longitude != null) ...[
                        SizedBox(width: 8.w),
                        Image.asset(
                          'assets/icons/map.png',
                          width: 24.w,
                          height: 24.h,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Location with icon
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          complaint.location ?? complaint.fullLocation,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // Divider
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  // Description
                  Text(
                    complaint.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
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

  String _formatDate(String dateString) {
    try {
      // Parse the UTC date
      final date = DateTime.parse(dateString);
      // Convert to IST (UTC+5:30)
      final istDate = date.add(const Duration(hours: 5, minutes: 30));
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[istDate.month - 1]} ${istDate.day}, ${istDate.year}';
    } catch (e) {
      return 'Recent';
    }
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
            _buildSortOption('Newest First', _sortOrder == 'newest', () {
              setState(() {
                _sortOrder = 'newest';
              });
              Navigator.pop(context);
            }),
            SizedBox(height: 12.h),
            _buildSortOption('Oldest First', _sortOrder == 'oldest', () {
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

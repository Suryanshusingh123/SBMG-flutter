import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/connstants.dart';
import '../../models/api_complaint_model.dart';
import '../../providers/ceo_complaints_provider.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/location_display_helper.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../widgets/common/date_filter_bottom_sheet.dart';
import '../../l10n/app_localizations.dart';
import 'ceo_complaint_details_screen.dart';
import '../../services/auth_services.dart';
import '../../services/api_services.dart';
import '../../models/geography_model.dart';
import '../../screens/common/unified_select_location_screen.dart';
import '../../providers/ceo_provider.dart';

class CeoComplaintsScreen extends StatefulWidget {
  /// When true, this screen is shown inside [CeoShellScreen]; bottom nav is provided by the shell.
  final bool isEmbeddedInShell;

  const CeoComplaintsScreen({super.key, this.isEmbeddedInShell = false});

  @override
  State<CeoComplaintsScreen> createState() => _CeoComplaintsScreenState();
}

class _CeoComplaintsScreenState extends State<CeoComplaintsScreen> {
  String _selectedStatus = 'Open';
  String _sortOrder = 'newest';
  int _selectedIndex = 1;
  bool _hasLoadedComplaints = false;
  DateTime? _filterDate;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _districtName;
  Map<String, dynamic>? _complaintLocation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadComplaints();
      _loadDistrictName();
      _loadSavedLocation();
    });
  }

  Future<void> _loadSavedLocation() async {
    // Load saved location for COMPLAINTS page if available
    // Fallback to old inspection location for backward compatibility
    var savedLocation = await _authService.getPageLocation('ceo', 'complaints');
    savedLocation ??= await _authService.getInspectionLocation('ceo');
    if (savedLocation != null && mounted) {
      setState(() {
        _complaintLocation = savedLocation;
      });
    }
  }

  void _loadComplaints() {
    if (!_hasLoadedComplaints) {
      _hasLoadedComplaints = true;
      context.read<CeoComplaintsProvider>().loadComplaints();
    }
  }

  Future<void> _loadDistrictName() async {
    try {
      final authService = AuthService();
      final apiService = ApiService();
      final districtId = await authService.getDistrictId();
      if (districtId == null) {
        if (mounted) {
          setState(
            () => _districtName = AppLocalizations.of(context)!.district,
          );
        }
        return;
      }

      final districts = await apiService.getDistricts();
      final districtLabel = AppLocalizations.of(context)!.district;
      final district = districts.firstWhere(
        (d) => d.id == districtId,
        orElse: () => District(id: districtId, name: districtLabel),
      );

      if (mounted) {
        setState(() {
          _districtName = district.name;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _districtName = AppLocalizations.of(context)!.district;
        });
      }
    }
  }

  String _getCurrentMonth(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('MMMM', locale).format(DateTime.now());
  }

  String _getDisplayMonth(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    if (_filterDate != null) {
      return DateFormat('MMMM', locale).format(_filterDate!);
    }
    if (_filterStartDate != null) {
      return DateFormat('MMMM', locale).format(_filterStartDate!);
    }
    return _getCurrentMonth(context);
  }

  void _refreshComplaints() {
    context.read<CeoComplaintsProvider>().loadComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildStatusTabs(context),
            Expanded(child: _buildComplaintsList(context)),
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
                    Navigator.pushReplacementNamed(context, '/ceo-dashboard');
                    break;
                  case 1:
                    break;
                  case 2:
                    Navigator.pushReplacementNamed(context, '/ceo-monitoring');
                    break;
                  case 3:
                    Navigator.pushReplacementNamed(context, '/ceo-settings');
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
  }

  Widget _buildHeader(BuildContext context) {
    final provider = context.watch<CeoComplaintsProvider>();
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
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UnifiedSelectLocationScreen(
                            userRole: 'ceo',
                          ),
                        ),
                      );
                      if (result is Map<String, dynamic>) {
                        print('📍 Location changed - New location: $result');
                        print('   - District ID: ${result['districtId']}');
                        print('   - Block ID: ${result['blockId']}');
                        print('   - GP ID: ${result['gpId']}');
                        // Save the location for COMPLAINTS page (block/GP optional for CEO)
                        await _authService.savePageLocation(
                          'ceo',
                          'complaints',
                          result,
                        );
                        final saved = await _authService.getPageLocation(
                          'ceo',
                          'complaints',
                        );
                        print('💾 Verified saved location: $saved');
                        if (saved == null) {
                          print('❌ ERROR: Location was not saved correctly!');
                          return;
                        }
                        setState(() {
                          _complaintLocation = result;
                        });
                        if (mounted) {
                          context
                              .read<CeoComplaintsProvider>()
                              .loadComplaints();
                        }
                      } else {
                        print(
                          '⚠️ Location change cancelled or invalid result: $result',
                        );
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Icon(
                        Icons.location_on,
                        size: 18.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showDateFilter,
                    child: Icon(
                      Icons.calendar_today,
                      size: 18.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: _showSortOptions,
                    child: Icon(
                      Icons.swap_vert,
                      size: 18.sp,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Consumer<CeoProvider>(
            builder: (context, ceoProvider, child) {
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
                locationText = parts.isNotEmpty
                    ? parts.join(' • ')
                    : ceoProvider.locationPath;
              } else {
                locationText = ceoProvider.locationPath.isNotEmpty
                    ? ceoProvider.locationPath
                    : (_districtName ?? 'District');
              }

              return Text(
                '$locationText • ${_getDisplayMonth(context)}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF6B7280),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              );
            },
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
          return (complaintDate.isAfter(
                    startDate.subtract(const Duration(seconds: 1)),
                  ) ||
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

  Widget _buildStatusTabs(BuildContext context) {
    final provider = context.watch<CeoComplaintsProvider>();

    return SizedBox(
      height: 40.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        children: [
          _buildTab(
            context,
            AppLocalizations.of(context)!.open,
            _getFilteredCount(provider.openComplaints),
            _selectedStatus == 'Open',
            0,
          ),
          SizedBox(width: 12.w),
          _buildTab(
            context,
            AppLocalizations.of(context)!.resolved,
            _getFilteredCount(provider.resolvedComplaints),
            _selectedStatus == 'Resolved',
            1,
          ),
          SizedBox(width: 12.w),
          _buildTab(
            context,
            AppLocalizations.of(context)!.verified,
            _getFilteredCount(provider.verifiedComplaints),
            _selectedStatus == 'Verified',
            2,
          ),
          SizedBox(width: 12.w),
          _buildTab(
            context,
            AppLocalizations.of(context)!.complaintClosed,
            _getFilteredCount(provider.closedComplaints),
            _selectedStatus == AppLocalizations.of(context)!.complaintClosed,
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
                fontSize: 14.sp,
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
    final provider = context.watch<CeoComplaintsProvider>();

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
      case 'Disposed complaints':
      case 'Closed': // Fallback for backwards compatibility
      case 'निपटाई गई शिकायतें': // Hindi fallback
        filteredComplaints = provider.closedComplaints;
        break;
    }

    final Map<int, ApiComplaintModel> uniqueComplaints = {};
    for (final complaint in filteredComplaints) {
      if (!uniqueComplaints.containsKey(complaint.id)) {
        uniqueComplaints[complaint.id] = complaint;
      }
    }
    filteredComplaints = uniqueComplaints.values.toList();

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
          return (complaintDate.isAfter(
                    startDate.subtract(const Duration(seconds: 1)),
                  ) ||
                  complaintDate.isAtSameMomentAs(startDate)) &&
              (complaintDate.isBefore(endDate) ||
                  complaintDate.isAtSameMomentAs(endDate));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Sort complaints based on sort order (including time)
    if (_sortOrder == 'newest') {
      filteredComplaints.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.createdAt).toUtc();
          final dateB = DateTime.parse(b.createdAt).toUtc();
          return dateB.compareTo(dateA); // Newest first (descending)
        } catch (e) {
          return b.createdAt.compareTo(
            a.createdAt,
          ); // Fallback to string comparison
        }
      });
    } else {
      filteredComplaints.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.createdAt).toUtc();
          final dateB = DateTime.parse(b.createdAt).toUtc();
          return dateA.compareTo(dateB); // Oldest first (ascending)
        } catch (e) {
          return a.createdAt.compareTo(
            b.createdAt,
          ); // Fallback to string comparison
        }
      });
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
    final provider = context.watch<CeoComplaintsProvider>();
    final firstMediaUrl = complaint.hasMedia ? complaint.firstMediaUrl : null;
    final mediaUrl = firstMediaUrl != null
        ? ApiConstants.getMediaUrl(firstMediaUrl)
        : null;
    final l10n = AppLocalizations.of(context)!;
    final locationText = LocationDisplayHelper.buildDisplay(
      cacheKey: 'ceo-${complaint.id}',
      latitude: complaint.latitude,
      longitude: complaint.longitude,
      locationField: complaint.location,
      district: complaint.districtName,
      block: complaint.blockName,
      village: complaint.villageName,
      scheduleUpdate: () {
        if (!mounted) return;
        setState(() {});
      },
      unavailableLabel: l10n.locationNotAvailable,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CeoComplaintDetailsScreen(complaintId: complaint.id),
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
            Container(
              height: 150.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
                color: Colors.grey.shade300,
              ),
              child: Stack(
                children: [
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
                                    size: 40,
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
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
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
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                          provider.getComplaintTypeDisplayName(complaint),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          locationText,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  Text(
                    complaint.description,
                    style: TextStyle(
                      fontSize: 12.sp,
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

  String _formatDate(String dateString) =>
      DateTimeUtils.formatComplaintListIST(dateString);

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
        setState(() {
          _filterDate = selectedDate;
          _filterStartDate = startDate;
          _filterEndDate = endDate;
        });
      },
    );
  }
}

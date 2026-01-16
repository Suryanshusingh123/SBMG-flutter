import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/connstants.dart';
import '../../providers/ceo_inspection_provider.dart';
import '../../providers/ceo_provider.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../widgets/common/date_filter_bottom_sheet.dart';
import '../../l10n/app_localizations.dart';
import '../../models/inspection_model.dart';
import '../../services/auth_services.dart';
import '../common/unified_select_location_screen.dart';

class CeoInspectionScreen extends StatefulWidget {
  const CeoInspectionScreen({super.key});

  @override
  State<CeoInspectionScreen> createState() => _CeoInspectionScreenState();
}

class _CeoInspectionScreenState extends State<CeoInspectionScreen> {
  int _selectedIndex = 2; // Inspection tab
  bool _hasLoadedInspections = false;
  bool _hasCheckedLocation = false;
  Map<String, dynamic>? _inspectionLocation;
  DateTime? _filterDate;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadLocation();
    });
  }

  Future<void> _checkAndLoadLocation() async {
    if (_hasCheckedLocation) return;

    // Check if inspection location exists
    final location = await _authService.getInspectionLocation('ceo');
    
    if (location == null || location['gpId'] == null) {
      // Show location selection screen once
      if (!mounted) return;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const UnifiedSelectLocationScreen(userRole: 'ceo'),
        ),
      );

      if (result is Map<String, dynamic> && result['gpId'] != null) {
        setState(() {
          _inspectionLocation = result;
        });
      } else {
        // User cancelled, go back
        Navigator.pop(context);
        return;
      }
    } else {
      setState(() {
        _inspectionLocation = location;
      });
    }

    _hasCheckedLocation = true;
    
    if (!_hasLoadedInspections) {
      _hasLoadedInspections = true;
      if (mounted) {
        context.read<CeoInspectionProvider>().loadInspections();
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final istDate = date.add(const Duration(hours: 5, minutes: 30));
      return DateFormat('d MMM yyyy').format(istDate);
    } catch (e) {
      return dateString;
    }
  }

  String _todayPretty() {
    final now = DateTime.now();
    return '${DateFormat('EEE, d MMM yyyy').format(now)} (today)';
  }

  String _displayMonth() {
    final date = _filterDate ?? _filterStartDate ?? DateTime.now();
    return DateFormat('MMMM').format(date);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildCurrentInspectionCard(context),
            Expanded(child: _buildInspectionLog(context)),
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
              Navigator.pushReplacementNamed(context, '/ceo-dashboard');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/ceo-complaints');
              break;
            case 2:
              // already on inspections
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
    final provider = context.watch<CeoInspectionProvider>();
    final ceoProvider = context.watch<CeoProvider>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppLocalizations.of(context)!.inspection} (${provider.totalInspections})',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              Row(
                children: [
                  if (_inspectionLocation != null)
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UnifiedSelectLocationScreen(userRole: 'ceo'),
                          ),
                        );
                        if (result is Map<String, dynamic> && result['gpId'] != null) {
                          setState(() {
                            _inspectionLocation = result;
                          });
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: Icon(
                          Icons.location_on,
                          size: 18,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: _showDateFilter,
                    child: const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            _inspectionLocation != null
                ? '${_inspectionLocation!['districtName']} • ${_inspectionLocation!['blockName']} • ${_inspectionLocation!['gpName']} • ${_displayMonth()}'
                : '${ceoProvider.districtName} • ${_displayMonth()}',
            style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentInspectionCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
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
          Row(
            children: [
              Icon(Icons.event, color: Colors.green.shade700, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                _todayPretty(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
            SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _inspectionLocation == null ? null : () {
                // Use stored location for new inspection
                Navigator.pushNamed(
                  context,
                  '/ceo-new-inspection',
                  arguments: {
                    'gpId': _inspectionLocation!['gpId'],
                    'gpName': _inspectionLocation!['gpName'] ?? '',
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start new inspection',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionLog(BuildContext context) {
    final provider = context.watch<CeoInspectionProvider>();
    final inspections = _getFilteredInspections(provider.inspections);

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF009B56)),
      );
    }

    if (inspections.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'No inspections found',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _buildViewGpsInspectionButton(context),
          ),
          SizedBox(height: 20.h),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inspection log (${provider.totalInspections})',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              Text(
                'Month',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<CeoInspectionProvider>().loadInspections();
            },
            color: const Color(0xFF009B56),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: inspections.length,
              itemBuilder: (context, index) {
                return _buildInspectionCard(inspections[index]);
              },
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _buildViewGpsInspectionButton(context),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildInspectionCard(Inspection inspection) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.description, color: Colors.white, size: 18.sp),
                Positioned(
                  left: 6.w,
                  top: 6.h,
                  child: Icon(
                    Icons.description,
                    color: Colors.white.withOpacity(0.7),
                    size: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(inspection.date),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  inspection.villageName,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey.shade400,
            size: 14.sp,
          ),
        ],
      ),
    );
  }

  List<Inspection> _getFilteredInspections(List<Inspection> inspections) {
    List<Inspection> filtered = List.from(inspections);

    if (_filterDate != null) {
      filtered = filtered.where((insp) {
        try {
          final d = DateTime.parse(insp.date);
          return d.year == _filterDate!.year &&
              d.month == _filterDate!.month &&
              d.day == _filterDate!.day;
        } catch (_) {
          return false;
        }
      }).toList();
    }

    if (_filterStartDate != null && _filterEndDate != null) {
      filtered = filtered.where((insp) {
        try {
          final d = DateTime.parse(insp.date);
          return d.isAfter(
                _filterStartDate!.subtract(const Duration(days: 1)),
              ) &&
              d.isBefore(_filterEndDate!.add(const Duration(days: 1)));
        } catch (_) {
          return false;
        }
      }).toList();
    }

    // Sort by date and time (newest first, including time)
    filtered.sort((a, b) {
      try {
        final da = DateTime.parse(a.date).toUtc();
        final db = DateTime.parse(b.date).toUtc();
        return db.compareTo(da); // Newest first (descending)
      } catch (_) {
        return 0;
      }
    });

    return filtered;
  }

  Widget _buildViewGpsInspectionButton(BuildContext context) {
    return GestureDetector(
      onTap: _inspectionLocation == null ? null : () async {
        // Use stored location
        final int gpId = _inspectionLocation!['gpId'] as int;
        final String gpName = _inspectionLocation!['gpName'] as String;
        final int? blockId = _inspectionLocation!['blockId'] as int?;
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _CeoGpInspectionScreen(
              gpId: gpId,
              gpName: gpName,
              blockId: blockId,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFF34D399).withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.apartment, color: Colors.green.shade700),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'View GPs inspection',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }
}

class _CeoGpInspectionScreen extends StatefulWidget {
  final int gpId;
  final String gpName;
  final int? blockId;

  const _CeoGpInspectionScreen({
    required this.gpId,
    required this.gpName,
    this.blockId,
  });

  @override
  State<_CeoGpInspectionScreen> createState() => _CeoGpInspectionScreenState();
}

class _CeoGpInspectionScreenState extends State<_CeoGpInspectionScreen> {
  DateTime? _filterDate;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CeoInspectionProvider>().loadInspectionsForGp(
        gpId: widget.gpId,
      );
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final istDate = date.add(const Duration(hours: 5, minutes: 30));
      return DateFormat('d MMM yyyy').format(istDate);
    } catch (e) {
      return dateString;
    }
  }

  List<Inspection> _filtered(List<Inspection> inspections) {
    List<Inspection> filtered = List.from(inspections);

    if (_filterDate != null) {
      filtered = filtered.where((insp) {
        try {
          final d = DateTime.parse(insp.date);
          return d.year == _filterDate!.year &&
              d.month == _filterDate!.month &&
              d.day == _filterDate!.day;
        } catch (_) {
          return false;
        }
      }).toList();
    }

    if (_filterStartDate != null && _filterEndDate != null) {
      filtered = filtered.where((insp) {
        try {
          final d = DateTime.parse(insp.date);
          return d.isAfter(
                _filterStartDate!.subtract(const Duration(days: 1)),
              ) &&
              d.isBefore(_filterEndDate!.add(const Duration(days: 1)));
        } catch (_) {
          return false;
        }
      }).toList();
    }

    // Sort by date and time (newest first, including time)
    filtered.sort((a, b) {
      try {
        final da = DateTime.parse(a.date).toUtc();
        final db = DateTime.parse(b.date).toUtc();
        return db.compareTo(da); // Newest first (descending)
      } catch (_) {
        return 0;
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CeoInspectionProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.gpName,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
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
              },
              child: const Icon(
                Icons.calendar_today,
                size: 18,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: Text(
              'Inspection log (${provider.totalInspections})',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.gpName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  'Month',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _filtered(provider.inspections).length,
                    itemBuilder: (context, index) {
                      final inspection = _filtered(provider.inspections)[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
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
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.description,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                  Positioned(
                                    left: 6.w,
                                    top: 6.h,
                                    child: Icon(
                                      Icons.description,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(inspection.date),
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    inspection.villageName,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey.shade400,
                              size: 14.sp,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

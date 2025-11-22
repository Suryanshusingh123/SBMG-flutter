import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/connstants.dart';
import '../../providers/vdo_inspection_provider.dart';
import '../../providers/vdo_provider.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../widgets/common/date_filter_bottom_sheet.dart';
import '../../l10n/app_localizations.dart';
import '../../models/inspection_model.dart';
import 'new_inspection_screen.dart';

class VdoInspectionScreen extends StatefulWidget {
  const VdoInspectionScreen({super.key});

  @override
  State<VdoInspectionScreen> createState() => _VdoInspectionScreenState();
}

class _VdoInspectionScreenState extends State<VdoInspectionScreen> {
  int _selectedIndex = 2; // Inspection tab is selected
  bool _hasLoadedInspections = false;
  DateTime? _filterDate;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInspections();
    });
  }

  void _loadInspections() {
    if (!_hasLoadedInspections) {
      _hasLoadedInspections = true;
      context.read<VdoInspectionProvider>().loadInspections();
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

  void _refreshInspections() {
    context.read<VdoInspectionProvider>().loadInspections();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      // Convert to IST (UTC+5:30)
      final istDate = date.add(const Duration(hours: 5, minutes: 30));
      return DateFormat('d MMM yyyy').format(istDate);
    } catch (e) {
      return dateString;
    }
  }

  String _getTodayDate() {
    final now = DateTime.now();
    final today = DateFormat('EEE, d MMM yyyy').format(now);
    return '$today (today)';
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

            // Current Inspection Card
            _buildCurrentInspectionCard(context),

            // Inspection Log Section
            Expanded(child: _buildInspectionLog(context)),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == _selectedIndex) return;

          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/vdo-dashboard');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/vdo-complaints');
              break;
            case 2:
              // Already on inspection
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/vdo-settings');
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
    final inspectionProvider = context.watch<VdoInspectionProvider>();
    final vdoProvider = context.watch<VdoProvider>();
    final totalInspections = inspectionProvider.totalInspections;
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
                '${l10n.inspection} ($totalInspections)',
                style: TextStyle(
                  fontSize: 18.sp,
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
                      size: 18.sp,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            '${vdoProvider.villageName} • ${_getDisplayMonth()}',
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
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTodayDate(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewInspectionScreen(),
                    ),
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
      ),
    );
  }

  Widget _buildInspectionLog(BuildContext context) {
    final provider = context.watch<VdoInspectionProvider>();

    if (provider.isInspectionsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF009B56)),
      );
    }

    if (provider.inspections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64.w, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'No inspections found',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Log Header
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
                'Month/date',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),

        // Inspection List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _refreshInspections();
            },
            color: const Color(0xFF009B56),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _getFilteredInspections(provider.inspections).length,
              itemBuilder: (context, index) {
                return _buildInspectionCard(
                  _getFilteredInspections(provider.inspections)[index],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInspectionCard(Inspection inspection) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to inspection details
      },
      child: Container(
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
      ),
    );
  }

  List<Inspection> _getFilteredInspections(List<Inspection> inspections) {
    List<Inspection> filteredInspections = List.from(inspections);

    // Apply date filters
    if (_filterDate != null) {
      filteredInspections = filteredInspections.where((inspection) {
        try {
          final inspectionDate = DateTime.parse(inspection.date);
          return inspectionDate.year == _filterDate!.year &&
              inspectionDate.month == _filterDate!.month &&
              inspectionDate.day == _filterDate!.day;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    if (_filterStartDate != null && _filterEndDate != null) {
      filteredInspections = filteredInspections.where((inspection) {
        try {
          final inspectionDate = DateTime.parse(inspection.date);
          return inspectionDate.isAfter(
                _filterStartDate!.subtract(const Duration(days: 1)),
              ) &&
              inspectionDate.isBefore(
                _filterEndDate!.add(const Duration(days: 1)),
              );
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Sort by date and time (newest first, including time)
    filteredInspections.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.date).toUtc();
        final dateB = DateTime.parse(b.date).toUtc();
        return dateB.compareTo(dateA); // Newest first (descending)
      } catch (e) {
        return 0;
      }
    });

    return filteredInspections;
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

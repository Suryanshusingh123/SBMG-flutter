import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'qr_scanner_screen.dart';
import '../../widgets/common/date_filter_bottom_sheet.dart';
import '../../providers/supervisor_attendance_provider.dart';

class SupervisorAttendanceScreen extends StatefulWidget {
  const SupervisorAttendanceScreen({super.key});

  @override
  State<SupervisorAttendanceScreen> createState() =>
      _SupervisorAttendanceScreenState();
}

class _SupervisorAttendanceScreenState
    extends State<SupervisorAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    // Load attendance state and logs using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SupervisorAttendanceProvider>();
      provider.loadAttendanceState();
      provider.fetchAttendanceLogs();
    });
  }

  // Convert coordinates to readable address using reverse geocoding
  Future<String> _getAddressFromCoordinates(
    SupervisorAttendanceProvider provider,
    String? lat,
    String? long,
  ) async {
    if (lat == null || long == null || lat.isEmpty || long.isEmpty) {
      return 'Unknown Location';
    }

    // Create cache key
    final cacheKey = '${lat}_$long';

    // Check if address is already cached
    final cachedAddress = provider.getCachedAddress(cacheKey);
    if (cachedAddress != null) {
      return cachedAddress;
    }

    try {
      // Parse coordinates
      final latitude = double.tryParse(lat);
      final longitude = double.tryParse(long);

      if (latitude == null || longitude == null) {
        return 'Invalid Coordinates';
      }

      // Check if coordinates are valid (not dummy/test data)
      if (latitude == 1.0 && longitude == 1.0) {
        return 'Test Location';
      }

      // Check if coordinates are within valid ranges
      if (latitude < -90 ||
          latitude > 90 ||
          longitude < -180 ||
          longitude > 180) {
        return 'Invalid Coordinates';
      }

      print('🔍 Reverse geocoding for: $latitude, $longitude');

      // Perform reverse geocoding
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      print('📍 Found ${placemarks.length} placemarks');

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        // Build address from available components (more comprehensive)
        final addressComponents = <String>[];

        // Add street information if available
        if (placemark.street?.isNotEmpty == true) {
          addressComponents.add(placemark.street!);
        } else if (placemark.thoroughfare?.isNotEmpty == true) {
          addressComponents.add(placemark.thoroughfare!);
        }

        // Add locality information
        if (placemark.subLocality?.isNotEmpty == true) {
          addressComponents.add(placemark.subLocality!);
        } else if (placemark.locality?.isNotEmpty == true) {
          addressComponents.add(placemark.locality!);
        }

        // Add administrative area
        if (placemark.subAdministrativeArea?.isNotEmpty == true) {
          addressComponents.add(placemark.subAdministrativeArea!);
        } else if (placemark.administrativeArea?.isNotEmpty == true) {
          addressComponents.add(placemark.administrativeArea!);
        }

        // Add country
        if (placemark.country?.isNotEmpty == true) {
          addressComponents.add(placemark.country!);
        }

        final address = addressComponents.isNotEmpty
            ? addressComponents.join(', ')
            : 'Location at ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

        print('📍 Final address: $address');

        // Cache the result
        provider.cacheAddress(cacheKey, address);

        return address;
      } else {
        print('📍 No placemarks found for coordinates: $latitude, $longitude');
        return 'Location at ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
      }
    } catch (e) {
      print('❌ Error in reverse geocoding: $e');
      return 'Location at $lat, $long';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupervisorAttendanceProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(provider),

                // Current Day Attendance Card
                _buildCurrentDayCard(provider),

                // Attendance Summary
                _buildAttendanceSummary(provider),

                // Attendance Log
                _buildAttendanceLog(provider),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        );
      },
    );
  }

  Widget _buildHeader(SupervisorAttendanceProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Attendance',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          GestureDetector(
            onTap: () => _showDateFilter(provider),
            child: const Icon(
              Icons.calendar_today,
              size: 20,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentDayCard(SupervisorAttendanceProvider provider) {
    final now = DateTime.now();
    final dayName = DateFormat('EEE').format(now);
    final day = now.day;
    final month = DateFormat('MMM').format(now);
    final year = now.year;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: const Color(0xFF009B56),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '$dayName, $day $month $year (today)',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF111827),
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () => _handleAttendanceAction(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.isAttendanceActive
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF009B56),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          provider.isAttendanceActive
                              ? Icons.stop_circle
                              : Icons.grid_view,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          provider.isAttendanceActive
                              ? 'End Attendance'
                              : 'Mark Attendance',
                          style: const TextStyle(
                            fontFamily: 'Noto Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.arrow_forward, size: 16.sp),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummary(SupervisorAttendanceProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance log (${provider.presentDays}/${provider.totalAttendances}) - ${provider.selectedFilter}',
                style: const TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                  letterSpacing: 0,
                ),
              ),
              Text(
                provider.selectedMonthName,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4B5563),
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total days',
                  provider.totalWorkingDays.toString(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildSummaryCard(
                  'Present',
                  provider.presentDays.toString(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildSummaryCard(
                  'Absent',
                  provider.absentDays.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Container(
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
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceLog(SupervisorAttendanceProvider provider) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Expanded(
              child: provider.isLoadingLogs
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF009B56),
                      ),
                    )
                  : provider.filteredAttendanceLog.isEmpty
                  ? Center(
                      child: Text(
                        'No attendance records found',
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: provider.filteredAttendanceLog.length,
                      itemBuilder: (context, index) {
                        return _buildAttendanceItem(
                          provider.filteredAttendanceLog[index],
                          provider,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceItem(
    Map<String, dynamic> attendance,
    SupervisorAttendanceProvider provider,
  ) {
    // Parse date
    final dateStr = attendance['date'] as String?;
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    final day = date != null ? DateFormat('d').format(date) : '?';
    final month = date != null ? DateFormat('MMM').format(date) : '?';

    // Get coordinates for reverse geocoding
    final startLat = attendance['start_lat'] as String?;
    final startLong = attendance['start_long'] as String?;

    // Determine status
    final endTime = attendance['end_time'];
    final isPresent = endTime != null;
    final status = isPresent ? 'Present' : 'Incomplete';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Date Circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF009B56),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  month,
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),

          // Address
          Expanded(
            child: FutureBuilder<String>(
              future: _getAddressFromCoordinates(provider, startLat, startLong),
              builder: (context, snapshot) {
                String displayAddress = 'Loading...';

                if (snapshot.hasData) {
                  displayAddress = snapshot.data!;
                } else if (snapshot.hasError) {
                  displayAddress = 'Unknown Location';
                }

                return Text(
                  displayAddress,
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                  ),
                );
              },
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPresent
                  ? const Color(0xFFD1FAE5)
                  : const Color(0xFFFFF4E6),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isPresent
                    ? const Color(0xFF009B56)
                    : const Color(0xFFF59E0B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.list_alt, 'Complaint', 1),
          _buildNavItem(Icons.grid_view, 'Attendance', 2, isActive: true),
          _buildNavItem(Icons.settings, 'Settings', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index, {
    bool isActive = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/supervisor-dashboard');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/supervisor-complaints');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/supervisor-settings');
          }
        },
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE8F5E8) : Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24.sp,
                color: isActive
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF9CA3AF),
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF111827)
                      : const Color(0xFF9CA3AF),
                ),
              ),
              SizedBox(height: 4.h),
              if (isActive)
                Container(
                  width: 24,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                )
              else
                SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAttendanceAction(SupervisorAttendanceProvider provider) {
    if (provider.isAttendanceActive) {
      _endAttendance(provider);
    } else {
      _markAttendance(provider);
    }
  }

  Future<void> _markAttendance(SupervisorAttendanceProvider provider) async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null && mounted) {
      final lat = result['lat'] as String;
      final long = result['long'] as String;

      print('📍 QR Code Scanned Successfully');
      print('   Lat: $lat');
      print('   Long: $long');

      final response = await provider.markAttendance(lat, long);

      if (mounted) {
        if (response['success']) {
          // Reload attendance logs to show latest data
          await provider.fetchAttendanceLogs();

          _showSuccessDialog(
            'Attendance Marked',
            response['message'] ??
                'Your attendance has been successfully marked.',
          );
        } else {
          _showErrorDialog(response['message'] ?? 'Failed to mark attendance');
        }
      }
    }
  }

  Future<void> _endAttendance(SupervisorAttendanceProvider provider) async {
    if (provider.currentAttendanceId == null ||
        provider.startLat == null ||
        provider.startLong == null) {
      _showErrorDialog('No active attendance session found');
      return;
    }

    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null && mounted) {
      final lat = result['lat'] as String;
      final long = result['long'] as String;

      final response = await provider.endAttendance(lat, long);

      if (mounted) {
        if (response['success']) {
          _showSuccessDialog(
            'Attendance Ended',
            response['message'] ??
                'Your attendance has been successfully ended.',
          );
        } else {
          _showErrorDialog(response['message'] ?? 'Failed to end attendance');
        }
      }
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF009B56), size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF009B56),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'Error',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDateFilter(SupervisorAttendanceProvider? provider) {
    if (provider == null) return;

    showDateFilterBottomSheet(
      context: context,
      initialFilterType: DateFilterType.month,
      onApply: (filterType, selectedDate, startDate, endDate) {
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📅 CALENDAR SELECTION RECEIVED');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('🔍 Filter type: $filterType');
        print('📅 Selected date: $selectedDate');
        print('📅 Start date: $startDate');
        print('📅 End date: $endDate');

        // Update the selected month name based on the selection
        if (startDate != null && endDate != null) {
          // Use the start date for the month name
          provider.updateSelectedMonth(startDate);
          provider.applyCustomDateRangeFilter(startDate, endDate);
        } else if (selectedDate != null) {
          provider.updateSelectedMonth(selectedDate);
          provider.applyCustomDateRangeFilter(selectedDate, selectedDate);
        }

        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      },
    );
  }
}

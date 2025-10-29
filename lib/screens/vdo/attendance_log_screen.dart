import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../widgets/common/date_filter_bottom_sheet.dart';

class VdoAttendanceLogScreen extends StatefulWidget {
  const VdoAttendanceLogScreen({super.key});

  @override
  State<VdoAttendanceLogScreen> createState() => _VdoAttendanceLogScreenState();
}

class _VdoAttendanceLogScreenState extends State<VdoAttendanceLogScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // Data
  List<Map<String, dynamic>> _attendanceList = [];
  List<Map<String, dynamic>> _filteredAttendanceList = [];
  bool _isLoading = true;

  // Location IDs
  int? _villageId;
  int? _blockId;
  int? _districtId;

  // Date filtering
  DateTime _selectedDate = DateTime.now();
  String _selectedMonthName = '';

  @override
  void initState() {
    super.initState();
    _selectedMonthName = DateFormat('MMMM').format(_selectedDate);
    _initializeData();
  }

  Future<void> _initializeData() async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔵 ATTENDANCE LOG INITIALIZATION');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('⏰ Timestamp: ${DateTime.now()}');

    try {
      // Get location IDs from /me API
      print('📋 Step 1: Fetching user information...');
      final userInfo = await _authService.getCurrentUser();
      if (userInfo['success']) {
        final userData = userInfo['user'] as Map<String, dynamic>;
        final villageId = userData['village_id'];
        final blockId = userData['block_id'];
        final districtId = userData['district_id'];

        print('✅ User information retrieved');
        print('📍 Location IDs:');
        print('   - Village ID: $villageId');
        print('   - Block ID: $blockId');
        print('   - District ID: $districtId');

        setState(() {
          _villageId = villageId;
          _blockId = blockId;
          _districtId = districtId;
        });

        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📋 Step 2: Fetching attendance data...');
        await _fetchAttendanceData();
      } else {
        print('❌ Failed to get user information');
        throw Exception('Failed to get user information');
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ ERROR INITIALIZING ATTENDANCE LOG');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 Error: $e');
      print('📚 Error type: ${e.runtimeType}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAttendanceData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔵 FETCHING ATTENDANCE DATA');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 Parameters:');
    print('   - Village ID: $_villageId');
    print('   - Block ID: $_blockId');
    print('   - District ID: $_districtId');

    if (startDate != null && endDate != null) {
      print('   - Start Date: ${DateFormat('yyyy-MM-dd').format(startDate)}');
      print('   - End Date: ${DateFormat('yyyy-MM-dd').format(endDate)}');
    } else {
      print('   - Date Range: All records');
    }
    print('⏰ Timestamp: ${DateTime.now()}');

    setState(() {
      _isLoading = true;
    });

    try {
      String? startDateStr;
      String? endDateStr;

      if (startDate != null && endDate != null) {
        startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
        endDateStr = DateFormat('yyyy-MM-dd').format(endDate);
      }

      final response = await _apiService.getAttendanceViewForBDO(
        villageId: _villageId,
        blockId: _blockId,
        districtId: _districtId,
        startDate: startDateStr,
        endDate: endDateStr,
        skip: 0,
        limit: 500,
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 ATTENDANCE DATA RECEIVED');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response['success']) {
        final data = response['data'] as Map<String, dynamic>;
        final attendances = List<Map<String, dynamic>>.from(
          data['attendances'] ?? [],
        );

        print('✅ API Response successful');
        print('📊 Data Summary:');
        print('   - Total attendances: ${data['total'] ?? 0}');
        print('   - Attendances received: ${attendances.length}');
        print('   - Page: ${data['page'] ?? 0}');
        print('   - Limit: ${data['limit'] ?? 500}');

        // Log first few attendance records
        final logCount = attendances.length > 5 ? 5 : attendances.length;
        for (int i = 0; i < logCount; i++) {
          final att = attendances[i];
          print('   📋 Attendance ${i + 1}:');
          print('      - ID: ${att['id']}');
          print('      - Date: ${att['date']}');
          print('      - Village: ${att['village_name']}');
          print(
            '      - Status: ${att['end_time'] != null ? "Present" : "Absent"}',
          );
        }
        if (attendances.length > 5) {
          print('   ... and ${attendances.length - 5} more records');
        }

        setState(() {
          _attendanceList = attendances;
          _filteredAttendanceList = List.from(_attendanceList);
          _isLoading = false;
        });

        print('✅ Attendance data loaded and filtered');
      } else {
        print('❌ API Response failed');
        print('   - Message: ${response['message'] ?? "Unknown error"}');
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to load attendance'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ ERROR FETCHING ATTENDANCE DATA');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 Error: $e');
      print('📚 Error type: ${e.runtimeType}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading attendance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyDateFilter(DateTime startDate, DateTime endDate) {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔵 APPLYING DATE FILTER');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📅 Filter Range:');
    print('   - Start: ${DateFormat('yyyy-MM-dd').format(startDate)}');
    print('   - End: ${DateFormat('yyyy-MM-dd').format(endDate)}');
    print('📊 Before Filter: ${_attendanceList.length} records');

    setState(() {
      _selectedDate = startDate;
      _selectedMonthName = DateFormat('MMMM').format(startDate);
      _filteredAttendanceList = _attendanceList.where((attendance) {
        final attendanceDate = DateTime.parse(attendance['date'] as String);
        final attendanceDateOnly = DateTime(
          attendanceDate.year,
          attendanceDate.month,
          attendanceDate.day,
        );
        final startDateOnly = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

        return (attendanceDateOnly.isAtSameMomentAs(startDateOnly) ||
                attendanceDateOnly.isAfter(startDateOnly)) &&
            (attendanceDateOnly.isAtSameMomentAs(endDateOnly) ||
                attendanceDateOnly.isBefore(endDateOnly));
      }).toList();
    });

    print('📊 After Filter: ${_filteredAttendanceList.length} records');

    final presentCount = _filteredAttendanceList
        .where((attendance) => attendance['end_time'] != null)
        .length;
    final absentCount = _filteredAttendanceList
        .where((attendance) => attendance['end_time'] == null)
        .length;

    print('📈 Summary:');
    print('   - Total: ${_filteredAttendanceList.length}');
    print('   - Present: $presentCount');
    print('   - Absent: $absentCount');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  void _showDateFilter() {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📅 OPENING DATE FILTER');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 Current selection:');
    print(
      '   - Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
    );
    print('   - Month: $_selectedMonthName');
    print('   - Filtered Records: ${_filteredAttendanceList.length}');

    showDateFilterBottomSheet(
      context: context,
      initialFilterType: DateFilterType.month,
      initialDate: _selectedDate,
      onApply: (filterType, selectedDate, startDate, endDate) {
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📅 DATE FILTER APPLIED');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('🔍 Filter Type: $filterType');
        if (startDate != null && endDate != null) {
          print('📅 Selected Range:');
          print('   - Start: ${DateFormat('yyyy-MM-dd').format(startDate)}');
          print('   - End: ${DateFormat('yyyy-MM-dd').format(endDate)}');

          setState(() {
            _selectedDate = startDate;
            _selectedMonthName = DateFormat('MMMM').format(startDate);
          });
          _applyDateFilter(startDate, endDate);
          // Optionally refetch with date range
          print('🔄 Refetching data with date range...');
          _fetchAttendanceData(startDate: startDate, endDate: endDate);
        } else if (selectedDate != null) {
          print(
            '📅 Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
          );

          setState(() {
            _selectedDate = selectedDate;
            _selectedMonthName = DateFormat('MMMM').format(selectedDate);
          });
          _applyDateFilter(selectedDate, selectedDate);
          print('🔄 Refetching data for single date...');
          _fetchAttendanceData(startDate: selectedDate, endDate: selectedDate);
        }
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      },
    );
  }

  int _getPresentCount() {
    return _filteredAttendanceList
        .where((attendance) => attendance['end_time'] != null)
        .length;
  }

  int _getAbsentCount() {
    return _filteredAttendanceList
        .where((attendance) => attendance['end_time'] == null)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = _getPresentCount();
    final absentCount = _getAbsentCount();
    final totalDays = _filteredAttendanceList.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Attendane log',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.calendar_today, color: Colors.grey.shade700),
                onPressed: _showDateFilter,
              ),
              if (_filteredAttendanceList.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF009B56),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_filteredAttendanceList.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF009B56)),
            )
          : Column(
              children: [
                // Attendance Summary Header
                Container(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attendance log ($presentCount/$totalDays)',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        _selectedMonthName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Summary Cards
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total days',
                          totalDays.toString(),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildSummaryCard(
                          'Present',
                          presentCount.toString(),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildSummaryCard(
                          'Absence',
                          absentCount.toString(),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Attendance List
                Expanded(
                  child: _filteredAttendanceList.isEmpty
                      ? Center(
                          child: Text(
                            'No attendance records found',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: _filteredAttendanceList.length,
                          itemBuilder: (context, index) {
                            return _buildAttendanceItem(
                              _filteredAttendanceList[index],
                            );
                          },
                        ),
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
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(Map<String, dynamic> attendance) {
    // Parse date
    final dateStr = attendance['date'] as String?;
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    final day = date != null ? DateFormat('d').format(date) : '?';
    final month = date != null ? DateFormat('MMM').format(date) : '?';

    // Determine status
    final endTime = attendance['end_time'];
    final isPresent = endTime != null;
    final statusText = isPresent ? 'Present' : 'Absent';
    final statusColor = isPresent ? const Color(0xFF009B56) : Colors.red;

    // Get address/village name
    final villageName = attendance['village_name'] as String? ?? 'Address';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Date Box
          Container(
            width: 50.w,
            height: 50.h,
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
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  month,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Address/Village Name
          Expanded(
            child: Text(
              villageName,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          // Status
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

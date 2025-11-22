import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../widgets/common/date_filter_bottom_sheet.dart';

class GpAttendanceScreen extends StatefulWidget {
  final int gpId;
  final String gpName;
  const GpAttendanceScreen({
    super.key,
    required this.gpId,
    required this.gpName,
  });

  @override
  State<GpAttendanceScreen> createState() => _GpAttendanceScreenState();
}

class _GpAttendanceScreenState extends State<GpAttendanceScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> _attendanceList = [];
  List<Map<String, dynamic>> _filteredAttendanceList = [];
  bool _isLoading = true;

  int? _blockId;
  int? _districtId;

  DateTime _selectedDate = DateTime.now();
  String _selectedMonthName = '';

  @override
  void initState() {
    super.initState();
    _selectedMonthName = DateFormat('MMMM').format(_selectedDate);
    _initialize();
  }

  Future<void> _initialize() async {
    final blockId = await _authService.getBlockId();
    final districtId = await _authService.getDistrictId();
    setState(() {
      _blockId = blockId;
      _districtId = districtId;
    });
    await _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    setState(() {
      _isLoading = true;
    });

    String? start;
    String? end;
    if (startDate != null && endDate != null) {
      start = DateFormat('yyyy-MM-dd').format(startDate);
      end = DateFormat('yyyy-MM-dd').format(endDate);
    }

    try {
      final response = await _apiService.getAttendanceViewForBDO(
        villageId: widget.gpId,
        blockId: _blockId,
        districtId: _districtId,
        startDate: start,
        endDate: end,
        skip: 0,
        limit: 500,
      );
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final items = List<Map<String, dynamic>>.from(
          data['attendances'] ?? [],
        );
        setState(() {
          _attendanceList = items;
          _filteredAttendanceList = List.from(items);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
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
      setState(() => _isLoading = false);
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
    setState(() {
      _selectedDate = startDate;
      _selectedMonthName = DateFormat('MMMM').format(startDate);
      _filteredAttendanceList = _attendanceList.where((attendance) {
        final d = DateTime.parse((attendance['date'] as String));
        final dOnly = DateTime(d.year, d.month, d.day);
        final sOnly = DateTime(startDate.year, startDate.month, startDate.day);
        final eOnly = DateTime(endDate.year, endDate.month, endDate.day);
        return (dOnly.isAtSameMomentAs(sOnly) || dOnly.isAfter(sOnly)) &&
            (dOnly.isAtSameMomentAs(eOnly) || dOnly.isBefore(eOnly));
      }).toList();
    });
  }

  void _showDateFilter() {
    showDateFilterBottomSheet(
      context: context,
      initialFilterType: DateFilterType.month,
      initialDate: _selectedDate,
      onApply: (type, selectedDate, startDate, endDate) {
        if (startDate != null && endDate != null) {
          _applyDateFilter(startDate, endDate);
          _fetchAttendanceData(startDate: startDate, endDate: endDate);
        } else if (selectedDate != null) {
          _applyDateFilter(selectedDate, selectedDate);
          _fetchAttendanceData(startDate: selectedDate, endDate: selectedDate);
        }
      },
    );
  }

  int _presentCount() =>
      _filteredAttendanceList.where((e) => e['end_time'] != null).length;
  int _absentCount() =>
      _filteredAttendanceList.where((e) => e['end_time'] == null).length;

  @override
  Widget build(BuildContext context) {
    final present = _presentCount();
    final absent = _absentCount();
    final total = _filteredAttendanceList.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Attendance log - ${widget.gpName}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.grey.shade700),
            onPressed: _showDateFilter,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF009B56)),
            )
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attendance log ($present/$total)',
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: _summaryCard('Total days', total.toString()),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _summaryCard('Present', present.toString()),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _summaryCard('Absent', absent.toString()),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
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
                          itemBuilder: (context, index) =>
                              _attendanceTile(_filteredAttendanceList[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _summaryCard(String title, String value) {
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

  Widget _attendanceTile(Map<String, dynamic> attendance) {
    final dateStr = attendance['date'] as String?;
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    final day = date != null ? DateFormat('d').format(date) : '?';
    final month = date != null ? DateFormat('MMM').format(date) : '?';
    final isPresent = attendance['end_time'] != null;
    final statusText = isPresent ? 'Present' : 'Absent';
    final statusColor = isPresent ? const Color(0xFF009B56) : Colors.red;
    final villageName = attendance['village_name'] as String? ?? widget.gpName;

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

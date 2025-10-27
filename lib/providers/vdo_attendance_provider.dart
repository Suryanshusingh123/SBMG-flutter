import 'package:flutter/material.dart';
import '../services/api_services.dart';

class VdoAttendanceProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State
  List<Map<String, dynamic>> _attendanceData = [];
  List<Map<String, dynamic>> _filteredAttendanceData = [];
  bool _isLoadingLogs = true;
  int _totalAttendances = 0;

  // Date filtering
  String _selectedFilter = 'Month';
  DateTime _selectedDate = DateTime.now();

  // Getters
  List<Map<String, dynamic>> get attendanceData => _attendanceData;
  List<Map<String, dynamic>> get filteredAttendanceData =>
      _filteredAttendanceData;
  bool get isLoadingLogs => _isLoadingLogs;
  int get totalAttendances => _totalAttendances;
  String get selectedFilter => _selectedFilter;
  DateTime get selectedDate => _selectedDate;

  // Calculated getters
  int get totalWorkingDays {
    final selectedDate = _selectedDate;
    final daysInMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    ).day;
    final totalWorkingDays = daysInMonth - 4; // Subtract 4 Sundays

    print('📅 Attendance Calculation:');
    print('   - Selected Month: ${selectedDate.month}/${selectedDate.year}');
    print('   - Days in Month: $daysInMonth');
    print(
      '   - Total Working Days: $totalWorkingDays ($daysInMonth - 4 Sundays)',
    );

    return totalWorkingDays;
  }

  int get presentDays {
    final presentCount = _filteredAttendanceData.length;
    print('   - Present Days: $presentCount (from filtered API records)');
    return presentCount;
  }

  int get absentDays {
    final absentCount = totalWorkingDays - presentDays;
    print('   - Absent Days: $absentCount ($totalWorkingDays - $presentDays)');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    return absentCount;
  }

  String get selectedMonthName {
    const months = [
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
    return months[_selectedDate.month - 1];
  }

  // Fetch attendance data
  Future<void> fetchAttendanceData() async {
    _isLoadingLogs = true;
    notifyListeners();

    final response = await _apiService.getAttendanceView(
      villageId: 1, // Using village_id = 1 as per API example
      skip: 0,
      limit: 500,
    );

    if (response['success']) {
      final data = response['data'];
      final attendances = data['attendances'] as List<dynamic>;

      _attendanceData = attendances.cast<Map<String, dynamic>>();
      _totalAttendances = data['total'] ?? 0;
      _isLoadingLogs = false;
      notifyListeners();

      // Apply current filter after loading data
      applyDateFilter();
    } else {
      _isLoadingLogs = false;
      notifyListeners();
    }
  }

  // Apply date filter
  void applyDateFilter() {
    print('🔍 Applying date filter...');
    print('   - Selected filter: $_selectedFilter');
    print('   - Selected date: $_selectedDate');
    print('   - Total attendance data: ${_attendanceData.length}');

    final filteredData = <Map<String, dynamic>>[];

    for (final attendance in _attendanceData) {
      final dateStr = attendance['date'] as String?;
      if (dateStr != null) {
        final attendanceDate = DateTime.tryParse(dateStr);
        if (attendanceDate != null) {
          bool shouldInclude = false;

          switch (_selectedFilter) {
            case 'Month':
              shouldInclude =
                  attendanceDate.year == _selectedDate.year &&
                  attendanceDate.month == _selectedDate.month;
              break;
            case 'Week':
              final weekStart = _selectedDate.subtract(
                Duration(days: _selectedDate.weekday - 1),
              );
              final weekEnd = weekStart.add(const Duration(days: 6));
              shouldInclude =
                  attendanceDate.isAfter(
                    weekStart.subtract(const Duration(days: 1)),
                  ) &&
                  attendanceDate.isBefore(weekEnd.add(const Duration(days: 1)));
              break;
            case 'Custom':
            case 'Day':
              shouldInclude =
                  attendanceDate.year == _selectedDate.year &&
                  attendanceDate.month == _selectedDate.month &&
                  attendanceDate.day == _selectedDate.day;
              break;
            case 'Year':
              shouldInclude = attendanceDate.year == _selectedDate.year;
              break;
          }

          if (shouldInclude) {
            filteredData.add(attendance);
          }
        }
      }
    }

    print('🔍 Filter result: ${filteredData.length} records match filter');

    _filteredAttendanceData = filteredData;
    notifyListeners();
  }

  // Update date filter
  void updateDateFilter(String filter, DateTime date) {
    _selectedFilter = filter;
    _selectedDate = date;
    applyDateFilter();
  }
}

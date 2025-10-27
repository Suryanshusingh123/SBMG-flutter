import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_services.dart';
import '../services/auth_services.dart';

class BdoAttendanceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _attendanceData = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  DateTime get selectedDate => _selectedDate;
  List<Map<String, dynamic>> get attendanceData => _attendanceData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get selectedMonth => DateFormat('MMMM').format(_selectedDate);

  // Calculate total working days (excluding Sundays)
  int get totalWorkingDays {
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDay = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    int count = 0;
    for (
      DateTime date = firstDay;
      date.isBefore(lastDay) || date.isAtSameMomentAs(lastDay);
      date = date.add(const Duration(days: 1))
    ) {
      if (date.weekday != DateTime.sunday) {
        count++;
      }
    }
    return count;
  }

  // Calculate present days
  int get presentDays {
    final uniqueDates = _attendanceData.map((a) => a['date'] as String).toSet();
    return uniqueDates.length;
  }

  // Calculate absent days
  int get absentDays => totalWorkingDays - presentDays;

  // Fetch attendance data
  Future<void> fetchAttendanceData(int gpId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final districtId = await _authService.getDistrictId();
      final blockId = await _authService.getBlockId();

      final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final lastDay = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

      final startDate = DateFormat('yyyy-MM-dd').format(firstDay);
      final endDate = DateFormat('yyyy-MM-dd').format(lastDay);

      print('📡 Fetching attendance for GP ID: $gpId');
      print('   - District ID: $districtId');
      print('   - Block ID: $blockId');
      print('   - Date Range: $startDate to $endDate');

      final response = await _apiService.getAttendanceViewForBDO(
        villageId: gpId,
        districtId: districtId,
        blockId: blockId,
        startDate: startDate,
        endDate: endDate,
        skip: 0,
        limit: 500,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final attendances = data['attendances'] as List<dynamic>;

        _attendanceData = attendances.cast<Map<String, dynamic>>();
        _isLoading = false;
        notifyListeners();

        print('✅ Loaded ${_attendanceData.length} attendance records');
      } else {
        _isLoading = false;
        _errorMessage = response['message'] ?? 'Failed to load attendance';
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error: $e';
      notifyListeners();
      print('❌ Error loading attendance: $e');
    }
  }

  // Update selected date
  void updateSelectedDate(DateTime date, int gpId) {
    _selectedDate = date;
    notifyListeners();
    fetchAttendanceData(gpId);
  }
}

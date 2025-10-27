import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/attendance_service.dart';
import '../services/storage_service.dart';
import '../services/auth_services.dart';

class SupervisorAttendanceProvider with ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();

  // Storage keys
  static const String _attendanceActiveKey = 'attendance_active';
  static const String _attendanceIdKey = 'attendance_id';
  static const String _startLatKey = 'attendance_start_lat';
  static const String _startLongKey = 'attendance_start_long';
  static const String _villageIdKey = 'attendance_village_id';

  // Attendance state
  bool _isAttendanceActive = false;
  int? _currentAttendanceId;
  String? _startLat;
  String? _startLong;
  int? _villageId;
  bool _isLoading = false;

  // Attendance logs data
  List<Map<String, dynamic>> _attendanceLog = [];
  List<Map<String, dynamic>> _filteredAttendanceLog = [];
  bool _isLoadingLogs = true;
  int _totalAttendances = 0;

  // Date filtering
  String _selectedFilter = 'Month';
  DateTime _selectedDate = DateTime.now();

  // Address cache
  final Map<String, String> _addressCache = {};

  // Getters
  bool get isAttendanceActive => _isAttendanceActive;
  int? get currentAttendanceId => _currentAttendanceId;
  String? get startLat => _startLat;
  String? get startLong => _startLong;
  int? get villageId => _villageId;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get attendanceLog => _attendanceLog;
  List<Map<String, dynamic>> get filteredAttendanceLog =>
      _filteredAttendanceLog;
  bool get isLoadingLogs => _isLoadingLogs;
  int get totalAttendances => _totalAttendances;
  String get selectedFilter => _selectedFilter;
  DateTime get selectedDate => _selectedDate;
  String get selectedMonthName => DateFormat('MMMM').format(_selectedDate);

  // Calculate attendance statistics
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
    final presentCount = _filteredAttendanceLog.length;
    print('   - Present Days: $presentCount (from filtered API records)');
    return presentCount;
  }

  int get absentDays {
    final absentCount = totalWorkingDays - presentDays;
    print('   - Absent Days: $absentCount ($totalWorkingDays - $presentDays)');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    return absentCount;
  }

  // Load attendance state from storage
  Future<void> loadAttendanceState() async {
    final isActive = await _storageService.getBool(_attendanceActiveKey);
    final attendanceId = await _storageService.getInt(_attendanceIdKey);
    final startLat = await _storageService.getString(_startLatKey);
    final startLong = await _storageService.getString(_startLongKey);
    final villageId = await _storageService.getInt(_villageIdKey);

    _isAttendanceActive = isActive ?? false;
    _currentAttendanceId = attendanceId;
    _startLat = startLat;
    _startLong = startLong;
    _villageId = villageId;
    notifyListeners();
  }

  // Save attendance state to storage
  Future<void> saveAttendanceState() async {
    await _storageService.saveBool(_attendanceActiveKey, _isAttendanceActive);
    if (_currentAttendanceId != null) {
      await _storageService.saveInt(_attendanceIdKey, _currentAttendanceId!);
    }
    if (_startLat != null) {
      await _storageService.saveString(_startLatKey, _startLat!);
    }
    if (_startLong != null) {
      await _storageService.saveString(_startLongKey, _startLong!);
    }
    if (_villageId != null) {
      await _storageService.saveInt(_villageIdKey, _villageId!);
    }
  }

  // Clear attendance state from storage
  Future<void> clearAttendanceState() async {
    await _storageService.remove(_attendanceActiveKey);
    await _storageService.remove(_attendanceIdKey);
    await _storageService.remove(_startLatKey);
    await _storageService.remove(_startLongKey);
    await _storageService.remove(_villageIdKey);
  }

  // Fetch attendance logs
  Future<void> fetchAttendanceLogs() async {
    _isLoadingLogs = true;
    notifyListeners();

    final response = await _attendanceService.getAttendanceLogs(
      page: 1,
      limit: 10,
    );

    if (response['success']) {
      final data = response['data'];
      final attendances = data['attendances'] as List<dynamic>;

      _attendanceLog = attendances.cast<Map<String, dynamic>>();
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

  // Mark attendance
  Future<Map<String, dynamic>> markAttendance(String lat, String long) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get village_id from stored user data
      final villageId = await _authService.getVillageId();

      if (villageId == null) {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message':
              'Village ID not found. Please ensure you are logged in correctly.',
        };
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 Marking Attendance:');
      print('   Lat: $lat');
      print('   Long: $long');
      print('   Village ID: $villageId (from storage)');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _attendanceService.markAttendance(
        startLat: lat,
        startLong: long,
        villageId: villageId,
      );

      _isLoading = false;

      if (response['success']) {
        final data = response['data'];
        _isAttendanceActive = true;
        _currentAttendanceId = data['id'];
        _startLat = lat;
        _startLong = long;
        _villageId = villageId;
        await saveAttendanceState();
        notifyListeners();

        // Refresh attendance logs
        await fetchAttendanceLogs();

        return {
          'success': true,
          'message':
              'Your attendance has been successfully marked for ${data['village_name'] ?? 'today'}.',
        };
      } else {
        notifyListeners();
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to mark attendance',
        };
      }
    } catch (e) {
      print('Error marking attendance: $e');
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Error marking attendance: $e'};
    }
  }

  // End attendance
  Future<Map<String, dynamic>> endAttendance(String lat, String long) async {
    if (_currentAttendanceId == null) {
      return {
        'success': false,
        'message': 'No active attendance session found',
      };
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _attendanceService.endAttendance(
        attendanceId: _currentAttendanceId!,
        endLat: lat,
        endLong: long,
      );

      _isLoading = false;

      if (response['success']) {
        _isAttendanceActive = false;
        _currentAttendanceId = null;
        _startLat = null;
        _startLong = null;
        _villageId = null;
        await clearAttendanceState();
        notifyListeners();

        // Refresh attendance logs
        await fetchAttendanceLogs();

        return {
          'success': true,
          'message': 'Your attendance has been successfully ended.',
        };
      } else {
        notifyListeners();
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to end attendance',
        };
      }
    } catch (e) {
      print('Error ending attendance: $e');
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Error ending attendance: $e'};
    }
  }

  // Update date filter
  void updateDateFilter(String filter, DateTime date) {
    _selectedFilter = filter;
    _selectedDate = date;
    notifyListeners();
    applyDateFilter();
  }

  // Apply date filter
  void applyDateFilter() {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📅 APPLYING DATE FILTER');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔍 Filter Type: $_selectedFilter');
    print('📅 Selected Date: $_selectedDate');

    DateTime startDate;
    DateTime endDate;

    switch (_selectedFilter) {
      case 'Day':
        startDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
        );
        endDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          23,
          59,
          59,
        );
        break;
      case 'Week':
        final weekStart = _selectedDate.subtract(
          Duration(days: _selectedDate.weekday - 1),
        );
        startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
        endDate = startDate.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
        break;
      case 'Month':
        startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
        endDate = DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          0,
          23,
          59,
          59,
        );
        break;
      case 'Year':
        startDate = DateTime(_selectedDate.year, 1, 1);
        endDate = DateTime(_selectedDate.year, 12, 31, 23, 59, 59);
        break;
      case 'Custom':
        startDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
        );
        endDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          23,
          59,
          59,
        );
        break;
      default:
        startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
        endDate = DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          0,
          23,
          59,
          59,
        );
    }

    print(
      '📅 Filter Range: ${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}',
    );

    // Filter attendance data
    _filteredAttendanceLog = _attendanceLog.where((attendance) {
      final attendanceDate = DateTime.parse(attendance['date']);
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

      final isInRange =
          (attendanceDateOnly.isAtSameMomentAs(startDateOnly) ||
              attendanceDateOnly.isAfter(startDateOnly)) &&
          (attendanceDateOnly.isAtSameMomentAs(endDateOnly) ||
              attendanceDateOnly.isBefore(endDateOnly));

      return isInRange;
    }).toList();

    print(
      '📊 Filtered Records: ${_filteredAttendanceLog.length} out of ${_attendanceLog.length}',
    );
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    notifyListeners();
  }

  // Cache address
  void cacheAddress(String key, String address) {
    _addressCache[key] = address;
  }

  // Get cached address
  String? getCachedAddress(String key) {
    return _addressCache[key];
  }
}

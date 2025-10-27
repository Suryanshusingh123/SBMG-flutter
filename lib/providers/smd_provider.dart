import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/scheme_model.dart';
import '../models/event_model.dart';
import '../models/geography_model.dart';
import '../services/api_services.dart';
import '../services/auth_services.dart';
import '../services/complaints_service.dart';

class SmdProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final ComplaintsService _complaintsService = ComplaintsService();

  // Schemes
  List<Scheme> _schemes = [];
  bool _isSchemesLoading = true;

  // Events
  List<Event> _events = [];
  bool _isEventsLoading = true;

  // Complaints Analytics
  Map<String, dynamic> _analytics = {
    'totalComplaints': 0,
    'openComplaints': 0,
    'resolvedComplaints': 0,
    'verifiedComplaints': 0,
    'closedComplaints': 0,
    'todaysComplaints': 0,
  };
  bool _isComplaintsLoading = true;

  // Inspection data
  int _totalInspections = 0;
  int _thisMonthInspections = 0;
  bool _isInspectionLoading = true;

  // Location info
  String _districtName = 'District';
  final String _blockName = 'Block';

  // Date range for analytics
  DateTime? _fromDate;
  DateTime? _toDate;
  String _dateRangeText = 'Select Date Range';

  // Getters
  List<Scheme> get schemes => _schemes;
  bool get isSchemesLoading => _isSchemesLoading;

  List<Event> get events => _events;
  bool get isEventsLoading => _isEventsLoading;

  Map<String, dynamic> get analytics => _analytics;
  bool get isComplaintsLoading => _isComplaintsLoading;

  int get totalInspections => _totalInspections;
  int get thisMonthInspections => _thisMonthInspections;
  bool get isInspectionLoading => _isInspectionLoading;

  String get districtName => _districtName;
  String get blockName => _blockName;

  String get dateRangeText => _dateRangeText;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  // Load all data
  Future<void> loadAllData() async {
    await Future.wait([
      loadSchemes(),
      loadEvents(),
      loadComplaintsAnalytics(),
      loadInspectionData(),
      loadLocationInfo(),
    ]);
  }

  // Load location info
  Future<void> loadLocationInfo() async {
    try {
      // For SMD, get the selected district (not from /me response)
      final districtId = await _authService.getSmdSelectedDistrictId();

      if (districtId != null) {
        final districts = await _apiService.getDistricts();
        final district = districts.firstWhere(
          (d) => d.id == districtId,
          orElse: () => District(id: districtId, name: 'District'),
        );
        _districtName = district.name;
      }

      notifyListeners();
    } catch (e) {
      print('Error loading location info: $e');
    }
  }

  // Load schemes
  Future<void> loadSchemes() async {
    try {
      _isSchemesLoading = true;
      notifyListeners();

      final schemes = await _apiService.getSchemes(limit: 100);
      _schemes = schemes;
      _isSchemesLoading = false;
      notifyListeners();
    } catch (e) {
      _isSchemesLoading = false;
      notifyListeners();
    }
  }

  // Load events
  Future<void> loadEvents() async {
    try {
      _isEventsLoading = true;
      notifyListeners();

      final events = await _apiService.getEvents(limit: 100);
      _events = events;
      _isEventsLoading = false;
      notifyListeners();
    } catch (e) {
      _isEventsLoading = false;
      notifyListeners();
    }
  }

  // Load complaints analytics
  Future<void> loadComplaintsAnalytics() async {
    try {
      _isComplaintsLoading = true;
      notifyListeners();

      print('🔄 Starting to load complaints analytics for SMD...');

      final districtId = await _authService.getSmdSelectedDistrictId();

      print('📡 SMD Complaints Parameters:');
      print('   - District ID: $districtId');

      final response = await _complaintsService.getComplaintsWithAnalytics(
        districtId: districtId,
        limit: 500,
        orderBy: 'newest',
        fromDate: _fromDate,
        toDate: _toDate,
      );

      if (response['success'] == true) {
        _analytics = response['analytics'];
        _isComplaintsLoading = false;
        notifyListeners();
        print('✅ Complaints analytics loaded successfully');
      } else {
        _isComplaintsLoading = false;
        notifyListeners();
        print('❌ Error loading complaints analytics: ${response['message']}');
      }
    } catch (e) {
      _isComplaintsLoading = false;
      notifyListeners();
      print('❌ Error loading complaints analytics: $e');
    }
  }

  // Load inspection data
  Future<void> loadInspectionData() async {
    try {
      print('🔄 Starting to load inspections for SMD...');
      _isInspectionLoading = true;
      notifyListeners();

      final districtId = await _authService.getSmdSelectedDistrictId();

      print('📡 SMD Inspection Parameters:');
      print('   - District ID: $districtId');

      final inspectionResponse = await _apiService.getInspections(
        districtId: districtId,
        page: 1,
        pageSize: 100,
      );

      print('📊 Processing inspection data...');
      print('   - Total inspections received: ${inspectionResponse.total}');
      print('   - Items in response: ${inspectionResponse.items.length}');

      final currentDate = DateTime.now();
      final currentMonth = currentDate.month;
      final currentYear = currentDate.year;

      int thisMonthCount = 0;
      for (final inspection in inspectionResponse.items) {
        final inspectionDate = DateTime.tryParse(inspection.date);
        if (inspectionDate != null) {
          if (inspectionDate.month == currentMonth &&
              inspectionDate.year == currentYear) {
            thisMonthCount++;
          }
        }
      }

      _totalInspections = inspectionResponse.total;
      _thisMonthInspections = thisMonthCount;
      _isInspectionLoading = false;
      notifyListeners();

      print('✅ Inspection data loaded successfully!');
      print('   - Total: ${inspectionResponse.total}');
      print('   - This month: $thisMonthCount');
    } catch (e) {
      print('❌ Error loading inspections: $e');
      _isInspectionLoading = false;
      notifyListeners();
    }
  }

  // Update date range
  void updateDateRange(DateTime? fromDate, DateTime? toDate) {
    _fromDate = fromDate;
    _toDate = toDate;
    _updateDateRangeText();
    notifyListeners();
  }

  // Update date range text
  void _updateDateRangeText() {
    if (_fromDate != null && _toDate != null) {
      final fromText = DateFormat('dd MMM yy').format(_fromDate!);
      final toText = DateFormat('dd MMM yy').format(_toDate!);
      _dateRangeText = '$fromText – $toText';
    } else if (_fromDate != null) {
      _dateRangeText = DateFormat('dd MMM yy').format(_fromDate!);
    } else {
      _dateRangeText = 'Select Date Range';
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await loadComplaintsAnalytics();
  }
}

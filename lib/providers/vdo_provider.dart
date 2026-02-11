import 'package:flutter/material.dart';
import '../utils/download_helper.dart';
import '../models/scheme_model.dart';
import '../models/event_model.dart';
import '../models/contractor_model.dart';
import '../services/api_services.dart';
import '../services/auth_services.dart';
import '../services/complaints_service.dart';

class VdoProvider with ChangeNotifier {
  int _selectedComplaintsTabIndex = 0;
  // Loading states
  bool _isSchemesLoading = true;
  bool _isEventsLoading = true;
  bool _isComplaintsLoading = true;
  bool _isInspectionsLoading = true;
  bool _isContractorLoading = true;

  // Data
  List<Scheme> _schemes = [];
  List<Event> _events = [];
  Map<String, dynamic> _analytics = {
    'totalComplaints': 0,
    'openComplaints': 0,
    'resolvedComplaints': 0,
    'verifiedComplaints': 0,
    'closedComplaints': 0,
    'todaysComplaints': 0,
  };
  String _villageName = 'Gram Panchayat';
  int _totalInspections = 0;
  int _thisMonthInspections = 0;
  ContractorDetails? _contractor;

  // Date range for analytics
  DateTime? _fromDate;
  DateTime? _toDate;
  String _dateRangeText = 'Select Date Range';

  // GP Master Data completion status
  bool _isVillageMasterDataCompleted = false;
  String _completionDate = '';

  // Annual survey exists for VDO's GP: null = loading, true = exists, false = none
  bool? _hasAnnualSurveyForGp;

  // Services
  final ApiService _apiService = ApiService();
  final ComplaintsService _complaintsService = ComplaintsService();

  // Getters
  bool get isSchemesLoading => _isSchemesLoading;
  bool get isEventsLoading => _isEventsLoading;
  bool get isComplaintsLoading => _isComplaintsLoading;
  bool get isInspectionsLoading => _isInspectionsLoading;
  bool get isContractorLoading => _isContractorLoading;

  List<Scheme> get schemes => _schemes;
  List<Event> get events => _events;
  Map<String, dynamic> get analytics => _analytics;
  String get villageName => _villageName;
  int get totalInspections => _totalInspections;
  int get thisMonthInspections => _thisMonthInspections;
  ContractorDetails? get contractor => _contractor;

  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  String get dateRangeText => _dateRangeText;
  int get selectedComplaintsTabIndex => _selectedComplaintsTabIndex;

  bool get isVillageMasterDataCompleted => _isVillageMasterDataCompleted;
  String get completionDate => _completionDate;
  bool? get hasAnnualSurveyForGp => _hasAnnualSurveyForGp;

  // Load all data
  Future<void> loadAllData() async {
    await Future.wait([
      loadSchemes(),
      loadEvents(),
      loadVillageName(),
      loadComplaintsAnalytics(),
      loadInspections(),
      loadContractor(),
      checkVillageMasterDataStatus(),
    ]);
  }

  // Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadComplaintsAnalytics(),
      loadInspections(),
      checkVillageMasterDataStatus(),
    ]);
  }

  /// Rechecks only whether annual survey exists for the VDO's GP. Call after user adds GP master data.
  Future<void> recheckAnnualSurveyStatus() async {
    await checkVillageMasterDataStatus();
  }

  void setComplaintsTab(int index) {
    if (index == _selectedComplaintsTabIndex) return;
    _selectedComplaintsTabIndex = index;
    notifyListeners();
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

  /// Load GP name from geography API so it displays even when there are no complaints.
  Future<void> loadVillageName() async {
    try {
      final gpId = await AuthService().getVillageId();
      if (gpId == null) return;
      final gp = await _apiService.getGramPanchayatById(gpId);
      _villageName = gp.name;
      notifyListeners();
    } catch (e) {
      print('Error loading village/GP name: $e');
    }
  }

  // Load complaints analytics
  Future<void> loadComplaintsAnalytics() async {
    try {
      _isComplaintsLoading = true;
      notifyListeners();
      final response = await _complaintsService.getComplaintsWithAnalytics(
        fromDate: _fromDate,
        toDate: _toDate,
      );

      if (response['success'] == true) {
        final complaints = response['complaints'] as List<dynamic>;

        // Extract village name from first complaint only when we have complaints;
        // otherwise keep existing _villageName (set by loadVillageName() from geography API).
        if (complaints.isNotEmpty && complaints[0]['village_name'] != null) {
          _villageName = complaints[0]['village_name'] as String;
        }

        // Extract date range from complaints (oldest and newest)
        DateTime? oldestDate;
        DateTime? newestDate;

        if (complaints.isNotEmpty) {
          for (final complaint in complaints) {
            final createdAt = complaint['created_at'] as String?;
            if (createdAt != null) {
              final date = DateTime.tryParse(createdAt);
              if (date != null) {
                if (oldestDate == null || date.isBefore(oldestDate)) {
                  oldestDate = date;
                }
                if (newestDate == null || date.isAfter(newestDate)) {
                  newestDate = date;
                }
              }
            }
          }
        }

        _analytics = response['analytics'];

        // Set default date range if not already set
        if (_fromDate == null && oldestDate != null) {
          _fromDate = oldestDate;
        }
        if (_toDate == null && newestDate != null) {
          _toDate = newestDate;
        }

        // Update date range text
        updateDateRangeText();
      }
      _isComplaintsLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading complaints analytics: $e');
      _isComplaintsLoading = false;
      notifyListeners();
    }
  }

  // Load inspections
  Future<void> loadInspections() async {
    try {
      print('🔄 Starting to load inspections...');
      _isInspectionsLoading = true;
      notifyListeners();

      print('📡 Calling API service to fetch inspections for village_id: 1');
      final inspectionResponse = await _apiService.getInspections(
        villageId: 1,
        page: 1,
        pageSize: 100,
      );

      print('📊 Processing inspection data...');
      print('   - Total inspections received: ${inspectionResponse.total}');
      print('   - Items in response: ${inspectionResponse.items.length}');

      // Calculate this month's inspections
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
      _isInspectionsLoading = false;
      notifyListeners();

      print('✅ Inspection data loaded successfully!');
    } catch (e) {
      print('❌ Error loading inspections: $e');
      _isInspectionsLoading = false;
      notifyListeners();
    }
  }

  // Load contractor
  Future<void> loadContractor() async {
    try {
      print('🔄 Starting to load contractor details...');
      _isContractorLoading = true;
      notifyListeners();

      final gpId = await AuthService().getVillageId();
      if (gpId == null) {
        print('⚠️ No village/GP ID from auth, skipping contractor load');
        _isContractorLoading = false;
        notifyListeners();
        return;
      }

      print('📡 Calling API service to fetch contractor for GP ID: $gpId');
      final contractor = await _apiService.getContractorByGpId(gpId);

      print('📊 Contractor data loaded successfully:');
      print('   - Contractor ID: ${contractor.id}');
      print('   - Person Name: ${contractor.personName}');
      print('   - Agency: ${contractor.agency.name}');

      _contractor = contractor;
      _isContractorLoading = false;
      notifyListeners();

      print('✅ Contractor data loaded successfully!');
    } catch (e) {
      print('❌ Error loading contractor: $e');
      _isContractorLoading = false;
      notifyListeners();
    }
  }

  // Check GP Master Data status: does an annual survey exist for the VDO's GP?
  Future<void> checkVillageMasterDataStatus() async {
    _hasAnnualSurveyForGp = null;
    notifyListeners();

    final villageId = await AuthService().getVillageId();
    if (villageId == null) {
      _hasAnnualSurveyForGp = false;
      _isVillageMasterDataCompleted = false;
      _completionDate = '';
      notifyListeners();
      return;
    }

    try {
      final latest = await _apiService.getLatestAnnualSurveyForGp(villageId);
      final rawId = latest['id'];
      final surveyId = rawId is int
          ? rawId
          : int.tryParse(rawId?.toString() ?? '');
      _hasAnnualSurveyForGp = surveyId != null;
    } catch (e) {
      print('Error checking annual survey for GP: $e');
      _hasAnnualSurveyForGp = false;
    }
    _isVillageMasterDataCompleted = _hasAnnualSurveyForGp ?? false;
    if (!_isVillageMasterDataCompleted) _completionDate = '';
    notifyListeners();
  }

  // Update GP Master Data completion
  void updateVillageMasterDataCompletion(String completionDate) {
    _isVillageMasterDataCompleted = true;
    _completionDate = completionDate;
    notifyListeners();
  }

  // Update date range
  void updateDateRange(DateTime? fromDate, DateTime? toDate) {
    _fromDate = fromDate;
    _toDate = toDate;
    updateDateRangeText();
    notifyListeners();
    // Reload analytics with new date range
    loadComplaintsAnalytics();
  }

  // Update date range text
  void updateDateRangeText() {
    if (_fromDate != null && _toDate != null) {
      _dateRangeText = '${_formatDate(_fromDate!)} – ${_formatDate(_toDate!)}';
    } else if (_fromDate != null) {
      _dateRangeText = _formatDate(_fromDate!);
    } else {
      _dateRangeText = 'Select Date Range';
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _getMonthAbbreviation(date.month);
    final year = date.year.toString().substring(2);
    return '$day $month $year';
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  // Export analytics to CSV
  Future<String?> exportAnalyticsToCsv() async {
    try {
      print('📊 Starting CSV export...');

      // Request storage permission for Android
      await DownloadHelper.requestStoragePermission();

      // Create filename with timestamp
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')[0];
      final fileName = 'vdo_complaints_export_$timestamp.csv';

      // Create CSV content
      final csvContent = _generateCsvContent();

      // Download to Downloads folder
      final filePath = await DownloadHelper.downloadToDownloadsFolder(
        fileName: fileName,
        content: csvContent,
      );

      if (filePath != null) {
        print('✅ CSV file created at: $filePath');
        return filePath;
      } else {
        print('❌ Failed to save file to Downloads folder');
        return null;
      }
    } catch (e) {
      print('❌ Error exporting CSV: $e');
      return null;
    }
  }

  String _generateCsvContent() {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln('Metric,Count');

    // CSV Data
    buffer.writeln('Total Complaints,${_analytics['totalComplaints']}');
    buffer.writeln('Open Complaints,${_analytics['openComplaints']}');
    buffer.writeln('Resolved Complaints,${_analytics['resolvedComplaints']}');
    buffer.writeln('Verified Complaints,${_analytics['verifiedComplaints']}');
    buffer.writeln('Closed Complaints,${_analytics['closedComplaints']}');
    buffer.writeln('Total Inspections,$_totalInspections');
    buffer.writeln('This Month Inspections,$_thisMonthInspections');

    // Add date range info if available
    if (_fromDate != null && _toDate != null) {
      buffer.writeln('');
      buffer.writeln('Date Range from,${_formatDateForCsv(_fromDate!)}');
      buffer.writeln('Date Range to,${_formatDateForCsv(_toDate!)}');
    }

    return buffer.toString();
  }

  String _formatDateForCsv(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

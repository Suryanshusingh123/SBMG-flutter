import 'package:flutter/material.dart';
import '../models/scheme_model.dart';
import '../models/event_model.dart';
import '../services/api_services.dart';
import '../services/complaints_service.dart';

class SupervisorProvider with ChangeNotifier {
  // Services
  final ApiService _apiService = ApiService();
  final ComplaintsService _complaintsService = ComplaintsService();

  // Loading states
  bool _isSchemesLoading = true;
  bool _isEventsLoading = true;
  bool _isComplaintsLoading = true;

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
  List<dynamic> _todaysComplaints = [];
  String _villageName = 'Gram Panchayat';

  // Getters
  bool get isSchemesLoading => _isSchemesLoading;
  bool get isEventsLoading => _isEventsLoading;
  bool get isComplaintsLoading => _isComplaintsLoading;
  List<Scheme> get schemes => _schemes;
  List<Event> get events => _events;
  Map<String, dynamic> get analytics => _analytics;
  List<dynamic> get todaysComplaints => _todaysComplaints;
  String get villageName => _villageName;

  // Load all data
  Future<void> loadAllData() async {
    await Future.wait([loadSchemes(), loadEvents(), loadComplaintsAnalytics()]);
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
      print('Error loading schemes: $e');
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
      print('Error loading events: $e');
      _isEventsLoading = false;
      notifyListeners();
    }
  }

  // Load complaints analytics
  Future<void> loadComplaintsAnalytics() async {
    try {
      _isComplaintsLoading = true;
      notifyListeners();

      final response = await _complaintsService.getComplaintsWithAnalytics();

      if (response['success'] == true) {
        final complaints = response['complaints'] as List<dynamic>;
        final todaysComplaints = _filterTodaysComplaints(complaints);

        // Extract village name from first complaint if available
        String villageName = 'Gram Panchayat';
        if (complaints.isNotEmpty && complaints[0]['village_name'] != null) {
          villageName = complaints[0]['village_name'];
        }

        _analytics = response['analytics'];
        _todaysComplaints = todaysComplaints;
        _villageName = villageName;
        _isComplaintsLoading = false;
        notifyListeners();
      } else {
        print('Error loading complaints analytics: ${response['message']}');
        _isComplaintsLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading complaints analytics: $e');
      _isComplaintsLoading = false;
      notifyListeners();
    }
  }

  // Filter today's complaints
  List<dynamic> _filterTodaysComplaints(List<dynamic> complaints) {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);

    print('🔍 Filtering today\'s complaints:');
    print('📅 Today (UTC): $today');
    print('📊 Total complaints to filter: ${complaints.length}');

    final todaysComplaints = complaints.where((complaint) {
      if (complaint['created_at'] != null) {
        try {
          final createdAt = DateTime.parse(complaint['created_at']).toUtc();
          final complaintDate = DateTime.utc(
            createdAt.year,
            createdAt.month,
            createdAt.day,
          );

          final isToday = complaintDate.isAtSameMomentAs(today);
          print(
            '📝 Complaint ${complaint['id']}: ${complaint['created_at']} -> $complaintDate (isToday: $isToday)',
          );

          return isToday;
        } catch (e) {
          print('❌ Error parsing date: ${complaint['created_at']} - $e');
          return false;
        }
      }
      return false;
    }).toList();

    print('✅ Today\'s complaints found: ${todaysComplaints.length}');
    return todaysComplaints;
  }

  // Refresh all data
  Future<void> refresh() async {
    await loadAllData();
  }
}

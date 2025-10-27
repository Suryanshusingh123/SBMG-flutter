import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_services.dart';

class EventsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Event> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasEvents => _events.isNotEmpty;
  int get eventsCount => _events.length;

  Future<void> loadEvents({int limit = 15}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final events = await _apiService.getEvents(limit: limit);
      _events = events;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load events: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Event? getEventById(int id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }
}

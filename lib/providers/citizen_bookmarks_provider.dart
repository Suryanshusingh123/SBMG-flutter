import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class BookmarksProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  // Track bookmarked schemes and events by ID
  final Map<int, bool> _bookmarkedSchemes = {};
  final Map<int, bool> _bookmarkedEvents = {};
  
  bool _isInitialized = false;

  Map<int, bool> get bookmarkedSchemes => _bookmarkedSchemes;
  Map<int, bool> get bookmarkedEvents => _bookmarkedEvents;

  // Get count of bookmarked schemes
  int get bookmarkedSchemesCount {
    return _bookmarkedSchemes.values.where((v) => v).length;
  }

  // Get count of bookmarked events
  int get bookmarkedEventsCount {
    return _bookmarkedEvents.values.where((v) => v).length;
  }

  // Initialize and load bookmarks from storage
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Load bookmarked scheme IDs
      final schemesJson = await _storageService.getString('bookmarked_schemes');
      if (schemesJson != null) {
        final List<dynamic> schemeIds = jsonDecode(schemesJson);
        for (final id in schemeIds) {
          _bookmarkedSchemes[int.parse(id.toString())] = true;
        }
        print('✅ Loaded ${schemeIds.length} bookmarked schemes from storage');
      }

      // Load bookmarked event IDs
      final eventsJson = await _storageService.getString('bookmarked_events');
      if (eventsJson != null) {
        final List<dynamic> eventIds = jsonDecode(eventsJson);
        for (final id in eventIds) {
          _bookmarkedEvents[int.parse(id.toString())] = true;
        }
        print('✅ Loaded ${eventIds.length} bookmarked events from storage');
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading bookmarks: $e');
      _isInitialized = true;
    }
  }

  // Save bookmarked scheme IDs to storage
  Future<void> _saveBookmarkedSchemes() async {
    try {
      final schemeIds = _bookmarkedSchemes.entries
          .where((e) => e.value)
          .map((e) => e.key.toString())
          .toList();
      final json = jsonEncode(schemeIds);
      final saved = await _storageService.saveString('bookmarked_schemes', json);
      if (saved) {
        print('💾 Saved ${schemeIds.length} bookmarked schemes to storage');
      } else {
        print('⚠️ Failed to save bookmarked schemes to storage');
      }
    } catch (e) {
      print('❌ Error saving bookmarked schemes: $e');
    }
  }

  // Save bookmarked event IDs to storage
  Future<void> _saveBookmarkedEvents() async {
    try {
      final eventIds = _bookmarkedEvents.entries
          .where((e) => e.value)
          .map((e) => e.key.toString())
          .toList();
      final json = jsonEncode(eventIds);
      final saved = await _storageService.saveString('bookmarked_events', json);
      if (saved) {
        print('💾 Saved ${eventIds.length} bookmarked events to storage');
      } else {
        print('⚠️ Failed to save bookmarked events to storage');
      }
    } catch (e) {
      print('❌ Error saving bookmarked events: $e');
    }
  }

  // Check if a scheme is bookmarked
  bool isSchemeBookmarked(int schemeId) {
    return _bookmarkedSchemes[schemeId] ?? false;
  }

  // Check if an event is bookmarked
  bool isEventBookmarked(int eventId) {
    return _bookmarkedEvents[eventId] ?? false;
  }

  // Toggle scheme bookmark
  void toggleSchemeBookmark(int schemeId, bool isBookmarked) {
    _bookmarkedSchemes[schemeId] = isBookmarked;
    _saveBookmarkedSchemes();
    notifyListeners();
  }

  // Toggle event bookmark
  void toggleEventBookmark(int eventId, bool isBookmarked) {
    _bookmarkedEvents[eventId] = isBookmarked;
    _saveBookmarkedEvents();
    notifyListeners();
  }

  // Get bookmarked scheme IDs
  List<int> get bookmarkedSchemeIds {
    return _bookmarkedSchemes.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
  }

  // Get bookmarked event IDs
  List<int> get bookmarkedEventIds {
    return _bookmarkedEvents.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
  }
}

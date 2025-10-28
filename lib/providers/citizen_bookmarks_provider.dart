import 'package:flutter/material.dart';

class BookmarksProvider with ChangeNotifier {
  // Track bookmarked schemes and events by ID
  final Map<int, bool> _bookmarkedSchemes = {};
  final Map<int, bool> _bookmarkedEvents = {};

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
    notifyListeners();
  }

  // Toggle event bookmark
  void toggleEventBookmark(int eventId, bool isBookmarked) {
    _bookmarkedEvents[eventId] = isBookmarked;
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

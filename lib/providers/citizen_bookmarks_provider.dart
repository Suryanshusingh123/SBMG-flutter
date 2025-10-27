import 'package:flutter/material.dart';
import '../models/scheme_model.dart';
import '../models/event_model.dart';
import '../services/bookmark_service.dart';

class BookmarksProvider with ChangeNotifier {
  final BookmarkService _bookmarkService = BookmarkService();

  List<Scheme> get bookmarkedSchemes => _bookmarkService.bookmarkedSchemes;
  List<Event> get bookmarkedEvents => _bookmarkService.bookmarkedEvents;

  int get bookmarkedSchemesCount => _bookmarkService.bookmarkedSchemes.length;
  int get bookmarkedEventsCount => _bookmarkService.bookmarkedEvents.length;

  bool isSchemeBookmarked(int schemeId) {
    return _bookmarkService.isSchemeBookmarked(schemeId);
  }

  bool isEventBookmarked(int eventId) {
    return _bookmarkService.isEventBookmarked(eventId);
  }

  void toggleSchemeBookmark(Scheme scheme) {
    _bookmarkService.toggleSchemeBookmark(scheme);
    notifyListeners();
  }

  void toggleEventBookmark(Event event) {
    _bookmarkService.toggleEventBookmark(event);
    notifyListeners();
  }

  void clearAllBookmarks() {
    // Implement if needed
    notifyListeners();
  }
}

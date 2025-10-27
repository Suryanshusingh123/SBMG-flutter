import '../models/scheme_model.dart';
import '../models/event_model.dart';

class BookmarkService {
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService() => _instance;
  BookmarkService._internal();

  // Store bookmarked items
  final List<Scheme> _bookmarkedSchemes = [];
  final List<Event> _bookmarkedEvents = [];

  // Getters
  List<Scheme> get bookmarkedSchemes => List.unmodifiable(_bookmarkedSchemes);
  List<Event> get bookmarkedEvents => List.unmodifiable(_bookmarkedEvents);

  // Check if item is bookmarked
  bool isSchemeBookmarked(int schemeId) {
    return _bookmarkedSchemes.any((scheme) => scheme.id == schemeId);
  }

  bool isEventBookmarked(int eventId) {
    return _bookmarkedEvents.any((event) => event.id == eventId);
  }

  // Toggle bookmark for scheme
  void toggleSchemeBookmark(Scheme scheme) {
    final index = _bookmarkedSchemes.indexWhere((s) => s.id == scheme.id);
    if (index != -1) {
      _bookmarkedSchemes.removeAt(index);
      print('🔖 Scheme removed from bookmarks: ${scheme.name}');
    } else {
      _bookmarkedSchemes.add(scheme.copyWith(isBookmarked: true));
      print('🔖 Scheme added to bookmarks: ${scheme.name}');
    }
  }

  // Toggle bookmark for event
  void toggleEventBookmark(Event event) {
    final index = _bookmarkedEvents.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _bookmarkedEvents.removeAt(index);
      print('🔖 Event removed from bookmarks: ${event.title}');
    } else {
      _bookmarkedEvents.add(event.copyWith(isBookmarked: true));
      print('🔖 Event added to bookmarks: ${event.title}');
    }
  }

  // Remove all bookmarks
  void clearAllBookmarks() {
    _bookmarkedSchemes.clear();
    _bookmarkedEvents.clear();
    print('🔖 All bookmarks cleared');
  }
}

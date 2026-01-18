import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/auth_services.dart';

class BookmarksProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  
  // Track bookmarked schemes and events by ID
  final Map<int, bool> _bookmarkedSchemes = {};
  final Map<int, bool> _bookmarkedEvents = {};
  
  bool _isInitialized = false;
  String? _currentUserKey;

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

  // Get user-specific storage key
  Future<String> _getUserStorageKey() async {
    // Try to get username first (most unique identifier)
    final username = await _authService.getUsername();
    if (username != null && username.isNotEmpty) {
      return username;
    }
    
    // Fallback to role if username not available
    final role = await _authService.getRole();
    if (role != null && role.isNotEmpty) {
      return role;
    }
    
    // Last resort: use token hash or default
    final token = await _authService.getToken();
    if (token != null && token.length >= 16) {
      // Use a portion of the token as identifier
      return token.substring(0, 16);
    }
    
    // Default fallback (should not happen when logged in)
    return 'default_user';
  }

  // Initialize and load bookmarks from storage for current user
  Future<void> initialize() async {
    // Skip if already initialized for the same user
    if (_isInitialized) {
      final userKey = await _getUserStorageKey();
      // If user hasn't changed, no need to reload
      if (_currentUserKey == userKey) {
        return;
      }
      // User changed, need to reload
      print('🔄 User changed from $_currentUserKey to $userKey, reloading bookmarks');
    }
    
    try {
      // Get current user identifier
      final userKey = await _getUserStorageKey();
      
      // If user changed, clear previous bookmarks
      if (_currentUserKey != null && _currentUserKey != userKey) {
        _bookmarkedSchemes.clear();
        _bookmarkedEvents.clear();
        print('🔄 User changed from $_currentUserKey to $userKey, cleared bookmarks');
      }
      
      _currentUserKey = userKey;
      
      // Load bookmarked scheme IDs for current user
      final schemesKey = 'bookmarked_schemes_$userKey';
      var schemesJson = await _storageService.getString(schemesKey);
      
      // Migration: If no user-specific bookmarks found, check for old global bookmarks
      // and migrate them to the current user (one-time migration)
      if (schemesJson == null) {
        final oldSchemesJson = await _storageService.getString('bookmarked_schemes');
        if (oldSchemesJson != null) {
          // Migrate old bookmarks to user-specific key
          await _storageService.saveString(schemesKey, oldSchemesJson);
          schemesJson = oldSchemesJson;
          // Optionally remove old global key after migration
          // await _storageService.remove('bookmarked_schemes');
          print('🔄 Migrated old bookmarked schemes to user: $userKey');
        }
      }
      
      if (schemesJson != null) {
        final List<dynamic> schemeIds = jsonDecode(schemesJson);
        for (final id in schemeIds) {
          _bookmarkedSchemes[int.parse(id.toString())] = true;
        }
        print('✅ Loaded ${schemeIds.length} bookmarked schemes for user: $userKey');
      }

      // Load bookmarked event IDs for current user
      final eventsKey = 'bookmarked_events_$userKey';
      var eventsJson = await _storageService.getString(eventsKey);
      
      // Migration: If no user-specific bookmarks found, check for old global bookmarks
      if (eventsJson == null) {
        final oldEventsJson = await _storageService.getString('bookmarked_events');
        if (oldEventsJson != null) {
          // Migrate old bookmarks to user-specific key
          await _storageService.saveString(eventsKey, oldEventsJson);
          eventsJson = oldEventsJson;
          // Optionally remove old global key after migration
          // await _storageService.remove('bookmarked_events');
          print('🔄 Migrated old bookmarked events to user: $userKey');
        }
      }
      
      if (eventsJson != null) {
        final List<dynamic> eventIds = jsonDecode(eventsJson);
        for (final id in eventIds) {
          _bookmarkedEvents[int.parse(id.toString())] = true;
        }
        print('✅ Loaded ${eventIds.length} bookmarked events for user: $userKey');
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading bookmarks: $e');
      _isInitialized = true;
    }
  }

  // Save bookmarked scheme IDs to storage for current user
  Future<void> _saveBookmarkedSchemes() async {
    try {
      final userKey = _currentUserKey ?? await _getUserStorageKey();
      final schemeIds = _bookmarkedSchemes.entries
          .where((e) => e.value)
          .map((e) => e.key.toString())
          .toList();
      final json = jsonEncode(schemeIds);
      final schemesKey = 'bookmarked_schemes_$userKey';
      final saved = await _storageService.saveString(schemesKey, json);
      if (saved) {
        print('💾 Saved ${schemeIds.length} bookmarked schemes for user: $userKey');
      } else {
        print('⚠️ Failed to save bookmarked schemes for user: $userKey');
      }
    } catch (e) {
      print('❌ Error saving bookmarked schemes: $e');
    }
  }

  // Save bookmarked event IDs to storage for current user
  Future<void> _saveBookmarkedEvents() async {
    try {
      final userKey = _currentUserKey ?? await _getUserStorageKey();
      final eventIds = _bookmarkedEvents.entries
          .where((e) => e.value)
          .map((e) => e.key.toString())
          .toList();
      final json = jsonEncode(eventIds);
      final eventsKey = 'bookmarked_events_$userKey';
      final saved = await _storageService.saveString(eventsKey, json);
      if (saved) {
        print('💾 Saved ${eventIds.length} bookmarked events for user: $userKey');
      } else {
        print('⚠️ Failed to save bookmarked events for user: $userKey');
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
  Future<void> toggleSchemeBookmark(int schemeId, bool isBookmarked) async {
    // Check if user changed and reload if needed
    final userKey = await _getUserStorageKey();
    if (_currentUserKey != userKey || !_isInitialized) {
      await reloadForCurrentUser();
    }
    
    _bookmarkedSchemes[schemeId] = isBookmarked;
    await _saveBookmarkedSchemes();
    notifyListeners();
  }

  // Toggle event bookmark
  Future<void> toggleEventBookmark(int eventId, bool isBookmarked) async {
    // Check if user changed and reload if needed
    final userKey = await _getUserStorageKey();
    if (_currentUserKey != userKey || !_isInitialized) {
      await reloadForCurrentUser();
    }
    
    _bookmarkedEvents[eventId] = isBookmarked;
    await _saveBookmarkedEvents();
    notifyListeners();
  }

  // Clear bookmarks (useful when user logs out or switches)
  void clearBookmarks() {
    _bookmarkedSchemes.clear();
    _bookmarkedEvents.clear();
    _currentUserKey = null;
    _isInitialized = false;
    notifyListeners();
  }

  // Reload bookmarks for current user (useful when user switches)
  Future<void> reloadForCurrentUser() async {
    _currentUserKey = null;
    _isInitialized = false;
    _bookmarkedSchemes.clear();
    _bookmarkedEvents.clear();
    await initialize();
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

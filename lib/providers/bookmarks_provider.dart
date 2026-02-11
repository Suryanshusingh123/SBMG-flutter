// Backend-only bookmark service for all roles (citizen, SMD, CEO, BDO, VDO, supervisor).
// All bookmark state is fetched from and written to the API; no local storage.

import 'package:flutter/material.dart';
import '../models/scheme_model.dart';
import '../services/auth_services.dart';
import '../services/api_services.dart';

class BookmarksProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  // Cache of bookmarked IDs and list (from API only)
  final Map<int, bool> _bookmarkedSchemes = {};
  final Map<int, bool> _bookmarkedEvents = {};
  List<Scheme> _bookmarkedSchemeList = [];
  bool _isLoadingBookmarkedList = false;

  bool _isInitialized = false;
  bool _isLoading = false;

  Map<int, bool> get bookmarkedSchemes => _bookmarkedSchemes;
  List<Scheme> get bookmarkedSchemeList => List.unmodifiable(_bookmarkedSchemeList);
  bool get isLoadingBookmarkedList => _isLoadingBookmarkedList;

  int get bookmarkedSchemesCount =>
      _bookmarkedSchemes.values.where((v) => v).length;

  int get bookmarkedEventsCount =>
      _bookmarkedEvents.values.where((v) => v).length;

  bool get isLoading => _isLoading;

  Future<void> initialize({bool forceReload = false}) async {
    if (_isInitialized && !_isLoading && !forceReload) return;

    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        _bookmarkedSchemes.clear();
        _bookmarkedEvents.clear();
        _bookmarkedSchemeList = [];
        _isInitialized = true;
        _isLoading = false;
        notifyListeners();
        return;
      }

      try {
        final bookmarkedSchemes = await _apiService.getBookmarkedSchemes();
        _bookmarkedSchemes.clear();
        for (final scheme in bookmarkedSchemes) {
          _bookmarkedSchemes[scheme.id] = true;
        }
      } catch (e) {
        _bookmarkedSchemes.clear();
      }

      try {
        final bookmarkedEvents = await _apiService.getBookmarkedEvents();
        _bookmarkedEvents.clear();
        for (final event in bookmarkedEvents) {
          _bookmarkedEvents[event.id] = true;
        }
      } catch (e) {
        _bookmarkedEvents.clear();
      }

      _isInitialized = true;
    } catch (e) {
      _bookmarkedSchemes.clear();
      _bookmarkedEvents.clear();
      _bookmarkedSchemeList = [];
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isSchemeBookmarked(int schemeId) =>
      _bookmarkedSchemes[schemeId] ?? false;

  bool isEventBookmarked(int eventId) =>
      _bookmarkedEvents[eventId] ?? false;

  Future<void> toggleSchemeBookmark(int schemeId, bool isBookmarked) async {
    if (!await _authService.isLoggedIn()) {
      throw Exception('Please login to bookmark schemes');
    }
    if (isBookmarked) {
      await _apiService.addSchemeBookmark(schemeId);
    } else {
      await _apiService.removeSchemeBookmark(schemeId);
    }
    await loadBookmarkedSchemesList();
  }

  Future<void> toggleEventBookmark(int eventId, bool isBookmarked) async {
    if (!await _authService.isLoggedIn()) {
      throw Exception('Please login to bookmark events');
    }
    if (isBookmarked) {
      await _apiService.addEventBookmark(eventId);
    } else {
      await _apiService.removeEventBookmark(eventId);
    }
    await _refreshBookmarkedEventsFromBackend();
  }

  void clearBookmarks() {
    _bookmarkedSchemes.clear();
    _bookmarkedEvents.clear();
    _bookmarkedSchemeList = [];
    _isInitialized = false;
    notifyListeners();
  }

  Future<void> reloadForCurrentUser() async {
    _isInitialized = false;
    _bookmarkedSchemes.clear();
    _bookmarkedEvents.clear();
    _bookmarkedSchemeList = [];
    await initialize(forceReload: true);
  }

  Future<void> loadBookmarkedSchemesList() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      _bookmarkedSchemeList = [];
      _bookmarkedSchemes.clear();
      notifyListeners();
      return;
    }

    _isLoadingBookmarkedList = true;
    notifyListeners();

    try {
      final list = await _apiService.getBookmarkedSchemes(skip: 0, limit: 100);
      _bookmarkedSchemeList = list;
      _bookmarkedSchemes.clear();
      for (final scheme in list) {
        _bookmarkedSchemes[scheme.id] = true;
      }
    } catch (e) {
      _bookmarkedSchemeList = [];
      _bookmarkedSchemes.clear();
    } finally {
      _isLoadingBookmarkedList = false;
      notifyListeners();
    }
  }

  Future<void> _refreshBookmarkedEventsFromBackend() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      _bookmarkedEvents.clear();
      notifyListeners();
      return;
    }
    try {
      final list = await _apiService.getBookmarkedEvents(skip: 0, limit: 100);
      _bookmarkedEvents.clear();
      for (final event in list) {
        _bookmarkedEvents[event.id] = true;
      }
    } catch (e) {
      _bookmarkedEvents.clear();
    }
    notifyListeners();
  }

  List<int> get bookmarkedSchemeIds =>
      _bookmarkedSchemes.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

  List<int> get bookmarkedEventIds =>
      _bookmarkedEvents.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
}

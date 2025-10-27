import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  /// Save a string value to local storage
  Future<bool> saveString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(key, value);
    } catch (e) {
      print('❌ Error saving to storage: $e');
      return false;
    }
  }

  /// Get a string value from local storage
  Future<String?> getString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      print('❌ Error reading from storage: $e');
      return null;
    }
  }

  /// Save a boolean value to local storage
  Future<bool> saveBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(key, value);
    } catch (e) {
      print('❌ Error saving to storage: $e');
      return false;
    }
  }

  /// Get a boolean value from local storage
  Future<bool?> getBool(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    } catch (e) {
      print('❌ Error reading from storage: $e');
      return null;
    }
  }

  /// Save an integer value to local storage
  Future<bool> saveInt(String key, int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setInt(key, value);
    } catch (e) {
      print('❌ Error saving to storage: $e');
      return false;
    }
  }

  /// Get an integer value from local storage
  Future<int?> getInt(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(key);
    } catch (e) {
      print('❌ Error reading from storage: $e');
      return null;
    }
  }

  /// Remove a value from local storage
  Future<bool> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(key);
    } catch (e) {
      print('❌ Error removing from storage: $e');
      return false;
    }
  }

  /// Clear all values from local storage
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e) {
      print('❌ Error clearing storage: $e');
      return false;
    }
  }

  /// Check if a key exists in local storage
  Future<bool> containsKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(key);
    } catch (e) {
      print('❌ Error checking storage: $e');
      return false;
    }
  }
}

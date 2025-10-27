import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = '';
  String _phone = '';
  String _gender = '';
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = false;

  String get name => _name;
  String get phone => _phone;
  String get gender => _gender;
  String get selectedLanguage => _selectedLanguage;
  bool get notificationsEnabled => _notificationsEnabled;

  void updateName(String name) {
    _name = name;
    notifyListeners();
  }

  void updatePhone(String phone) {
    _phone = phone;
    notifyListeners();
  }

  void updateGender(String gender) {
    _gender = gender;
    notifyListeners();
  }

  void updateLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  void toggleNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  Future<void> saveProfile() async {
    // TODO: Implement actual save to backend/storage
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }

  void loadProfile() {
    // TODO: Load from storage/backend
    notifyListeners();
  }
}

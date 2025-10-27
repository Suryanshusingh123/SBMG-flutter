import 'package:flutter/material.dart';
import '../services/auth_services.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  bool _isCheckingAuth = true;
  String? _token;
  String? _errorMessage;
  bool _isLoading = false;
  bool _otpSent = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isCheckingAuth => _isCheckingAuth;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get otpSent => _otpSent;

  AuthProvider() {
    checkAuthentication();
  }

  Future<void> checkAuthentication() async {
    _isCheckingAuth = true;
    notifyListeners();

    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        _token = await _authService.getToken();
      }
    } catch (e) {
      _isLoggedIn = false;
      _token = null;
    } finally {
      _isCheckingAuth = false;
      notifyListeners();
    }
  }

  Future<bool> sendOtp(String mobileNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendOtp(mobileNumber);
      _otpSent = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _otpSent = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String mobileNumber, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.verifyOtp(mobileNumber, otp);
      _isLoggedIn = true;
      _token = await _authService.getToken();
      _isLoading = false;
      _otpSent = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      _isLoggedIn = false;
      _token = null;
      _otpSent = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetOtpState() {
    _otpSent = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Reset password methods
  Future<bool> requestPasswordReset(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.requestPasswordReset(
        phoneNumber: phoneNumber,
      );
      _isLoading = false;
      if (result['success']) {
        _otpSent = true;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyPasswordResetOtp(String phoneNumber, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.verifyPasswordResetOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );
      _isLoading = false;
      if (result['success']) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> setNewPassword(
    String phoneNumber,
    String otp,
    String newPassword,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.setNewPassword(
        phoneNumber: phoneNumber,
        otp: otp,
        newPassword: newPassword,
      );
      _isLoading = false;
      if (result['success']) {
        _otpSent = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

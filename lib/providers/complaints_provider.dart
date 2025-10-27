import 'dart:io';
import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../models/complaint_type_model.dart';
import '../services/api_services.dart';

class ComplaintsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ComplaintType> _complaintTypes = [];
  final List<ComplaintModel> _complaints = [];
  bool _isLoadingTypes = false;
  final bool _isLoadingComplaints = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<ComplaintType> get complaintTypes => _complaintTypes;
  List<ComplaintModel> get complaints => _complaints;
  bool get isLoadingTypes => _isLoadingTypes;
  bool get isLoadingComplaints => _isLoadingComplaints;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  List<ComplaintModel> get openComplaints =>
      _complaints.where((c) => c.status == 'open').toList();

  List<ComplaintModel> get closedComplaints =>
      _complaints.where((c) => c.status == 'closed').toList();

  Future<void> loadComplaintTypes() async {
    _isLoadingTypes = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final types = await _apiService.getComplaintTypes();
      _complaintTypes = types;
      _isLoadingTypes = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load complaint types';
      _isLoadingTypes = false;
      notifyListeners();
    }
  }

  Future<bool> submitComplaint({
    required String token,
    required int complaintTypeId,
    required int gpId,
    required String description,
    required List<File> files,
    required double lat,
    required double long,
    required String location,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.submitComplaint(
        token: token,
        complaintTypeId: complaintTypeId,
        gpId: gpId,
        description: description,
        files: files,
        lat: lat,
        long: long,
        location: location,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit complaint: ${e.toString()}';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  ComplaintType? getComplaintTypeById(int id) {
    try {
      return _complaintTypes.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }
}

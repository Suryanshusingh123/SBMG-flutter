import 'package:flutter/material.dart';

class ApiConstants {
  // Base API URL
  static const String baseUrl = 'http://139.59.34.99:8000';

  // API Endpoints
  static const String schemesEndpoint = '/api/v1/schemes/';
  static const String eventsEndpoint = '/api/v1/events/';

  // Authentication Endpoints
  static const String loginEndpoint = '/api/v1/auth/login';
  static const String publicLoginEndpoint = '/api/v1/public/login';
  static const String adminLoginEndpoint = '/api/v1/admin/login';
  static const String meEndpoint = '/api/v1/auth/me';
  static const String sendOtpEndpoint = '/api/v1/authsend-otp';
  static const String verifyOtpEndpoint = '/api/v1/authverify-otp';
  static const String resetPasswordRequestEndpoint =
      '/api/v1/admin/reset-password-request';
  static const String resetPasswordVerifyEndpoint =
      '/api/v1/admin/reset-password-verify';
  static const String resetPasswordSetEndpoint =
      '/api/v1/admin/reset-password-set';

  // Complaint Endpoints
  static const String complaintTypesEndpoint = '/api/v1/public/complaint-types';
  static const String submitComplaintEndpoint = '/api/v1/citizen/with-media';
  static const String myComplaintsEndpoint = '/api/v1/complaints/my';
  static const String adminComplaintsEndpoint = '/api/v1/admin/complaints';
  static const String updateComplaintStatusEndpoint =
      '/api/v1/admin/complaints';
  static const String complaintsEndpoint = '/api/v1/complaints';

  // Geography Endpoints
  static const String districtsEndpoint = '/api/v1/geography/districts';
  static const String blocksEndpoint = '/api/v1/geography/blocks';
  static const String villagesEndpoint = '/api/v1/geography/grampanchayats';
  static const String contractorEndpoint = '/api/v1/geography/grampanchayats';

  // Annual Surveys Endpoints
  static const String annualSurveyEndpoint =
      '/api/v1/annual-surveys/latest-for-gp';
  static const String annualSurveyFillEndpoint = '/api/v1/annual-surveys/fill';
  static const String annualSurveyActiveFyEndpoint =
      '/api/v1/annual-surveys/fy/active';

  // Inspection Endpoints
  static const String inspectionsEndpoint = '/api/v1/inspections/';

  // Attendance Endpoints
  static const String attendanceLogEndpoint = '/api/v1/attendance/log';
  static const String attendanceEndEndpoint = '/api/v1/attendance/end';
  static const String attendanceMyEndpoint = '/api/v1/attendance/my';
  static const String attendanceViewEndpoint = '/api/v1/attendance/view';

  // Media URL helper
  static String getMediaUrl(String mediaPath) {
    // Use the public media endpoint: /api/v1/public/media/{file_path}
    // Remove leading slash if present
    final cleanMediaPath = mediaPath.startsWith('/')
        ? mediaPath.substring(1)
        : mediaPath;

    // Split the path into directory and filename parts
    final pathParts = cleanMediaPath.split('/');
    if (pathParts.isEmpty) return '$baseUrl/api/v1/public/media/';

    // Encode only the filename (last part), keep directory structure intact
    final directoryParts = pathParts.take(pathParts.length - 1).toList();
    final filename = pathParts.last;
    final encodedFilename = Uri.encodeComponent(filename);

    final encodedPath = directoryParts.isEmpty
        ? encodedFilename
        : '${directoryParts.join('/')}/$encodedFilename';

    return '$baseUrl/api/v1/public/media/$encodedPath';
  }

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Public API headers (for citizen access)
  static const Map<String, String> publicHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

class AppColors {
  static const Color primaryColor = Color(0xFF009B56);
  static const Color secondaryColor = Color(0xFFFFD700);
  static const Color accentColor = Color(0xFF2C3E50);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color textColor = Color(0xFF2C3E50);
  static const Color greyColor = Color(0xFF6B7280);
  static const Color lightGreyColor = Color(0xFFE5E7EB);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
}

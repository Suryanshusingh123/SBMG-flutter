import 'package:intl/intl.dart';

/// Utility class for handling date and time conversions to IST (Indian Standard Time).
/// IST is UTC+5:30.
///
/// **Backend always works in UTC.** All API timestamps (e.g. `created_at`,
/// `resolved_at`, `uploaded_at`) are in UTC. This util parses them as UTC and
/// converts to IST for display. When sending dates to the API, use [formatForAPI]
/// or [nowForAPI] to produce UTC ISO8601 strings.
class DateTimeUtils {
  // IST offset: UTC+5:30 = 5 hours and 30 minutes
  static const Duration istOffset = Duration(hours: 5, minutes: 30);

  /// Converts a DateTime to IST (Indian Standard Time).
  /// Assumes the input DateTime is in UTC.
  static DateTime toIST(DateTime dateTime) {
    // If the dateTime is already in local time, convert to UTC first
    DateTime utcDateTime;
    if (dateTime.isUtc) {
      utcDateTime = dateTime;
    } else {
      utcDateTime = dateTime.toUtc();
    }
    
    // Add IST offset (UTC+5:30)
    return utcDateTime.add(istOffset);
  }

  /// Parses a date string (UTC from backend) and converts it to IST.
  /// Input is ISO8601; if no timezone, treated as UTC.
  static DateTime parseToIST(String dateString) {
    // Backend always UTC; assume UTC if no timezone info
    DateTime dateTime;
    if (dateString.endsWith('Z') || dateString.contains('+') || dateString.contains('-', dateString.indexOf('T'))) {
      // Has timezone info, parse as is
      dateTime = DateTime.parse(dateString);
    } else {
      // No timezone info, assume UTC and add 'Z'
      dateTime = DateTime.parse('${dateString}Z');
    }
    
    // Ensure it's in UTC
    if (!dateTime.isUtc) {
      dateTime = dateTime.toUtc();
    }
    
    // Convert to IST
    return toIST(dateTime);
  }

  /// Gets current date and time in IST
  static DateTime nowIST() {
    return toIST(DateTime.now().toUtc());
  }

  /// Formats a DateTime in IST for display with date and time
  /// Format: "MMM d, yyyy, h:mm a" (e.g., "Jan 15, 2024, 2:30 PM")
  static String formatDateTimeIST(DateTime dateTime) {
    final istDateTime = dateTime.isUtc ? toIST(dateTime) : toIST(dateTime.toUtc());
    return DateFormat('MMM d, yyyy, h:mm a').format(istDateTime);
  }

  /// Formats a DateTime in IST for display with date only
  /// Format: "MMM d, yyyy" (e.g., "Jan 15, 2024")
  static String formatDateIST(DateTime dateTime) {
    final istDateTime = dateTime.isUtc ? toIST(dateTime) : toIST(dateTime.toUtc());
    return DateFormat('MMM d, yyyy').format(istDateTime);
  }

  /// Formats a DateTime in IST for display with time only
  /// Format: "h:mm a" (e.g., "2:30 PM")
  static String formatTimeIST(DateTime dateTime) {
    final istDateTime = dateTime.isUtc ? toIST(dateTime) : toIST(dateTime.toUtc());
    return DateFormat('h:mm a').format(istDateTime);
  }

  /// Formats a UTC date string from the backend to IST display format.
  /// Format: "MMM d, yyyy, h:mm a" (e.g., "Jan 15, 2024, 2:30 PM")
  static String formatDateStringIST(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Unknown';
    }
    try {
      final ist = parseToIST(dateString);
      return DateFormat('MMM d, yyyy, h:mm a').format(ist);
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Unified format for complaint list tiles (VDO, SMD, BDO, CEO, etc.).
  /// Input: UTC string from backend (e.g. `created_at`). Output: "dd/MM/yyyy" in IST.
  static String formatComplaintListIST(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '—';
    }
    try {
      final ist = parseToIST(dateString);
      return DateFormat('dd/MM/yyyy').format(ist);
    } catch (e) {
      return '—';
    }
  }

  /// Unified format for complaint details (header, timeline); includes time for verification.
  /// Input: UTC string from backend. Output: "dd/MM/yyyy, h:mm a" in IST.
  static String formatComplaintDetailIST(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Unknown';
    }
    try {
      final ist = parseToIST(dateString);
      return DateFormat('dd/MM/yyyy, h:mm a').format(ist);
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Converts a DateTime to UTC ISO8601 for API submission.
  /// Backend always expects UTC.
  static String formatForAPI(DateTime dateTime) {
    final istDateTime = dateTime.isUtc ? toIST(dateTime) : toIST(dateTime.toUtc());
    final utcForAPI = istDateTime.subtract(istOffset);
    return utcForAPI.toIso8601String();
  }

  /// Current date and time in UTC ISO8601 for API submission. Backend expects UTC.
  static String nowForAPI() {
    return DateTime.now().toUtc().toIso8601String();
  }
}

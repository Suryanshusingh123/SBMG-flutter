import 'package:intl/intl.dart';

/// Utility class for handling date and time conversions to IST (Indian Standard Time)
/// IST is UTC+5:30
class DateTimeUtils {
  // IST offset: UTC+5:30 = 5 hours and 30 minutes
  static const Duration istOffset = Duration(hours: 5, minutes: 30);

  /// Converts a DateTime to IST (Indian Standard Time)
  /// Assumes the input DateTime is in UTC
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

  /// Parses a date string and converts it to IST
  /// Assumes the input string is in ISO8601 format (UTC)
  static DateTime parseToIST(String dateString) {
    // Parse the date string - assume UTC if no timezone info
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

  /// Formats a DateTime in IST for API submission (ISO8601 format in IST)
  /// Returns ISO8601 string without timezone (treated as IST)
  static String formatForAPI(DateTime dateTime) {
    final istDateTime = dateTime.isUtc ? toIST(dateTime) : toIST(dateTime.toUtc());
    // Convert IST back to UTC for API (subtract offset)
    final utcForAPI = istDateTime.subtract(istOffset);
    return utcForAPI.toIso8601String();
  }

  /// Gets current date and time formatted for API submission (UTC ISO8601)
  static String nowForAPI() {
    return DateTime.now().toUtc().toIso8601String();
  }
}

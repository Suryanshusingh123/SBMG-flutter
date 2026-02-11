import 'dart:convert';

/// Returns a user-friendly message from API exceptions for display in snackbars/dialogs.
///
/// For API errors like `Exception: API Error: 404 - {"message":"No contractors found for this village","status_code":404}`,
/// returns only the `message` value: "No contractors found for this village".
///
/// For other exceptions, strips the "Exception: " prefix when present.
String userFriendlyApiMessage(dynamic e) {
  final s = e.toString();
  final dashBody = RegExp(r' - (.+)$').firstMatch(s);
  if (dashBody != null) {
    try {
      final decoded = jsonDecode(dashBody.group(1)!);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {}
  }
  return s.replaceFirst(RegExp(r'^Exception:\s*'), '');
}

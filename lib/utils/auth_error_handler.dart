import 'package:flutter/material.dart';

class AuthErrorHandler {
  /// Shows a dialog for 401 authentication errors with login options (for complaints page)
  static Future<bool?> showLoginRequiredDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF009B56).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: Color(0xFF009B56),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Authentication Required',
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'You need to log in to view your complaints.',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Login Button
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog

                // // Navigate to login screen
                // final result = await Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const CitizenLoginScreen(),
                //   ),
                // );

                // Return login result
                // if (result == true && context.mounted) {
                //   Navigator.of(context).pop(true);
                // }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009B56),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Login',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Checks if an error is a 401 authentication error
  static bool isAuthError(dynamic error) {
    if (error is Exception) {
      final errorString = error.toString();
      return errorString.contains('401') ||
          errorString.contains('Invalid or missing user token') ||
          errorString.contains('Unauthorized') ||
          errorString.contains('status_code":401');
    }
    return false;
  }
}

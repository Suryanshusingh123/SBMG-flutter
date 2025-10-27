import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback? onClose;

  const SuccessDialog({
    super.key,
    required this.message,
    this.buttonText = 'Close',
    this.onClose,
  });

  static void show({
    required BuildContext context,
    required String message,
    String buttonText = 'Close',
    VoidCallback? onClose,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        message: message,
        buttonText: buttonText,
        onClose: onClose,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF009B56),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.white, size: 50),
            ),

            SizedBox(height: 24),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
                height: 1.3,
              ),
            ),

            SizedBox(height: 32),

            // Close Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (onClose != null) {
                    onClose!();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009B56),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

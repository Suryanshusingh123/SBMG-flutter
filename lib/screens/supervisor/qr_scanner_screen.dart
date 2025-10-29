import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../l10n/app_localizations.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController();

  bool _hasDetectedQR = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera scanner
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              if (_hasDetectedQR) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                _hasDetectedQR = true;
                final barcode = barcodes.first;
                final rawValue = barcode.rawValue;

                if (rawValue != null && rawValue.isNotEmpty) {
                  print('📱 QR Code Detected: $rawValue');
                  _handleQRCode(rawValue);
                }
              }
            },
          ),

          // Overlay with scanning area
          _buildOverlay(),

          // Back button
          Positioned(
            top: 40.h,
            left: 16.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: const Color(0xFF111827),
                  size: 24.sp,
                ),
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.scanQrCodeForAttendance,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        // Dimmed background
        Positioned.fill(child: Container(color: Colors.black.withOpacity(0.6))),

        // Scanning window
        Positioned(
          top: MediaQuery.of(context).size.height / 2 - 150.h,
          left: MediaQuery.of(context).size.width / 2 - 150.w,
          child: CustomPaint(
            size: Size(300.w, 300.h),
            painter: ScanningOverlayPainter(),
          ),
        ),
      ],
    );
  }

  void _handleQRCode(String qrData) {
    // Parse QR code data to extract lat and long
    // Expected format: lat,long or {"lat": "...", "long": "..."}

    Map<String, String>? coordinates;

    try {
      // Try to parse as JSON
      if (qrData.startsWith('{')) {
        final json = qrData.replaceAll(RegExp(r'[\{\}]'), '');
        final parts = json.split(',');

        String? lat, long;
        for (final part in parts) {
          if (part.contains('"lat"')) {
            lat = part.split(':')[1].replaceAll('"', '').trim();
          } else if (part.contains('"long"')) {
            long = part.split(':')[1].replaceAll('"', '').trim();
          }
        }

        if (lat != null && long != null) {
          coordinates = {'lat': lat, 'long': long};
        }
      } else if (qrData.contains(',')) {
        // Try to parse as comma-separated values
        final parts = qrData.split(',');
        if (parts.length == 2) {
          coordinates = {'lat': parts[0].trim(), 'long': parts[1].trim()};
        }
      }
    } catch (e) {
      print('❌ Error parsing QR code: $e');
    }

    if (coordinates != null &&
        coordinates['lat'] != null &&
        coordinates['long'] != null) {
      print(
        '✅ Parsed coordinates: ${coordinates['lat']}, ${coordinates['long']}',
      );

      // Close scanner and return coordinates
      _cameraController.stop();
      Navigator.pop(context, coordinates);
    } else {
      // Show error dialog
      _cameraController.stop();
      _showErrorDialog(AppLocalizations.of(context)!.invalidQRCodeFormat);
    }
  }

  void _showErrorDialog(String message) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.scanError),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              setState(() {
                _hasDetectedQR = false;
              });
              _cameraController.start(); // Restart scanner
            },
            child: Text(l10n.tryAgain),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context), // Close scanner
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}

class ScanningOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw corners
    final cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, cornerLength), paint);

    // Top-right corner
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerLength),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLength, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

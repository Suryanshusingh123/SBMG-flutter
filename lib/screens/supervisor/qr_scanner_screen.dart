import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/app_localizations.dart';
import '../../services/code_scanner_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    // Auto-start scan when screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.05),
              ),
            ),
            // Back button
            Positioned(
              top: 16.h,
              left: 16.w,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
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
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 80.sp,
                      color: const Color(0xFF111827),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      l10n.scanQrCodeForAttendance,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF111827),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      _isScanning ? l10n.loading : l10n.tapToScanQRCode,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isScanning ? null : _startScan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF009B56),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: _isScanning
                            ? SizedBox(
                                height: 18.sp,
                                width: 18.sp,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n.scan,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startScan() async {
    if (_isScanning) return;
    setState(() => _isScanning = true);

    try {
      final raw = await CodeScannerService.scanQr();
      if (!mounted) return;

      if (raw == null || raw.isEmpty) {
        // User cancelled or nothing scanned.
        Navigator.pop(context);
        return;
      }

      print('📱 QR Code Detected: $raw');
      _handleQRCode(raw);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(AppLocalizations.of(context)!.scanError);
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
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
      Navigator.pop(context, coordinates);
    } else {
      // Show error dialog
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
              _startScan();
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

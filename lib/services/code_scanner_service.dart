import 'dart:io' show Platform;

import 'package:flutter/services.dart';

class CodeScannerService {
  static const MethodChannel _channel = MethodChannel('sbmg/code_scanner');

  /// Launches Google Play services Code Scanner UI (Android only).
  ///
  /// Returns the raw scanned string, or null if the user cancels.
  static Future<String?> scanQr() async {
    if (!Platform.isAndroid) return null;
    final result = await _channel.invokeMethod<String>('scanQr');
    return result;
  }
}


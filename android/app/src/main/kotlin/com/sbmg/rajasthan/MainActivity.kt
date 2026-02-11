package com.sbmg.rajasthan

import android.content.Intent
import com.google.android.gms.tasks.Task
import com.google.mlkit.vision.codescanner.GmsBarcodeScanner
import com.google.mlkit.vision.codescanner.GmsBarcodeScannerOptions
import com.google.mlkit.vision.codescanner.GmsBarcodeScanning
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "sbmg/code_scanner"

    private var pendingResult: MethodChannel.Result? = null
    private var pendingTask: Task<com.google.mlkit.vision.barcode.common.Barcode>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanQr" -> startQrScan(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun startQrScan(result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("SCAN_IN_PROGRESS", "A scan is already in progress", null)
            return
        }

        val options = GmsBarcodeScannerOptions.Builder()
            .setBarcodeFormats(com.google.mlkit.vision.barcode.common.Barcode.FORMAT_QR_CODE)
            .build()

        val scanner: GmsBarcodeScanner = GmsBarcodeScanning.getClient(this, options)

        pendingResult = result
        pendingTask = scanner.startScan()

        pendingTask
            ?.addOnSuccessListener { barcode ->
                val raw = barcode.rawValue
                pendingResult?.success(raw)
                clearPending()
            }
            ?.addOnCanceledListener {
                // Return null on cancel
                pendingResult?.success(null)
                clearPending()
            }
            ?.addOnFailureListener { e ->
                pendingResult?.error("SCAN_FAILED", e.message, null)
                clearPending()
            }
    }

    private fun clearPending() {
        pendingResult = null
        pendingTask = null
    }
}

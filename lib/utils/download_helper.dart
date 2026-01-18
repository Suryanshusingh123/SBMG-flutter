import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Helper class to handle file downloads to mobile Downloads folder
class DownloadHelper {
  /// Downloads a file to the Downloads folder on mobile devices
  /// Returns the file path if successful, null otherwise
  static Future<String?> downloadToDownloadsFolder({
    required String fileName,
    required String content,
  }) async {
    try {
      Directory? downloadsDir;

      if (Platform.isAndroid) {
        // For Android, try multiple approaches
        downloadsDir = await _getAndroidDownloadsDirectory();
      } else if (Platform.isIOS) {
        // For iOS, use application documents directory
        // Note: iOS doesn't have a public Downloads folder accessible to apps
        downloadsDir = await getApplicationDocumentsDirectory();
      } else {
        // For other platforms (Windows, Linux, macOS)
        // Try getDownloadsDirectory if available, otherwise use external storage
        try {
          downloadsDir = await getDownloadsDirectory();
        } catch (e) {
          // Fallback to external storage directory
          downloadsDir = await getExternalStorageDirectory();
        }
      }

      if (downloadsDir == null) {
        throw Exception('Could not access downloads directory');
      }

      // Create directory if it doesn't exist
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Create the file
      final file = File('${downloadsDir.path}/$fileName');

      // Write content to file
      await file.writeAsString(content);

      // Verify file was created
      if (await file.exists()) {
        return file.path;
      } else {
        throw Exception('File was not created successfully');
      }
    } catch (e) {
      print('❌ Error downloading file: $e');
      return null;
    }
  }

  /// Gets the Android Downloads directory
  /// Tries multiple approaches for different Android versions
  static Future<Directory?> _getAndroidDownloadsDirectory() async {
    try {
      // Approach 1: Try the standard Downloads path (works on Android < 10)
      final standardDownloadsPath = '/storage/emulated/0/Download';
      final standardDir = Directory(standardDownloadsPath);
      
      // Check if we can access this directory
      if (await standardDir.exists() || await _canAccessDirectory(standardDir)) {
        return standardDir;
      }

      // Approach 2: Try getting external storage public directory
      // Using external storage directory and creating Download subfolder
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        // Get the parent directory (usually Android/data/com.xxx.xxx/files)
        // and try to navigate to Download
        final parentDir = externalDir.parent.parent.parent;
        final downloadsPath = '${parentDir.path}/Download';
        final downloadsDir = Directory(downloadsPath);
        
        if (await downloadsDir.exists() || await _canCreateDirectory(downloadsDir)) {
          return downloadsDir;
        }
      }

      // Approach 3: Try using external storage root
      final externalStorageDir = await getExternalStorageDirectory();
      if (externalStorageDir != null) {
        // Try common paths
        final possiblePaths = [
          '/storage/emulated/0/Download',
          '/sdcard/Download',
          '${externalStorageDir.parent.parent.path}/Download',
        ];

        for (final path in possiblePaths) {
          final dir = Directory(path);
          if (await dir.exists() || await _canCreateDirectory(dir)) {
            return dir;
          }
        }
      }

      // Approach 4: Fallback to external storage directory
      // User can manually move the file if needed
      final fallbackDir = await getExternalStorageDirectory();
      if (fallbackDir != null) {
        // Create a Downloads subfolder in app's external storage
        final appDownloadsDir = Directory('${fallbackDir.path}/Downloads');
        await appDownloadsDir.create(recursive: true);
        return appDownloadsDir;
      }

      return null;
    } catch (e) {
      print('❌ Error getting Android Downloads directory: $e');
      // Final fallback
      return await getExternalStorageDirectory();
    }
  }

  /// Checks if we can access a directory
  static Future<bool> _canAccessDirectory(Directory dir) async {
    try {
      // Try to list the directory
      await dir.list().first;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Checks if we can create a directory
  static Future<bool> _canCreateDirectory(Directory dir) async {
    try {
      await dir.create(recursive: true);
      return await dir.exists();
    } catch (e) {
      return false;
    }
  }

  /// Requests storage permissions for Android
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) {
      return true; // No permission needed for non-Android
    }

    try {
      // For Android 13+ (API 33+), we don't need WRITE_EXTERNAL_STORAGE
      // For Android < 13, request WRITE_EXTERNAL_STORAGE
      final androidVersion = await _getAndroidVersion();
      
      if (androidVersion >= 33) {
        // Android 13+ doesn't require WRITE_EXTERNAL_STORAGE for MediaStore
        // But we still need MANAGE_EXTERNAL_STORAGE for direct file access
        return true;
      } else {
        // For Android < 13, request WRITE_EXTERNAL_STORAGE
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } catch (e) {
      print('❌ Error requesting storage permission: $e');
      return false;
    }
  }

  /// Gets Android version (API level)
  static Future<int> _getAndroidVersion() async {
    try {
      // This is a simple approach - in a real app you might want to use
      // platform channels to get the exact version
      // For now, we'll assume we need to handle Android 10+ differently
      return 30; // Default to Android 10, but this should be dynamic
    } catch (e) {
      return 30;
    }
  }
}

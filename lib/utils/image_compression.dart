import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

/// Maximum file size in bytes (2MB)
const int maxFileSizeBytes = 2 * 1024 * 1024;

/// Maximum image width/height for compression
const int maxImageDimension = 1920;

/// Quality for JPEG compression (0-100)
const int compressionQuality = 85;

/// Compresses an image file to reduce its size
/// Returns a compressed File, or the original file if compression fails
///
/// The function will:
/// - Resize the image if it's larger than maxImageDimension
/// - Compress JPEG quality to compressionQuality
/// - Ensure the final file size is under maxFileSizeBytes
Future<File> compressImage(File imageFile) async {
  try {
    // Check if file exists
    if (!await imageFile.exists()) {
      print('⚠️ Image file does not exist: ${imageFile.path}');
      return imageFile;
    }

    // Get original file size
    final originalSize = await imageFile.length();
    print(
      '📸 Original image size: ${(originalSize / 1024).toStringAsFixed(2)} KB',
    );

    // If file is already small enough, return as-is
    if (originalSize <= maxFileSizeBytes) {
      print('✅ Image is already small enough, skipping compression');
      return imageFile;
    }

    // Get temporary directory for compressed image
    final tempDir = await getTemporaryDirectory();
    final fileName = path.basename(imageFile.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final compressedPath = path.join(
      tempDir.path,
      'compressed_$timestamp$fileName',
    );

    // Read image to get dimensions
    final imageBytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      print('⚠️ Could not decode image, using original file');
      return imageFile;
    }

    // Calculate resize dimensions if needed
    int targetWidth = decodedImage.width;
    int targetHeight = decodedImage.height;
    int quality = compressionQuality;

    if (targetWidth > maxImageDimension || targetHeight > maxImageDimension) {
      final ratio = targetWidth > targetHeight
          ? maxImageDimension / targetWidth
          : maxImageDimension / targetHeight;
      targetWidth = (targetWidth * ratio).round();
      targetHeight = (targetHeight * ratio).round();
      print('📐 Resizing to: ${targetWidth}x$targetHeight');
    }

    // Compress the image
    // Only set minWidth/minHeight if we need to resize (when dimensions exceed max)
    final bool needsResize =
        targetWidth > maxImageDimension || targetHeight > maxImageDimension;
    final compressedXFile = needsResize
        ? await FlutterImageCompress.compressAndGetFile(
            imageFile.absolute.path,
            compressedPath,
            quality: quality,
            minWidth: targetWidth,
            minHeight: targetHeight,
            keepExif: true,
          )
        : await FlutterImageCompress.compressAndGetFile(
            imageFile.absolute.path,
            compressedPath,
            quality: quality,
            keepExif: true,
          );

    if (compressedXFile == null) {
      print('⚠️ Compression returned null, using original file');
      return imageFile;
    }

    // Convert XFile to File
    final compressedFile = File(compressedXFile.path);

    // Check compressed file size
    final compressedSize = await compressedFile.length();
    print(
      '📦 Compressed image size: ${(compressedSize / 1024).toStringAsFixed(2)} KB',
    );
    print(
      '📉 Size reduction: ${((1 - compressedSize / originalSize) * 100).toStringAsFixed(1)}%',
    );

    // If still too large, try more aggressive compression
    if (compressedSize > maxFileSizeBytes) {
      print(
        '⚠️ Compressed image still too large, applying more aggressive compression...',
      );

      final moreCompressedPath = path.join(
        tempDir.path,
        'compressed_aggressive_$timestamp$fileName',
      );

      // More aggressive: smaller dimensions and lower quality
      final aggressiveWidth = (targetWidth * 0.7).round();
      final aggressiveHeight = (targetHeight * 0.7).round();

      final moreCompressedXFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        moreCompressedPath,
        quality: 70, // Lower quality
        minWidth: aggressiveWidth,
        minHeight: aggressiveHeight,
        keepExif: true,
      );

      if (moreCompressedXFile != null) {
        final moreCompressedFile = File(moreCompressedXFile.path);
        final moreCompressedSize = await moreCompressedFile.length();
        print(
          '📦 Aggressively compressed size: ${(moreCompressedSize / 1024).toStringAsFixed(2)} KB',
        );

        if (moreCompressedSize <= maxFileSizeBytes) {
          return moreCompressedFile;
        }
      }
    }

    return compressedFile;
  } catch (e) {
    print('❌ Error compressing image: $e');
    // Return original file if compression fails
    return imageFile;
  }
}

/// Compresses multiple image files
/// Returns a list of compressed Files
Future<List<File>> compressImages(List<File> imageFiles) async {
  final List<File> compressedFiles = [];

  for (int i = 0; i < imageFiles.length; i++) {
    print('🔄 Compressing image ${i + 1}/${imageFiles.length}...');
    final compressedFile = await compressImage(imageFiles[i]);
    compressedFiles.add(compressedFile);
  }

  return compressedFiles;
}

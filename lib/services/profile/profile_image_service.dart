import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Service for handling profile image operations
///
/// This service provides functionality for:
/// - Image selection from gallery
/// - Image validation and optimization
/// - Avatar generation from initials
/// - Image format conversion and resizing
class ProfileImageService {
  static final ProfileImageService _instance = ProfileImageService._internal();
  factory ProfileImageService() => _instance;
  ProfileImageService._internal();

  final ImagePicker _imagePicker = ImagePicker();

  // Image constraints
  static const int maxImageSize = 512; // Max width/height in pixels
  static const int maxFileSizeBytes = 1024 * 1024; // 1MB
  static const double jpegQuality = 0.85;

  /// Picks an image from the device gallery
  ///
  /// Returns the path to the selected image, or null if cancelled
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxImageSize.toDouble(),
        maxHeight: maxImageSize.toDouble(),
        imageQuality: (jpegQuality * 100).round(),
        preferredCameraDevice: CameraDevice.front,
      );

      if (image == null) return null;

      // Validate the selected image
      final isValid = await validateImage(image.path);
      if (!isValid) {
        throw Exception('Selected image is not valid or too large');
      }

      return image.path;
    } catch (e) {
      throw ProfileImageException('Failed to pick image from gallery: $e');
    }
  }

  /// Validates an image file
  ///
  /// Checks file size, format, and dimensions
  Future<bool> validateImage(String imagePath) async {
    try {
      final file = File(imagePath);

      // Check if file exists
      if (!await file.exists()) {
        return false;
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize > maxFileSizeBytes) {
        return false;
      }

      // Decode image to check dimensions and format
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // Check dimensions (should be reasonable for profile pictures)
      if (image.width > maxImageSize * 2 || image.height > maxImageSize * 2) {
        return false;
      }

      image.dispose();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Generates an avatar image from initials
  ///
  /// Creates a circular avatar with initials and returns the image bytes
  Future<Uint8List> generateAvatarFromInitials({
    required String initials,
    required Color backgroundColor,
    required Color textColor,
    int size = 256,
  }) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..color = backgroundColor;

      // Draw circular background
      canvas.drawCircle(
        Offset(size / 2, size / 2),
        size / 2,
        paint,
      );

      // Draw initials text
      final textPainter = TextPainter(
        text: TextSpan(
          text: initials,
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w500,
            letterSpacing: size * 0.02,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Center the text
      final textOffset = Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      );

      textPainter.paint(canvas, textOffset);

      // Convert to image
      final picture = recorder.endRecording();
      final image = await picture.toImage(size, size);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      picture.dispose();
      image.dispose();

      return byteData!.buffer.asUint8List();
    } catch (e) {
      throw ProfileImageException('Failed to generate avatar: $e');
    }
  }

  /// Gets suggested colors for avatar background
  List<Color> getAvatarColors() {
    return [
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFF44336), // Red
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFF795548), // Brown
      const Color(0xFF009688), // Teal
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF3F51B5), // Indigo
    ];
  }

  /// Selects an avatar color based on initials
  ///
  /// Uses a hash of the initials to consistently select the same color
  Color selectAvatarColor(String initials) {
    final colors = getAvatarColors();
    final hash = initials.hashCode.abs();
    return colors[hash % colors.length];
  }

  /// Generates a complete avatar from name
  ///
  /// Creates initials from the name and generates an avatar image
  Future<Uint8List> generateAvatarFromName({
    required String firstName,
    String? lastName,
    int size = 256,
  }) async {
    // Generate initials
    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName != null && lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    if (initials.isEmpty) {
      initials = 'U'; // Default fallback
    }

    // Select colors
    final backgroundColor = selectAvatarColor(initials);
    final textColor = _getContrastingTextColor(backgroundColor);

    return await generateAvatarFromInitials(
      initials: initials,
      backgroundColor: backgroundColor,
      textColor: textColor,
      size: size,
    );
  }

  /// Gets a contrasting text color for a background color
  Color _getContrastingTextColor(Color backgroundColor) {
    // Calculate luminance to determine if text should be light or dark
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  /// Resizes an image to fit within the specified dimensions
  ///
  /// Maintains aspect ratio and reduces file size
  Future<String> resizeImage(String imagePath, {int maxSize = maxImageSize}) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();

      // Decode image
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: maxSize,
        targetHeight: maxSize,
      );

      final frame = await codec.getNextFrame();
      final resizedImage = frame.image;

      // Convert back to bytes
      final byteData = await resizedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Failed to convert resized image to bytes');
      }

      // Write to temporary file
      final resizedBytes = byteData.buffer.asUint8List();
      final tempFile = File('${imagePath}_resized.png');
      await tempFile.writeAsBytes(resizedBytes);

      resizedImage.dispose();

      return tempFile.path;
    } catch (e) {
      throw ProfileImageException('Failed to resize image: $e');
    }
  }

  /// Saves avatar bytes to a temporary file
  ///
  /// Used for saving generated avatars
  Future<String> saveAvatarToTemp(Uint8List avatarBytes, String fileName) async {
    try {
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/$fileName.png');
      await tempFile.writeAsBytes(avatarBytes);
      return tempFile.path;
    } catch (e) {
      throw ProfileImageException('Failed to save avatar to temp file: $e');
    }
  }

  /// Cleans up temporary image files
  Future<void> cleanupTempFiles(List<String> filePaths) async {
    for (final path in filePaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Log but don't throw - cleanup failures shouldn't break the app
        debugPrint('Failed to cleanup temp file $path: $e');
      }
    }
  }

  /// Gets image info without loading the full image
  Future<ImageInfo?> getImageInfo(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final info = ImageInfo(
        width: image.width,
        height: image.height,
        fileSizeBytes: bytes.length,
      );

      image.dispose();
      return info;
    } catch (e) {
      return null;
    }
  }
}

/// Information about an image file
class ImageInfo {
  final int width;
  final int height;
  final int fileSizeBytes;

  const ImageInfo({
    required this.width,
    required this.height,
    required this.fileSizeBytes,
  });

  double get aspectRatio => width / height;
  String get fileSizeMB => (fileSizeBytes / (1024 * 1024)).toStringAsFixed(2);
}

/// Exception thrown by ProfileImageService
class ProfileImageException implements Exception {
  final String message;

  const ProfileImageException(this.message);

  @override
  String toString() => 'ProfileImageException: $message';
}

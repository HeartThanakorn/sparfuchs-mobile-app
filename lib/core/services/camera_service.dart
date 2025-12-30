import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

/// Result of image capture or selection
class ImageCaptureResult {
  final File file;
  final Uint8List bytes;
  final int originalSize;
  final int compressedSize;

  ImageCaptureResult({
    required this.file,
    required this.bytes,
    required this.originalSize,
    required this.compressedSize,
  });

  /// Compression ratio (0-1, lower is better)
  double get compressionRatio => compressedSize / originalSize;
}

/// Service for camera operations and image processing
class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  final ImagePicker _imagePicker = ImagePicker();

  /// Maximum file size in bytes (1MB for API efficiency)
  static const int maxFileSizeBytes = 1024 * 1024; // 1MB

  /// Quality levels for compression (start high, reduce if needed)
  static const List<int> _qualityLevels = [90, 80, 70, 60, 50, 40, 30];

  /// Get current camera controller
  CameraController? get controller => _controller;

  /// Check if camera is initialized
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  /// Initialize camera with available cameras
  Future<void> initialize({
    ResolutionPreset resolution = ResolutionPreset.high,
    CameraLensDirection preferredLens = CameraLensDirection.back,
  }) async {
    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        throw CameraException('no_cameras', 'No cameras available on device');
      }

      // Find preferred camera (back camera for receipts)
      final camera = _cameras!.firstWhere(
        (cam) => cam.lensDirection == preferredLens,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        camera,
        resolution,
        enableAudio: false, // No audio needed for receipt scanning
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      // Set flash mode to auto by default
      await _controller!.setFlashMode(FlashMode.auto);
    } catch (e) {
      debugPrint('CameraService.initialize error: $e');
      rethrow;
    }
  }

  /// Capture image from camera
  /// Returns compressed image data ready for API upload
  Future<ImageCaptureResult> captureImage() async {
    if (_controller == null || !isInitialized) {
      throw CameraException('not_initialized', 'Camera not initialized');
    }

    try {
      // Take picture
      final XFile xFile = await _controller!.takePicture();
      final File originalFile = File(xFile.path);
      final int originalSize = await originalFile.length();

      // Compress image to max 1MB
      final compressedResult = await _compressImage(
        originalFile,
        originalSize,
      );

      return compressedResult;
    } catch (e) {
      debugPrint('CameraService.captureImage error: $e');
      rethrow;
    }
  }

  /// Pick image from device gallery
  /// Returns compressed image data ready for API upload
  Future<ImageCaptureResult?> pickFromGallery() async {
    try {
      final XFile? xFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000, // Reasonable max for receipt images
        maxHeight: 3000,
      );

      if (xFile == null) {
        return null; // User cancelled
      }

      final File originalFile = File(xFile.path);
      final int originalSize = await originalFile.length();

      // Compress image to max 1MB
      final compressedResult = await _compressImage(
        originalFile,
        originalSize,
      );

      return compressedResult;
    } catch (e) {
      debugPrint('CameraService.pickFromGallery error: $e');
      rethrow;
    }
  }

  /// Compress image to target size (max 1MB)
  /// Uses iterative quality reduction to achieve target size
  Future<ImageCaptureResult> _compressImage(
    File originalFile,
    int originalSize,
  ) async {
    // If already under limit, just read the file
    if (originalSize <= maxFileSizeBytes) {
      final bytes = await originalFile.readAsBytes();
      return ImageCaptureResult(
        file: originalFile,
        bytes: bytes,
        originalSize: originalSize,
        compressedSize: originalSize,
      );
    }

    Uint8List? compressedBytes;
    int compressedSize = originalSize;

    // Try decreasing quality levels until under limit
    for (final quality in _qualityLevels) {
      compressedBytes = await FlutterImageCompress.compressWithFile(
        originalFile.path,
        quality: quality,
        format: CompressFormat.jpeg,
        // Optionally reduce dimensions for very large images
        minWidth: quality < 50 ? 1500 : 2000,
        minHeight: quality < 50 ? 2000 : 3000,
      );

      if (compressedBytes != null) {
        compressedSize = compressedBytes.length;
        if (compressedSize <= maxFileSizeBytes) {
          break;
        }
      }
    }

    // If still too large after all quality reductions, use lowest quality result
    if (compressedBytes == null) {
      throw CameraException(
        'compression_failed',
        'Could not compress image to target size',
      );
    }

    // Save compressed bytes to temp file
    final tempDir = originalFile.parent;
    final compressedFile = File(
      '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await compressedFile.writeAsBytes(compressedBytes);

    return ImageCaptureResult(
      file: compressedFile,
      bytes: compressedBytes,
      originalSize: originalSize,
      compressedSize: compressedSize,
    );
  }

  /// Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller != null && isInitialized) {
      await _controller!.setFlashMode(mode);
    }
  }

  /// Toggle between front and back camera
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      return; // No camera to switch to
    }

    final currentLens = _controller?.description.lensDirection;
    final newLens = currentLens == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    await dispose();
    await initialize(preferredLens: newLens);
  }

  /// Set focus point (for tap-to-focus)
  Future<void> setFocusPoint(Offset point) async {
    if (_controller != null && isInitialized) {
      try {
        await _controller!.setFocusPoint(point);
        await _controller!.setExposurePoint(point);
      } catch (e) {
        // Some devices don't support focus point
        debugPrint('CameraService.setFocusPoint not supported: $e');
      }
    }
  }

  /// Set zoom level (1.0 = no zoom)
  Future<void> setZoomLevel(double zoom) async {
    if (_controller != null && isInitialized) {
      final minZoom = await _controller!.getMinZoomLevel();
      final maxZoom = await _controller!.getMaxZoomLevel();
      final clampedZoom = zoom.clamp(minZoom, maxZoom);
      await _controller!.setZoomLevel(clampedZoom);
    }
  }

  /// Dispose camera resources
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}

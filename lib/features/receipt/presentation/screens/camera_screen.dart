import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/core/services/camera_service.dart';
import 'package:sparfuchs_ai/features/receipt/data/repositories/scan_repository.dart';
import 'package:sparfuchs_ai/features/receipt/presentation/screens/verification_screen.dart';
import 'package:sparfuchs_ai/shared/theme/app_theme.dart';



/// Camera screen for capturing receipt images
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  bool _isInitializing = true;
  bool _isCapturing = false;
  FlashMode _flashMode = FlashMode.auto;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraService.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cameraService.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });
    try {
      await _cameraService.initialize();
      if (mounted) setState(() => _isInitializing = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Camera could not start: $e';
        });
      }
    }
  }

  Future<void> _captureImage() async {
    if (_isCapturing || !_cameraService.isInitialized) return;
    setState(() => _isCapturing = true);

    try {
      final result = await _cameraService.captureImage();
      if (!mounted) return;

      final file = result.file;
      final scanRepo = ref.read(scanRepositoryProvider);
      final receiptData = await scanRepo.scanReceipt(file);

      // Create a temporary Receipt object for verification
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'temp_user';
      final tempReceipt = Receipt(
        receiptId: 'new_receipt', // Marker for new receipt
        userId: userId,
        householdId: null,
        imageUrl: '', // Empty, using localImage
        isBookmarked: false,
        receiptData: receiptData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              receipt: tempReceipt,
              localImage: file,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Processing error: $e'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final result = await _cameraService.pickFromGallery();
      if (result != null && mounted) {
        setState(() => _isCapturing = true);
        try {
          final file = result.file;
          final scanRepo = ref.read(scanRepositoryProvider);
          final receiptData = await scanRepo.scanReceipt(file);

          final userId = FirebaseAuth.instance.currentUser?.uid ?? 'temp_user';
          final tempReceipt = Receipt(
            receiptId: 'new_receipt',
            userId: userId,
            householdId: null,
            imageUrl: '',
            isBookmarked: false,
            receiptData: receiptData,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          if (mounted) {
            await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationScreen(
                  receipt: tempReceipt,
                  localImage: file,
                ),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Processing error: $e'),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        } finally {
          if (mounted) setState(() => _isCapturing = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selection error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _toggleFlash() async {
    final modes = [FlashMode.auto, FlashMode.always, FlashMode.off];
    final currentIndex = modes.indexOf(_flashMode);
    final nextMode = modes[(currentIndex + 1) % modes.length];
    await _cameraService.setFlashMode(nextMode);
    setState(() => _flashMode = nextMode);
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.torch:
        return Icons.highlight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) return _buildErrorView();
    if (_isInitializing) return _buildLoadingView();

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildCameraPreview(),
        _buildReceiptOverlay(),
        _buildTopBar(),
        _buildBottomBar(),
        if (_isCapturing) _buildCapturingOverlay(),
      ],
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('Starting camera...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeCamera,
              icon: const Icon(Icons.refresh),
              label: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTapDown: (details) {
        final size = MediaQuery.of(context).size;
        final point = Offset(
          details.localPosition.dx / size.width,
          details.localPosition.dy / size.height,
        );
        _cameraService.setFocusPoint(point);
      },
      child: Center(child: CameraPreview(controller)),
    );
  }

  Widget _buildReceiptOverlay() {
    return IgnorePointer(
      child: CustomPaint(
        painter: ReceiptOverlayPainter(
          guideColor: AppTheme.primaryTeal.withValues(alpha: 0.8),
          overlayColor: Colors.black.withValues(alpha: 0.4),
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.black54, borderRadius: BorderRadius.circular(16)),
            child: const Text('Kassenbon im Rahmen ausrichten',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ActionButton(
                icon: Icons.photo_library,
                label: 'Galerie',
                onTap: _pickFromGallery),
            _CaptureButton(onTap: _captureImage, isCapturing: _isCapturing),
            _ActionButton(
                icon: _getFlashIcon(),
                label: _flashMode.name,
                onTap: _toggleFlash),
          ],
        ),
      ),
    );
  }

  Widget _buildCapturingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('AI analyzing receipt...',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Das kann einen Moment dauern',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class ReceiptOverlayPainter extends CustomPainter {
  final Color guideColor;
  final Color overlayColor;

  ReceiptOverlayPainter({required this.guideColor, required this.overlayColor});

  @override
  void paint(Canvas canvas, Size size) {
    final guideWidth = size.width * 0.85;
    final guideHeight = guideWidth * 1.5;
    final guideRect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 - 40),
        width: guideWidth,
        height: guideHeight);
    final overlayPaint = Paint()..color = overlayColor;
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(guideRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);
    final borderPaint = Paint()
      ..color = guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
        RRect.fromRectAndRadius(guideRect, const Radius.circular(12)),
        borderPaint);
    _drawCornerAccents(canvas, guideRect, borderPaint);
  }

  void _drawCornerAccents(Canvas canvas, Rect rect, Paint paint) {
    const accentLength = 24.0;
    final accentPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final corners = [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight
    ];
    for (final corner in corners) {
      final isLeft = corner.dx < rect.center.dx;
      final isTop = corner.dy < rect.center.dy;
      canvas.drawLine(
          corner,
          Offset(
              corner.dx + (isLeft ? accentLength : -accentLength), corner.dy),
          accentPaint);
      canvas.drawLine(
          corner,
          Offset(corner.dx,
              corner.dy + (isTop ? accentLength : -accentLength)),
          accentPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(26)),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isCapturing;
  const _CaptureButton({required this.onTap, required this.isCapturing});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isCapturing ? null : onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4)),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCapturing ? Colors.grey : Colors.white),
          child: isCapturing
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                      strokeWidth: 3, color: Colors.white))
              : null,
        ),
      ),
    );
  }
}

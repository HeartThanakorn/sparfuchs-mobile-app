import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparfuchs_ai/core/config/api_key_config.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/features/receipt/data/services/gemini_scan_service.dart';

// Service provider
final geminiScanServiceProvider = Provider<GeminiScanService>((ref) {
  final apiKey = ApiKeyConfig.geminiApiKey;
  return GeminiScanService(apiKey: apiKey);
});

// Repository provider
final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  final service = ref.watch(geminiScanServiceProvider);
  return ScanRepository(service);
});

/// Repository for handling receipt scanning
class ScanRepository {
  final GeminiScanService _service;

  ScanRepository(this._service);

  /// Scans a receipt image and returns parsed data
  Future<ReceiptData> scanReceipt(File imageFile) async {
    return _service.scanReceipt(imageFile);
  }
}

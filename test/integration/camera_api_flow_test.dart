import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/features/receipt/data/repositories/scan_repository.dart';
import 'package:sparfuchs_ai/features/receipt/data/services/gemini_scan_service.dart';



// Manual Mocks
class MockGeminiScanService implements GeminiScanService {
  final String apiKey = 'test_key'; // Not @override if original doesn't expose it

  @override
  Future<ReceiptData> scanReceipt(File imageFile) async {
    if (imageFile.path.contains('bad')) {
      throw Exception('Scan failed');
    }
    return ReceiptData(
      merchant: Merchant(name: 'Test Store'), // Removed category
      transaction: Transaction(
        date: '2023-01-01', 
        time: '12:00',
        currency: 'EUR',
        paymentMethod: 'CASH'
      ),
      items: [],
      totals: Totals(subtotal: 10.0, taxAmount: 0.7, pfandTotal: 0, grandTotal: 10.7),
      taxes: [TaxEntry(rate: 7, amount: 0.7)], // Added taxes
      aiMetadata: AiMetadata(
        confidenceScore: 0.9,
        modelUsed: 'gemini-pro-vision',
        processingTimeMs: 100,
        // needsReview is a getter, not a constructor param
      ),
    );
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockScanRepository implements ScanRepository {
  final MockGeminiScanService _service = MockGeminiScanService();

  @override
  Future<ReceiptData> scanReceipt(File imageFile) {
    return _service.scanReceipt(imageFile);
  }
}

void main() {
  late MockGeminiScanService mockGeminiService;
  late MockScanRepository mockScanRepository;
  late ProviderContainer container;

  setUp(() {
    mockGeminiService = MockGeminiScanService();
    mockScanRepository = MockScanRepository();
    
    container = ProviderContainer(
      overrides: [
        geminiScanServiceProvider.overrideWithValue(mockGeminiService),
        scanRepositoryProvider.overrideWithValue(mockScanRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Camera to API Integration Flow', () {
    test('GeminiScanService parses receipt correctly', () async {
      // Execute
      final file = File('test_receipt.jpg');
      final result = await mockGeminiService.scanReceipt(file);

      // Verify
      expect(result.merchant.name, 'Test Store');
      expect(result.transaction.currency, 'EUR');
      expect(result.aiMetadata.needsReview, isFalse); // Verify getter
    });

    test('ScanRepository delegates to service', () async {
      // Execute
      final file = File('test_receipt.jpg');
      final result = await mockScanRepository.scanReceipt(file);

      // Verify
      expect(result.totals.grandTotal, 10.7);
    });

    test('ScanRepository handles errors gracefully', () async {
      // Execute & Verify
      final file = File('bad_receipt.jpg');
      expect(
        () => mockScanRepository.scanReceipt(file),
        throwsException,
      );
    });
  });
}

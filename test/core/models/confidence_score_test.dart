import 'package:flutter_test/flutter_test.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';

/// Property 5: Confidence Score Review Trigger
/// Validates: Requirements 1.7
///
/// Property: needsReview getter returns true if and only if confidenceScore < 0.8
/// This ensures users are prompted to verify receipts when AI confidence is low.

void main() {
  group('Property 5: Confidence Score Review Trigger', () {
    /// The confidence threshold for triggering review (defined in AiMetadata)
    const double reviewThreshold = 0.8;

    // Test: needsReview is true when confidence < 0.8
    test('needsReview is true when confidenceScore < 0.8', () {
      // Test various low confidence scores
      final lowConfidenceScores = [0.0, 0.1, 0.3, 0.5, 0.7, 0.79, 0.799];

      for (final score in lowConfidenceScores) {
        final metadata = AiMetadata(
          confidenceScore: score,
          modelUsed: 'gemini-1.5-flash',
          processingTimeMs: 1500,
        );

        expect(
          metadata.needsReview,
          isTrue,
          reason: 'needsReview should be true for confidence $score',
        );
      }
    });

    // Test: needsReview is false when confidence >= 0.8
    test('needsReview is false when confidenceScore >= 0.8', () {
      // Test various high confidence scores
      final highConfidenceScores = [0.8, 0.85, 0.9, 0.95, 0.99, 1.0];

      for (final score in highConfidenceScores) {
        final metadata = AiMetadata(
          confidenceScore: score,
          modelUsed: 'gemini-1.5-flash',
          processingTimeMs: 1200,
        );

        expect(
          metadata.needsReview,
          isFalse,
          reason: 'needsReview should be false for confidence $score',
        );
      }
    });

    // Edge case: Exactly at threshold (0.8)
    test('needsReview is false when confidenceScore is exactly 0.8', () {
      const metadata = AiMetadata(
        confidenceScore: 0.8,
        modelUsed: 'gemini-1.5-flash',
        processingTimeMs: 1000,
      );

      expect(metadata.needsReview, isFalse);
      expect(metadata.confidenceScore, 0.8);
    });

    // Edge case: Just below threshold
    test('needsReview is true when confidenceScore is just below 0.8', () {
      const metadata = AiMetadata(
        confidenceScore: 0.799999,
        modelUsed: 'gemini-1.5-flash',
        processingTimeMs: 1000,
      );

      expect(metadata.needsReview, isTrue);
    });

    // Test: ReviewNeededBanner visibility in VerificationScreen context
    test('review banner should show when needsReview is true in receipt data', () {
      final receiptWithLowConfidence = _createReceiptWithConfidence(0.5);
      final receiptWithHighConfidence = _createReceiptWithConfidence(0.9);

      expect(receiptWithLowConfidence.receiptData.aiMetadata.needsReview, isTrue);
      expect(receiptWithHighConfidence.receiptData.aiMetadata.needsReview, isFalse);
    });

    // Test: Full Receipt flow with confidence check
    test('full receipt shows correct needsReview based on AI confidence', () {
      // Simulate n8n response with low confidence
      final lowConfidenceReceipt = _createReceiptWithConfidence(0.65);
      expect(lowConfidenceReceipt.receiptData.aiMetadata.confidenceScore, 0.65);
      expect(lowConfidenceReceipt.receiptData.aiMetadata.needsReview, isTrue);

      // Simulate n8n response with high confidence
      final highConfidenceReceipt = _createReceiptWithConfidence(0.95);
      expect(highConfidenceReceipt.receiptData.aiMetadata.confidenceScore, 0.95);
      expect(highConfidenceReceipt.receiptData.aiMetadata.needsReview, isFalse);
    });

    // Property test: For any confidence score, needsReview = (confidence < 0.8)
    test('needsReview getter always equals (confidenceScore < 0.8)', () {
      // Test many scores across the range
      final testScores = [
        0.0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45,
        0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.79, 0.799, 0.8, 0.801,
        0.85, 0.9, 0.95, 0.99, 1.0,
      ];

      for (final score in testScores) {
        final expectedNeedsReview = score < reviewThreshold;
        final metadata = AiMetadata(
          confidenceScore: score,
          modelUsed: 'test-model',
          processingTimeMs: 100,
        );

        expect(
          metadata.needsReview,
          expectedNeedsReview,
          reason: 'For score $score, needsReview should be $expectedNeedsReview',
        );
      }
    });
  });
}

/// Helper to create a Receipt with a specific confidence score
Receipt _createReceiptWithConfidence(double confidenceScore) {
  return Receipt(
    receiptId: 'test_receipt',
    userId: 'test_user',
    householdId: 'test_household',
    imageUrl: 'https://example.com/receipt.jpg',
    isBookmarked: false,
    receiptData: ReceiptData(
      merchant: const Merchant(
        name: 'Test Store',
        address: 'Test Address',
      ),
      transaction: const Transaction(
        date: '2024-01-15',
        time: '14:30:00',
        currency: 'EUR',
        paymentMethod: 'CASH',
      ),
      items: const [
        LineItem(
          itemId: '1',
          description: 'Test Item',
          category: 'Groceries',
          quantity: 1,
          unitPrice: 1.99,
          totalPrice: 1.99,
          discount: null,
          isDiscounted: false,
          type: 'regular',
          tags: [],
        ),
      ],
      totals: const Totals(
        subtotal: 1.99,
        pfandTotal: 0.0,
        taxAmount: 0.14,
        grandTotal: 2.13,
      ),
      taxes: const [],
      aiMetadata: AiMetadata(
        confidenceScore: confidenceScore,
        modelUsed: 'gemini-1.5-flash',
        processingTimeMs: 1500,
      ),
    ),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

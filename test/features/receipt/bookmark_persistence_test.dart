import 'package:flutter_test/flutter_test.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';

/// Property 11: Bookmark Persistence
/// Validates: Requirements 4.5
///
/// Properties:
/// 1. Toggling bookmark changes isBookmarked state
/// 2. Double toggle returns to original state
/// 3. Bookmarked receipts appear in bookmarks filter
/// 4. Unbookmarked receipts do not appear in bookmarks filter

void main() {
  group('Property 11: Bookmark Persistence', () {
    /// Helper to create receipt with bookmark state
    Receipt createReceipt(String id, {bool isBookmarked = false}) {
      return Receipt(
        receiptId: id,
        userId: 'user_1',
        householdId: 'household_1',
        imageUrl: 'https://example.com/$id.jpg',
        isBookmarked: isBookmarked,
        receiptData: ReceiptData(
          merchant: const Merchant(name: 'Test Store'),
          transaction: const Transaction(
            date: '2024-12-25',
            time: '12:00:00',
            currency: 'EUR',
            paymentMethod: 'CARD',
          ),
          items: const [],
          totals: const Totals(
            subtotal: 10.0,
            pfandTotal: 0.0,
            taxAmount: 0.7,
            grandTotal: 10.7,
          ),
          taxes: const [],
          aiMetadata: const AiMetadata(
            confidenceScore: 0.95,
            modelUsed: 'gemini-1.5-flash',
          ),
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    /// Simulates toggling bookmark (like Firestore update)
    Receipt toggleBookmark(Receipt receipt) {
      return receipt.copyWith(isBookmarked: !receipt.isBookmarked);
    }

    /// Filter bookmarked receipts
    List<Receipt> getBookmarkedReceipts(List<Receipt> receipts) {
      return receipts.where((r) => r.isBookmarked).toList();
    }

    // Test: Toggle changes bookmark state (false -> true)
    test('toggling unbookmarked receipt sets isBookmarked to true', () {
      final receipt = createReceipt('1', isBookmarked: false);
      expect(receipt.isBookmarked, isFalse);

      final toggled = toggleBookmark(receipt);
      expect(toggled.isBookmarked, isTrue);
    });

    // Test: Toggle changes bookmark state (true -> false)
    test('toggling bookmarked receipt sets isBookmarked to false', () {
      final receipt = createReceipt('1', isBookmarked: true);
      expect(receipt.isBookmarked, isTrue);

      final toggled = toggleBookmark(receipt);
      expect(toggled.isBookmarked, isFalse);
    });

    // Test: Double toggle returns to original state
    test('double toggle returns to original state', () {
      final original = createReceipt('1', isBookmarked: false);
      final toggled = toggleBookmark(original);
      final doubleToggled = toggleBookmark(toggled);

      expect(doubleToggled.isBookmarked, original.isBookmarked);
    });

    // Test: Triple toggle changes state
    test('triple toggle changes state', () {
      final original = createReceipt('1', isBookmarked: false);
      var receipt = original;
      for (int i = 0; i < 3; i++) {
        receipt = toggleBookmark(receipt);
      }

      expect(receipt.isBookmarked, isTrue);
    });

    // Test: Bookmarked receipts appear in filter
    test('bookmarked receipts appear in bookmarks filter', () {
      final receipts = [
        createReceipt('1', isBookmarked: true),
        createReceipt('2', isBookmarked: false),
        createReceipt('3', isBookmarked: true),
      ];

      final bookmarked = getBookmarkedReceipts(receipts);

      expect(bookmarked.length, 2);
      expect(bookmarked.map((r) => r.receiptId).toSet(), {'1', '3'});
    });

    // Test: Unbookmarked receipts do not appear in filter
    test('unbookmarked receipts do not appear in bookmarks filter', () {
      final receipts = [
        createReceipt('1', isBookmarked: false),
        createReceipt('2', isBookmarked: false),
      ];

      final bookmarked = getBookmarkedReceipts(receipts);

      expect(bookmarked.isEmpty, isTrue);
    });

    // Test: All bookmarked receipts are in filter
    test('all bookmarked receipts appear in filter', () {
      final receipts = [
        createReceipt('1', isBookmarked: true),
        createReceipt('2', isBookmarked: true),
        createReceipt('3', isBookmarked: true),
      ];

      final bookmarked = getBookmarkedReceipts(receipts);

      expect(bookmarked.length, 3);
    });

    // Test: Toggle updates filter result
    test('toggling updates the bookmarks filter result', () {
      var receipts = [
        createReceipt('1', isBookmarked: false),
        createReceipt('2', isBookmarked: true),
      ];

      expect(getBookmarkedReceipts(receipts).length, 1);

      // Toggle first receipt
      receipts = [
        toggleBookmark(receipts[0]),
        receipts[1],
      ];

      expect(getBookmarkedReceipts(receipts).length, 2);

      // Toggle second receipt
      receipts = [
        receipts[0],
        toggleBookmark(receipts[1]),
      ];

      expect(getBookmarkedReceipts(receipts).length, 1);
    });

    // Test: Receipt ID preserved after toggle
    test('receipt ID is preserved after bookmark toggle', () {
      final original = createReceipt('unique_id_123', isBookmarked: false);
      final toggled = toggleBookmark(original);

      expect(toggled.receiptId, original.receiptId);
    });

    // Test: Other fields preserved after toggle
    test('other receipt fields are preserved after toggle', () {
      final original = createReceipt('1', isBookmarked: false);
      final toggled = toggleBookmark(original);

      expect(toggled.userId, original.userId);
      expect(toggled.householdId, original.householdId);
      expect(toggled.imageUrl, original.imageUrl);
      expect(
        toggled.receiptData.merchant.name,
        original.receiptData.merchant.name,
      );
      expect(
        toggled.receiptData.totals.grandTotal,
        original.receiptData.totals.grandTotal,
      );
    });

    // Property: isBookmarked is boolean (type safety)
    test('isBookmarked is always a boolean', () {
      final unbookmarked = createReceipt('1', isBookmarked: false);
      final bookmarked = createReceipt('2', isBookmarked: true);

      expect(unbookmarked.isBookmarked, isA<bool>());
      expect(bookmarked.isBookmarked, isA<bool>());
      expect(toggleBookmark(unbookmarked).isBookmarked, isA<bool>());
    });

    // Property: Bookmark filter is complete and sound
    test('bookmark filter is complete and sound', () {
      final receipts = [
        createReceipt('1', isBookmarked: true),
        createReceipt('2', isBookmarked: false),
        createReceipt('3', isBookmarked: true),
        createReceipt('4', isBookmarked: false),
        createReceipt('5', isBookmarked: true),
      ];

      final bookmarked = getBookmarkedReceipts(receipts);
      final bookmarkedIds = bookmarked.map((r) => r.receiptId).toSet();

      // Completeness: all bookmarked receipts are returned
      for (final receipt in receipts) {
        if (receipt.isBookmarked) {
          expect(
            bookmarkedIds.contains(receipt.receiptId),
            isTrue,
            reason: 'Bookmarked receipt ${receipt.receiptId} should be in filter',
          );
        }
      }

      // Soundness: no unbookmarked receipts are returned
      for (final receipt in bookmarked) {
        expect(
          receipt.isBookmarked,
          isTrue,
          reason: 'Receipt ${receipt.receiptId} in filter should be bookmarked',
        );
      }
    });
  });
}

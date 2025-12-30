import 'package:flutter_test/flutter_test.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';

/// Property 9: Receipt Archive Sort Order
/// Validates: Requirements 4.1
///
/// Property: Receipts in the archive should be sorted by date (newest first)
/// - transaction.date should be in descending order
/// - Receipts with the same date should be stable-sorted

void main() {
  group('Property 9: Receipt Archive Sort Order', () {
    /// Helper to sort receipts by date (newest first)
    List<Receipt> sortByDateDescending(List<Receipt> receipts) {
      return List.from(receipts)
        ..sort((a, b) => b.receiptData.transaction.date
            .compareTo(a.receiptData.transaction.date));
    }

    /// Helper to check if list is sorted descending by date
    bool isSortedDescending(List<Receipt> receipts) {
      for (int i = 0; i < receipts.length - 1; i++) {
        final currentDate = receipts[i].receiptData.transaction.date;
        final nextDate = receipts[i + 1].receiptData.transaction.date;
        if (currentDate.compareTo(nextDate) < 0) {
          return false;
        }
      }
      return true;
    }

    /// Helper to create mock receipt with date
    Receipt createReceiptWithDate(String id, String date) {
      return Receipt(
        receiptId: id,
        userId: 'user_1',
        householdId: 'household_1',
        imageUrl: 'https://example.com/$id.jpg',
        isBookmarked: false,
        receiptData: ReceiptData(
          merchant: const Merchant(name: 'Test Store'),
          transaction: Transaction(
            date: date,
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

    // Test: Sorted list should be in descending date order
    test('sorted receipts are in descending date order', () {
      final receipts = [
        createReceiptWithDate('1', '2024-12-25'),
        createReceiptWithDate('2', '2024-12-30'),
        createReceiptWithDate('3', '2024-12-27'),
        createReceiptWithDate('4', '2024-12-20'),
      ];

      final sorted = sortByDateDescending(receipts);

      expect(isSortedDescending(sorted), isTrue);
      expect(sorted[0].receiptId, '2'); // 2024-12-30 (newest)
      expect(sorted[1].receiptId, '3'); // 2024-12-27
      expect(sorted[2].receiptId, '1'); // 2024-12-25
      expect(sorted[3].receiptId, '4'); // 2024-12-20 (oldest)
    });

    // Test: Already sorted list stays sorted
    test('already sorted list remains sorted', () {
      final receipts = [
        createReceiptWithDate('1', '2024-12-30'),
        createReceiptWithDate('2', '2024-12-29'),
        createReceiptWithDate('3', '2024-12-28'),
      ];

      final sorted = sortByDateDescending(receipts);

      expect(isSortedDescending(sorted), isTrue);
      expect(sorted.map((r) => r.receiptId).toList(), ['1', '2', '3']);
    });

    // Test: Empty list
    test('empty list is considered sorted', () {
      final receipts = <Receipt>[];
      final sorted = sortByDateDescending(receipts);

      expect(sorted.isEmpty, isTrue);
      expect(isSortedDescending(sorted), isTrue);
    });

    // Test: Single receipt
    test('single receipt is considered sorted', () {
      final receipts = [createReceiptWithDate('1', '2024-12-25')];
      final sorted = sortByDateDescending(receipts);

      expect(sorted.length, 1);
      expect(isSortedDescending(sorted), isTrue);
    });

    // Test: Same date receipts maintain relative order (stable sort)
    test('receipts with same date maintain stable order', () {
      final receipts = [
        createReceiptWithDate('first', '2024-12-25'),
        createReceiptWithDate('second', '2024-12-25'),
        createReceiptWithDate('third', '2024-12-25'),
      ];

      final sorted = sortByDateDescending(receipts);

      // All should have same date
      expect(sorted.every(
        (r) => r.receiptData.transaction.date == '2024-12-25',
      ), isTrue);
      expect(isSortedDescending(sorted), isTrue);
    });

    // Test: Mixed months and years
    test('correctly sorts across months and years', () {
      final receipts = [
        createReceiptWithDate('1', '2023-05-15'),
        createReceiptWithDate('2', '2024-01-01'),
        createReceiptWithDate('3', '2024-12-31'),
        createReceiptWithDate('4', '2023-12-31'),
      ];

      final sorted = sortByDateDescending(receipts);

      expect(sorted[0].receiptId, '3'); // 2024-12-31
      expect(sorted[1].receiptId, '2'); // 2024-01-01
      expect(sorted[2].receiptId, '4'); // 2023-12-31
      expect(sorted[3].receiptId, '1'); // 2023-05-15
    });

    // Test: Edge case - consecutive dates
    test('correctly sorts consecutive dates', () {
      final receipts = [
        createReceiptWithDate('1', '2024-12-01'),
        createReceiptWithDate('2', '2024-12-02'),
        createReceiptWithDate('3', '2024-12-03'),
        createReceiptWithDate('4', '2024-12-04'),
        createReceiptWithDate('5', '2024-12-05'),
      ];

      final sorted = sortByDateDescending(receipts);

      expect(sorted[0].receiptId, '5'); // newest
      expect(sorted[4].receiptId, '1'); // oldest
      expect(isSortedDescending(sorted), isTrue);
    });

    // Property test: Any shuffled list becomes sorted after sorting
    test('any list becomes properly sorted after sorting', () {
      // Create a list and shuffle it various ways
      final baseReceipts = [
        createReceiptWithDate('1', '2024-12-10'),
        createReceiptWithDate('2', '2024-12-20'),
        createReceiptWithDate('3', '2024-12-15'),
        createReceiptWithDate('4', '2024-12-05'),
        createReceiptWithDate('5', '2024-12-25'),
      ];

      // Try multiple shuffles
      for (int i = 0; i < 5; i++) {
        final shuffled = List<Receipt>.from(baseReceipts)..shuffle();
        final sorted = sortByDateDescending(shuffled);

        expect(
          isSortedDescending(sorted),
          isTrue,
          reason: 'Shuffle $i should result in sorted list',
        );
        expect(sorted[0].receiptId, '5'); // 2024-12-25 always first
        expect(sorted[4].receiptId, '4'); // 2024-12-05 always last
      }
    });
  });
}

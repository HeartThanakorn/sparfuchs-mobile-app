import 'package:flutter_test/flutter_test.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';

/// Property 10: Search Filter Accuracy
/// Validates: Requirements 4.3
///
/// Property: Search should find receipts where:
/// - merchant.name contains query (case insensitive), OR
/// - any item.description contains query (case insensitive)

void main() {
  group('Property 10: Search Filter Accuracy', () {
    /// Search filter implementation (same logic as ReceiptSearchDelegate)
    List<Receipt> filterReceipts(List<Receipt> receipts, String query) {
      final lowerQuery = query.toLowerCase().trim();
      if (lowerQuery.isEmpty) return receipts;

      return receipts.where((receipt) {
        // Check merchant name
        final merchantName = receipt.receiptData.merchant.name.toLowerCase();
        if (merchantName.contains(lowerQuery)) return true;

        // Check item descriptions
        for (final item in receipt.receiptData.items) {
          if (item.description.toLowerCase().contains(lowerQuery)) {
            return true;
          }
        }

        return false;
      }).toList();
    }

    /// Helper to create receipt with merchant and items
    Receipt createReceipt(String id, String merchant, List<String> items) {
      return Receipt(
        receiptId: id,
        userId: 'user_1',
        householdId: 'household_1',
        imageUrl: 'https://example.com/$id.jpg',
        isBookmarked: false,
        receiptData: ReceiptData(
          merchant: Merchant(name: merchant),
          transaction: const Transaction(
            date: '2024-12-25',
            time: '12:00:00',
            currency: 'EUR',
            paymentMethod: 'CARD',
          ),
          items: items
              .asMap()
              .entries
              .map((e) => LineItem(
                    itemId: '${id}_${e.key}',
                    description: e.value,
                    category: 'Groceries',
                    quantity: 1,
                    unitPrice: 1.99,
                    totalPrice: 1.99,
                    discount: null,
                    isDiscounted: false,
                    type: 'regular',
                    tags: const [],
                  ))
              .toList(),
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

    // Test data
    late List<Receipt> testReceipts;

    setUp(() {
      testReceipts = [
        createReceipt('1', 'REWE', ['Milch', 'Brot', 'Butter']),
        createReceipt('2', 'Aldi Süd', ['Cola', 'Chips', 'Schokolade']),
        createReceipt('3', 'Lidl', ['Äpfel', 'Bananen', 'Milch']),
        createReceipt('4', 'Edeka', ['Käse', 'Wurst', 'Brötchen']),
      ];
    });

    // Test: Search by merchant name
    test('finds receipt by merchant name', () {
      final results = filterReceipts(testReceipts, 'REWE');
      expect(results.length, 1);
      expect(results[0].receiptId, '1');
    });

    // Test: Search by partial merchant name
    test('finds receipt by partial merchant name', () {
      final results = filterReceipts(testReceipts, 'Aldi');
      expect(results.length, 1);
      expect(results[0].receiptId, '2');
    });

    // Test: Search by item description
    test('finds receipt by item description', () {
      final results = filterReceipts(testReceipts, 'Cola');
      expect(results.length, 1);
      expect(results[0].receiptId, '2');
    });

    // Test: Search finds multiple receipts with same item
    test('finds multiple receipts with same item', () {
      final results = filterReceipts(testReceipts, 'Milch');
      expect(results.length, 2);
      expect(results.map((r) => r.receiptId).toSet(), {'1', '3'});
    });

    // Test: Case insensitive merchant search
    test('search is case insensitive for merchant', () {
      final upperResult = filterReceipts(testReceipts, 'REWE');
      final lowerResult = filterReceipts(testReceipts, 'rewe');
      final mixedResult = filterReceipts(testReceipts, 'ReWe');

      expect(upperResult.length, 1);
      expect(lowerResult.length, 1);
      expect(mixedResult.length, 1);
      expect(upperResult[0].receiptId, lowerResult[0].receiptId);
      expect(lowerResult[0].receiptId, mixedResult[0].receiptId);
    });

    // Test: Case insensitive item search
    test('search is case insensitive for items', () {
      final upperResult = filterReceipts(testReceipts, 'MILCH');
      final lowerResult = filterReceipts(testReceipts, 'milch');

      expect(upperResult.length, lowerResult.length);
    });

    // Test: Empty query returns all receipts
    test('empty query returns all receipts', () {
      final results = filterReceipts(testReceipts, '');
      expect(results.length, testReceipts.length);
    });

    // Test: Whitespace-only query returns all receipts
    test('whitespace-only query returns all receipts', () {
      final results = filterReceipts(testReceipts, '   ');
      expect(results.length, testReceipts.length);
    });

    // Test: No match returns empty list
    test('no match returns empty list', () {
      final results = filterReceipts(testReceipts, 'XYZ123');
      expect(results.isEmpty, isTrue);
    });

    // Test: Partial item match
    test('finds receipt by partial item match', () {
      final results = filterReceipts(testReceipts, 'Schoko');
      expect(results.length, 1);
      expect(results[0].receiptId, '2');
    });

    // Test: German umlauts work correctly
    test('German umlauts are handled correctly', () {
      final results = filterReceipts(testReceipts, 'Äpfel');
      expect(results.length, 1);
      expect(results[0].receiptId, '3');
    });

    // Property: All returned receipts actually match the query
    test('all returned receipts contain query in merchant or items', () {
      final query = 'Milch';
      final results = filterReceipts(testReceipts, query);

      for (final receipt in results) {
        final merchantMatches = receipt.receiptData.merchant.name
            .toLowerCase()
            .contains(query.toLowerCase());
        final itemMatches = receipt.receiptData.items.any((item) =>
            item.description.toLowerCase().contains(query.toLowerCase()));

        expect(
          merchantMatches || itemMatches,
          isTrue,
          reason: 'Receipt ${receipt.receiptId} should match query "$query"',
        );
      }
    });

    // Property: No excluded receipts would have matched
    test('no excluded receipts would have matched the query', () {
      final query = 'Chips';
      final results = filterReceipts(testReceipts, query);
      final excludedIds =
          testReceipts.map((r) => r.receiptId).toSet().difference(
                results.map((r) => r.receiptId).toSet(),
              );

      for (final id in excludedIds) {
        final receipt = testReceipts.firstWhere((r) => r.receiptId == id);
        final merchantMatches = receipt.receiptData.merchant.name
            .toLowerCase()
            .contains(query.toLowerCase());
        final itemMatches = receipt.receiptData.items.any((item) =>
            item.description.toLowerCase().contains(query.toLowerCase()));

        expect(
          merchantMatches || itemMatches,
          isFalse,
          reason: 'Excluded receipt $id should NOT match query "$query"',
        );
      }
    });
  });
}

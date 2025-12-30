import 'package:flutter_test/flutter_test.dart';

/// Property 14: Household Receipt Sync
/// Validates: Requirements 5.3
///
/// Properties:
/// 1. Only receipts with matching householdId are included
/// 2. Receipts are sorted by date descending
/// 3. Receipts from all household members are included
/// 4. Filtering excludes non-household receipts completely

/// Mock receipt for testing
class MockReceipt {
  final String id;
  final String householdId;
  final String userId;
  final DateTime createdAt;

  MockReceipt(this.id, this.householdId, this.userId, this.createdAt);
}

/// Filter receipts by household ID
List<MockReceipt> filterByHousehold(
    List<MockReceipt> receipts, String householdId) {
  return receipts.where((r) => r.householdId == householdId).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}

void main() {
  group('Property 14: Household Receipt Sync', () {
    // Test: Only matching householdId included
    test('only receipts with matching householdId are included', () {
      final receipts = [
        MockReceipt('r1', 'h1', 'u1', DateTime.now()),
        MockReceipt('r2', 'h1', 'u2', DateTime.now()),
        MockReceipt('r3', 'h2', 'u3', DateTime.now()),
        MockReceipt('r4', 'h1', 'u1', DateTime.now()),
      ];

      final synced = filterByHousehold(receipts, 'h1');

      expect(synced.length, 3);
      expect(synced.every((r) => r.householdId == 'h1'), isTrue);
    });

    // Test: Sorted by date descending
    test('receipts are sorted by date descending', () {
      final now = DateTime.now();
      final receipts = [
        MockReceipt('r1', 'h1', 'u1', now.subtract(const Duration(days: 5))),
        MockReceipt('r2', 'h1', 'u1', now),
        MockReceipt('r3', 'h1', 'u1', now.subtract(const Duration(days: 2))),
      ];

      final synced = filterByHousehold(receipts, 'h1');

      expect(synced[0].id, 'r2');
      expect(synced[1].id, 'r3');
      expect(synced[2].id, 'r1');
    });

    // Test: All members' receipts included
    test('receipts from all household members are included', () {
      final receipts = [
        MockReceipt('r1', 'h1', 'user_A', DateTime.now()),
        MockReceipt('r2', 'h1', 'user_B', DateTime.now()),
        MockReceipt('r3', 'h1', 'user_C', DateTime.now()),
        MockReceipt('r4', 'h2', 'user_D', DateTime.now()),
      ];

      final synced = filterByHousehold(receipts, 'h1');
      final userIds = synced.map((r) => r.userId).toSet();

      expect(userIds, containsAll(['user_A', 'user_B', 'user_C']));
      expect(userIds.contains('user_D'), isFalse);
    });

    // Test: Non-household receipts excluded
    test('non-household receipts are completely excluded', () {
      final receipts = [
        MockReceipt('r1', 'h1', 'u1', DateTime.now()),
        MockReceipt('r2', 'h2', 'u2', DateTime.now()),
        MockReceipt('r3', 'h3', 'u3', DateTime.now()),
      ];

      final synced = filterByHousehold(receipts, 'h1');

      expect(synced.length, 1);
      expect(synced.any((r) => r.householdId == 'h2'), isFalse);
    });

    // Test: Empty for non-existent household
    test('empty result for non-existent household', () {
      final receipts = [
        MockReceipt('r1', 'h1', 'u1', DateTime.now()),
        MockReceipt('r2', 'h2', 'u2', DateTime.now()),
      ];

      final synced = filterByHousehold(receipts, 'h_nonexistent');

      expect(synced.isEmpty, isTrue);
    });

    // Test: Handles empty list
    test('handles empty receipt list gracefully', () {
      final receipts = <MockReceipt>[];
      final synced = filterByHousehold(receipts, 'h1');

      expect(synced.isEmpty, isTrue);
    });

    // Test: Empty householdId excluded
    test('receipts with empty householdId are excluded', () {
      final receipts = [
        MockReceipt('r1', 'h1', 'u1', DateTime.now()),
        MockReceipt('r2', '', 'u2', DateTime.now()),
        MockReceipt('r3', 'h1', 'u3', DateTime.now()),
      ];

      final synced = filterByHousehold(receipts, 'h1');

      expect(synced.length, 2);
      expect(synced.every((r) => r.householdId == 'h1'), isTrue);
    });
  });
}

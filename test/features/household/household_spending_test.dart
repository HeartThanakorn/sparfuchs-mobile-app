import 'package:flutter_test/flutter_test.dart';

/// Property 15: Household Spending Aggregation
/// Validates: Requirements 5.5
///
/// Properties:
/// 1. Total spending equals sum of all grandTotals
/// 2. Category spending sums correctly
/// 3. Member spending sums correctly
/// 4. Time period filtering works correctly

/// Mock receipt for testing
class MockReceipt {
  final String id;
  final String userId;
  final double grandTotal;
  final Map<String, double> categorySpending;
  final DateTime createdAt;

  MockReceipt({
    required this.id,
    required this.userId,
    required this.grandTotal,
    required this.categorySpending,
    required this.createdAt,
  });
}

/// Spending summary result
class SpendingSummary {
  final double total;
  final Map<String, double> byCategory;
  final Map<String, double> byMember;

  SpendingSummary({
    required this.total,
    required this.byCategory,
    required this.byMember,
  });
}

/// Calculate spending summary from receipts
SpendingSummary calculateSpending(List<MockReceipt> receipts) {
  double total = 0;
  final byCategory = <String, double>{};
  final byMember = <String, double>{};

  for (final receipt in receipts) {
    total += receipt.grandTotal;

    // Aggregate by member
    byMember.update(
      receipt.userId,
      (v) => v + receipt.grandTotal,
      ifAbsent: () => receipt.grandTotal,
    );

    // Aggregate by category
    for (final entry in receipt.categorySpending.entries) {
      byCategory.update(
        entry.key,
        (v) => v + entry.value,
        ifAbsent: () => entry.value,
      );
    }
  }

  return SpendingSummary(total: total, byCategory: byCategory, byMember: byMember);
}

/// Filter receipts by time period
List<MockReceipt> filterByPeriod(
    List<MockReceipt> receipts, DateTime startDate) {
  return receipts.where((r) => r.createdAt.isAfter(startDate)).toList();
}

void main() {
  group('Property 15: Household Spending Aggregation', () {
    // Test: Total equals sum of grandTotals
    test('total spending equals sum of all grandTotals', () {
      final receipts = [
        MockReceipt(
          id: 'r1',
          userId: 'u1',
          grandTotal: 50.0,
          categorySpending: {'groceries': 50.0},
          createdAt: DateTime.now(),
        ),
        MockReceipt(
          id: 'r2',
          userId: 'u2',
          grandTotal: 30.0,
          categorySpending: {'groceries': 30.0},
          createdAt: DateTime.now(),
        ),
        MockReceipt(
          id: 'r3',
          userId: 'u1',
          grandTotal: 20.0,
          categorySpending: {'household': 20.0},
          createdAt: DateTime.now(),
        ),
      ];

      final summary = calculateSpending(receipts);

      expect(summary.total, 100.0);
    });

    // Test: Category sums correctly
    test('category spending sums correctly', () {
      final receipts = [
        MockReceipt(
          id: 'r1',
          userId: 'u1',
          grandTotal: 100.0,
          categorySpending: {'groceries': 60.0, 'household': 40.0},
          createdAt: DateTime.now(),
        ),
        MockReceipt(
          id: 'r2',
          userId: 'u2',
          grandTotal: 50.0,
          categorySpending: {'groceries': 50.0},
          createdAt: DateTime.now(),
        ),
      ];

      final summary = calculateSpending(receipts);

      expect(summary.byCategory['groceries'], 110.0);
      expect(summary.byCategory['household'], 40.0);
    });

    // Test: Member sums correctly
    test('member spending sums correctly', () {
      final receipts = [
        MockReceipt(
          id: 'r1',
          userId: 'alice',
          grandTotal: 75.0,
          categorySpending: {},
          createdAt: DateTime.now(),
        ),
        MockReceipt(
          id: 'r2',
          userId: 'bob',
          grandTotal: 50.0,
          categorySpending: {},
          createdAt: DateTime.now(),
        ),
        MockReceipt(
          id: 'r3',
          userId: 'alice',
          grandTotal: 25.0,
          categorySpending: {},
          createdAt: DateTime.now(),
        ),
      ];

      final summary = calculateSpending(receipts);

      expect(summary.byMember['alice'], 100.0);
      expect(summary.byMember['bob'], 50.0);
    });

    // Test: Time period filtering
    test('time period filtering works correctly', () {
      final now = DateTime.now();
      final receipts = [
        MockReceipt(
          id: 'r1',
          userId: 'u1',
          grandTotal: 50.0,
          categorySpending: {},
          createdAt: now.subtract(const Duration(days: 5)),
        ),
        MockReceipt(
          id: 'r2',
          userId: 'u1',
          grandTotal: 30.0,
          categorySpending: {},
          createdAt: now.subtract(const Duration(days: 15)),
        ),
        MockReceipt(
          id: 'r3',
          userId: 'u1',
          grandTotal: 20.0,
          categorySpending: {},
          createdAt: now.subtract(const Duration(days: 45)),
        ),
      ];

      // Last 7 days
      final week = filterByPeriod(receipts, now.subtract(const Duration(days: 7)));
      expect(calculateSpending(week).total, 50.0);

      // Last 30 days
      final month = filterByPeriod(receipts, now.subtract(const Duration(days: 30)));
      expect(calculateSpending(month).total, 80.0);

      // All time
      expect(calculateSpending(receipts).total, 100.0);
    });

    // Test: Empty list
    test('empty receipt list produces zero totals', () {
      final summary = calculateSpending([]);

      expect(summary.total, 0.0);
      expect(summary.byCategory.isEmpty, isTrue);
      expect(summary.byMember.isEmpty, isTrue);
    });

    // Test: Single receipt
    test('single receipt aggregates correctly', () {
      final receipts = [
        MockReceipt(
          id: 'r1',
          userId: 'bob',
          grandTotal: 42.50,
          categorySpending: {'snacks': 42.50},
          createdAt: DateTime.now(),
        ),
      ];

      final summary = calculateSpending(receipts);

      expect(summary.total, 42.50);
      expect(summary.byMember['bob'], 42.50);
      expect(summary.byCategory['snacks'], 42.50);
    });
  });
}

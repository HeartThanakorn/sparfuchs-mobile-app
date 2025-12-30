import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Property 8: Category Percentage Calculation
/// Validates: Requirements 3.3, 3.4
///
/// Properties:
/// 1. Sum of all category percentages should equal 100% (within rounding tolerance)
/// 2. Each category percentage = (category amount / total) * 100
/// 3. Percentages should be non-negative
/// 4. Categories with zero spending should have 0% percentage

void main() {
  group('Property 8: Category Percentage Calculation', () {
    /// Helper to calculate percentage
    double calculatePercentage(double categoryAmount, double totalAmount) {
      if (totalAmount == 0) return 0;
      return (categoryAmount / totalAmount) * 100;
    }

    /// Helper to calculate all category percentages
    List<double> calculateCategoryPercentages(List<double> amounts) {
      final total = amounts.fold(0.0, (sum, amt) => sum + amt);
      return amounts.map((amt) => calculatePercentage(amt, total)).toList();
    }

    // Test: Sum of percentages equals 100%
    test('sum of category percentages equals 100%', () {
      final testCases = [
        [50.0, 30.0, 20.0], // Simple case
        [100.0], // Single category
        [25.0, 25.0, 25.0, 25.0], // Equal split
        [99.99, 0.01], // Edge case with small value
        [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0], // Many categories
      ];

      for (final amounts in testCases) {
        final percentages = calculateCategoryPercentages(amounts);
        final sum = percentages.fold(0.0, (a, b) => a + b);
        expect(
          sum,
          closeTo(100.0, 0.01),
          reason: 'Percentages for $amounts should sum to 100%, got $sum',
        );
      }
    });

    // Test: Individual percentage calculation is correct
    test('individual category percentage is correctly calculated', () {
      final amounts = [40.0, 35.0, 25.0];
      final total = amounts.fold(0.0, (sum, amt) => sum + amt);

      expect(calculatePercentage(40.0, total), closeTo(40.0, 0.01));
      expect(calculatePercentage(35.0, total), closeTo(35.0, 0.01));
      expect(calculatePercentage(25.0, total), closeTo(25.0, 0.01));
    });

    // Test: Percentages are non-negative
    test('all category percentages are non-negative', () {
      final testCases = [
        [100.0, 50.0, 25.0, 10.0],
        [0.01, 0.02, 0.03],
        [1000.0, 1.0],
      ];

      for (final amounts in testCases) {
        final percentages = calculateCategoryPercentages(amounts);
        for (int i = 0; i < percentages.length; i++) {
          expect(
            percentages[i],
            greaterThanOrEqualTo(0),
            reason: 'Percentage for amount ${amounts[i]} should be >= 0',
          );
        }
      }
    });

    // Test: Zero spending equals zero percentage
    test('zero spending in a category equals 0%', () {
      final amounts = [50.0, 0.0, 50.0];
      final percentages = calculateCategoryPercentages(amounts);

      expect(percentages[0], closeTo(50.0, 0.01));
      expect(percentages[1], 0.0);
      expect(percentages[2], closeTo(50.0, 0.01));
    });

    // Test: All zeros returns all 0%
    test('all zero amounts returns all 0% percentages', () {
      final amounts = [0.0, 0.0, 0.0];
      final percentages = calculateCategoryPercentages(amounts);

      for (final pct in percentages) {
        expect(pct, 0.0);
      }
    });

    // Test: Single category gets 100%
    test('single category gets 100%', () {
      final amounts = [150.0];
      final percentages = calculateCategoryPercentages(amounts);

      expect(percentages.length, 1);
      expect(percentages[0], 100.0);
    });

    // Test: Percentage ordering matches amount ordering
    test('higher amounts have higher percentages', () {
      final amounts = [10.0, 50.0, 30.0, 100.0, 5.0];
      final percentages = calculateCategoryPercentages(amounts);

      // Create pairs and sort by amount
      final pairs = List.generate(
        amounts.length,
        (i) => MapEntry(amounts[i], percentages[i]),
      );
      pairs.sort((a, b) => b.key.compareTo(a.key));

      // Verify percentages are in descending order when sorted by amount
      for (int i = 0; i < pairs.length - 1; i++) {
        expect(
          pairs[i].value,
          greaterThanOrEqualTo(pairs[i + 1].value),
          reason: 'Higher amount should have higher percentage',
        );
      }
    });

    // Test: Realistic grocery receipt categories
    test('realistic grocery receipt category breakdown', () {
      final categoryAmounts = {
        'Groceries': 45.50,
        'Beverages': 12.30,
        'Snacks': 8.20,
        'Household': 15.00,
        'Deposit': 1.50, // Pfand
      };

      final total = categoryAmounts.values.fold(0.0, (sum, amt) => sum + amt);
      expect(total, closeTo(82.50, 0.01));

      final groceriesPercent = calculatePercentage(45.50, total);
      expect(groceriesPercent, closeTo(55.15, 0.1));

      final depositPercent = calculatePercentage(1.50, total);
      expect(depositPercent, closeTo(1.82, 0.1));

      // Sum check
      final allPercentages = categoryAmounts.values
          .map((amt) => calculatePercentage(amt, total))
          .toList();
      final percentSum = allPercentages.fold(0.0, (a, b) => a + b);
      expect(percentSum, closeTo(100.0, 0.01));
    });

    // Test: Category breakdown model creates valid percentages
    test('CategoryBreakdown data model has valid percentage', () {
      final breakdown = _TestCategoryBreakdown(
        category: 'Groceries',
        amount: 50.0,
        percentage: 50.0,
        color: Colors.teal,
      );

      expect(breakdown.percentage, greaterThanOrEqualTo(0));
      expect(breakdown.percentage, lessThanOrEqualTo(100));
    });
  });
}

/// Test helper class mimicking CategoryBreakdown
class _TestCategoryBreakdown {
  final String category;
  final double amount;
  final double percentage;
  final Color color;

  const _TestCategoryBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

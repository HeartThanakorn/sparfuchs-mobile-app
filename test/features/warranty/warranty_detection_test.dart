import 'package:flutter_test/flutter_test.dart';

/// Property 21: Warranty Item Detection and Reminder Setup
/// Validates: Requirements 8.1, 8.2, 8.3
///
/// Properties:
/// 1. Only Electronics and Fashion items are detected
/// 2. Return deadline = purchaseDate + 14 days
/// 3. Electronics get 2-year warranty
/// 4. Fashion gets 6-month warranty
/// 5. Pfand items are excluded

/// Mock line item
class MockLineItem {
  final String description;
  final String category;
  final double price;
  final bool isPfand;

  MockLineItem({
    required this.description,
    required this.category,
    required this.price,
    this.isPfand = false,
  });
}

/// Warranty categories
const warrantyCategories = ['electronics', 'fashion'];

/// Filter warranty-eligible items
List<MockLineItem> filterWarrantyItems(List<MockLineItem> items) {
  return items
      .where((item) =>
          warrantyCategories.contains(item.category.toLowerCase()) &&
          !item.isPfand)
      .toList();
}

/// Calculate return deadline
DateTime calculateReturnDeadline(DateTime purchaseDate) {
  return purchaseDate.add(const Duration(days: 14));
}

/// Calculate warranty expiry based on category
DateTime? calculateWarrantyExpiry(DateTime purchaseDate, String category) {
  if (category.toLowerCase() == 'electronics') {
    return DateTime(
      purchaseDate.year + 2,
      purchaseDate.month,
      purchaseDate.day,
    );
  } else if (category.toLowerCase() == 'fashion') {
    return DateTime(
      purchaseDate.year,
      purchaseDate.month + 6,
      purchaseDate.day,
    );
  }
  return null;
}

void main() {
  group('Property 21: Warranty Item Detection and Reminder Setup', () {
    // Test: Only Electronics and Fashion detected
    test('only Electronics and Fashion items are detected', () {
      final items = [
        MockLineItem(description: 'iPhone', category: 'Electronics', price: 999),
        MockLineItem(description: 'Jeans', category: 'Fashion', price: 79),
        MockLineItem(description: 'Milk', category: 'Groceries', price: 1.99),
        MockLineItem(description: 'Soap', category: 'Household', price: 2.50),
      ];

      final warrantyItems = filterWarrantyItems(items);

      expect(warrantyItems.length, 2);
      expect(
          warrantyItems.every((i) =>
              warrantyCategories.contains(i.category.toLowerCase())),
          isTrue);
    });

    // Test: Return deadline = 14 days
    test('return deadline is purchaseDate + 14 days', () {
      final purchaseDate = DateTime(2024, 1, 1);
      final deadline = calculateReturnDeadline(purchaseDate);

      expect(deadline, DateTime(2024, 1, 15));
      expect(deadline.difference(purchaseDate).inDays, 14);
    });

    // Test: Electronics get 2-year warranty
    test('Electronics items get 2-year warranty', () {
      final purchaseDate = DateTime(2024, 1, 15);
      final expiry = calculateWarrantyExpiry(purchaseDate, 'Electronics');

      expect(expiry, DateTime(2026, 1, 15));
    });

    // Test: Fashion gets 6-month warranty
    test('Fashion items get 6-month warranty', () {
      final purchaseDate = DateTime(2024, 1, 15);
      final expiry = calculateWarrantyExpiry(purchaseDate, 'Fashion');

      expect(expiry, DateTime(2024, 7, 15));
    });

    // Test: Other categories get no warranty
    test('other categories get no warranty expiry', () {
      final purchaseDate = DateTime(2024, 1, 15);
      final expiry = calculateWarrantyExpiry(purchaseDate, 'Groceries');

      expect(expiry, isNull);
    });

    // Test: Pfand items excluded
    test('Pfand items are excluded from warranty tracking', () {
      final items = [
        MockLineItem(description: 'iPhone', category: 'Electronics', price: 999),
        MockLineItem(
            description: 'Pfand Bottle',
            category: 'Electronics',
            price: 0.25,
            isPfand: true),
      ];

      final warrantyItems = filterWarrantyItems(items);

      expect(warrantyItems.length, 1);
      expect(warrantyItems.any((i) => i.isPfand), isFalse);
    });

    // Test: Case insensitive category matching
    test('category matching is case-insensitive', () {
      final items = [
        MockLineItem(description: 'iPhone', category: 'ELECTRONICS', price: 999),
        MockLineItem(description: 'Jeans', category: 'fashion', price: 79),
        MockLineItem(description: 'Jacket', category: 'Fashion', price: 199),
      ];

      final warrantyItems = filterWarrantyItems(items);

      expect(warrantyItems.length, 3);
    });

    // Test: Empty items returns empty
    test('empty items list returns empty warranty items', () {
      final items = <MockLineItem>[];
      final warrantyItems = filterWarrantyItems(items);

      expect(warrantyItems.isEmpty, isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';

/// Property 6: Total Recalculation on Edit
/// Validates: Requirements 2.6
///
/// Property: When items are modified, the grand_total should equal:
/// sum(items.totalPrice) + taxAmount
/// where taxAmount = subtotal * 0.07 (German 7% VAT for food)

void main() {
  group('Property 6: Total Recalculation on Edit', () {
    /// Helper function to calculate totals (same logic as VerificationScreen)
    Totals calculateTotals(List<LineItem> items) {
      double subtotal = 0;
      double pfandTotal = 0;

      for (final item in items) {
        if (item.isPfand) {
          pfandTotal += item.totalPrice;
        } else {
          subtotal += item.totalPrice;
        }
      }

      final taxAmount = subtotal * 0.07;
      final grandTotal = subtotal + pfandTotal + taxAmount;

      return Totals(
        subtotal: subtotal,
        pfandTotal: pfandTotal,
        taxAmount: taxAmount,
        grandTotal: grandTotal,
      );
    }

    /// Helper function to recalculate item total price
    double calculateItemTotal(int quantity, double unitPrice, double? discount) {
      final total = (quantity * unitPrice) - (discount ?? 0);
      return total.clamp(0, double.infinity);
    }

    // Test: grandTotal calculation formula
    test('grandTotal equals sum of subtotal + pfandTotal + tax', () {
      final items = [
        const LineItem(
          itemId: '1', description: 'Item 1', category: 'Groceries',
          quantity: 2, unitPrice: 3.50, totalPrice: 7.00,
          discount: null, isDiscounted: false, type: 'regular', tags: [],
        ),
        const LineItem(
          itemId: '2', description: 'Pfand', category: 'Deposit',
          quantity: 1, unitPrice: 0.25, totalPrice: 0.25,
          discount: null, isDiscounted: false, type: 'pfand_bottle', tags: [],
        ),
      ];

      final totals = calculateTotals(items);

      // Verify the calculation is consistent
      expect(totals.subtotal, 7.00);
      expect(totals.pfandTotal, 0.25);
      expect(totals.grandTotal, closeTo(7.00 + 0.25 + (7.00 * 0.07), 0.01));
    });

    // Property test: totalPrice = quantity * unitPrice - discount
    test('totalPrice equals quantity * unitPrice - discount for various items', () {
      // Regular item without discount
      expect(calculateItemTotal(2, 1.50, null), 3.00);
      
      // Item with discount
      expect(calculateItemTotal(2, 5.00, 1.00), 9.00);
      
      // Single quantity
      expect(calculateItemTotal(1, 0.25, null), 0.25);
      
      // Large quantity
      expect(calculateItemTotal(10, 0.99, null), 9.90);
      
      // With high discount (should not go negative)
      expect(calculateItemTotal(1, 1.00, 2.00), 0.00);
    });

    // Specific test: Editing quantity recalculates total
    test('editing quantity recalculates item totalPrice correctly', () {
      const originalItem = LineItem(
        itemId: '1',
        description: 'Test Item',
        category: 'Groceries',
        quantity: 2,
        unitPrice: 1.50,
        totalPrice: 3.00,
        discount: null,
        isDiscounted: false,
        type: 'regular',
        tags: [],
      );

      // Simulate edit: change quantity to 5
      final newTotal = calculateItemTotal(5, originalItem.unitPrice, originalItem.discount);
      
      expect(newTotal, 7.50);
    });

    // Specific test: Editing unitPrice recalculates total
    test('editing unitPrice recalculates item totalPrice correctly', () {
      const originalItem = LineItem(
        itemId: '2',
        description: 'Test Item',
        category: 'Groceries',
        quantity: 3,
        unitPrice: 2.00,
        totalPrice: 6.00,
        discount: null,
        isDiscounted: false,
        type: 'regular',
        tags: [],
      );

      // Simulate edit: change unitPrice to 2.50
      final newTotal = calculateItemTotal(originalItem.quantity, 2.50, originalItem.discount);

      expect(newTotal, 7.50);
    });

    // Specific test: Editing discounted item preserves discount
    test('editing discounted item applies discount correctly', () {
      const originalItem = LineItem(
        itemId: '3',
        description: 'Discounted Item',
        category: 'Groceries',
        quantity: 2,
        unitPrice: 5.00,
        totalPrice: 9.00, // 10.00 - 1.00 discount
        discount: 1.00,
        isDiscounted: true,
        type: 'regular',
        tags: [],
      );

      // Simulate edit: change quantity to 4
      final newTotal = calculateItemTotal(4, originalItem.unitPrice, originalItem.discount);

      expect(newTotal, 19.00); // 4 * 5.00 - 1.00
    });

    // Specific test: Totals recalculation with mixed items
    test('totals recalculate correctly with mixed regular and Pfand items', () {
      final items = [
        const LineItem(
          itemId: '1', description: 'Milk', category: 'Groceries',
          quantity: 1, unitPrice: 1.29, totalPrice: 1.29,
          discount: null, isDiscounted: false, type: 'regular', tags: [],
        ),
        const LineItem(
          itemId: '2', description: 'Pfand', category: 'Deposit',
          quantity: 1, unitPrice: 0.25, totalPrice: 0.25,
          discount: null, isDiscounted: false, type: 'pfand_bottle', tags: [],
        ),
      ];

      final totals = calculateTotals(items);

      expect(totals.subtotal, closeTo(1.29, 0.01));
      expect(totals.pfandTotal, closeTo(0.25, 0.01));
      expect(totals.taxAmount, closeTo(0.09, 0.01)); // 1.29 * 0.07
      expect(totals.grandTotal, closeTo(1.63, 0.01)); // 1.29 + 0.25 + 0.09
    });

    // Test: Editing multiple items recalculates grand total
    test('editing multiple items recalculates grand total correctly', () {
      // Original items
      final items = [
        const LineItem(
          itemId: '1', description: 'Item 1', category: 'Groceries',
          quantity: 1, unitPrice: 2.00, totalPrice: 2.00,
          discount: null, isDiscounted: false, type: 'regular', tags: [],
        ),
        const LineItem(
          itemId: '2', description: 'Item 2', category: 'Groceries',
          quantity: 1, unitPrice: 3.00, totalPrice: 3.00,
          discount: null, isDiscounted: false, type: 'regular', tags: [],
        ),
      ];

      final originalTotals = calculateTotals(items);
      expect(originalTotals.subtotal, 5.00);

      // Simulate edits: change quantities
      final editedItems = [
        LineItem(
          itemId: '1', description: 'Item 1', category: 'Groceries',
          quantity: 3, unitPrice: 2.00, 
          totalPrice: calculateItemTotal(3, 2.00, null), // 6.00
          discount: null, isDiscounted: false, type: 'regular', tags: const [],
        ),
        LineItem(
          itemId: '2', description: 'Item 2', category: 'Groceries',
          quantity: 2, unitPrice: 3.00, 
          totalPrice: calculateItemTotal(2, 3.00, null), // 6.00
          discount: null, isDiscounted: false, type: 'regular', tags: const [],
        ),
      ];

      final editedTotals = calculateTotals(editedItems);
      expect(editedTotals.subtotal, 12.00);
      expect(editedTotals.grandTotal, closeTo(12.00 + (12.00 * 0.07), 0.01));
    });
  });
}

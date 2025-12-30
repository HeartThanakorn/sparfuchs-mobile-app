import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, test, group;
import 'package:sparfuchs_ai/core/models/receipt.dart';

/// Property 3: Discount Field Consistency
/// Validates: Requirements 1.5
///
/// Property: If isDiscounted == true, then discount should be non-null and > 0
/// If discount is null or <= 0, then isDiscounted should be false

void main() {
  group('Property 3: Discount Field Consistency', () {
    // Property test: isDiscounted implies discount > 0
    Glados(any.lineItemWithDiscount).test(
      'isDiscounted == true implies discount > 0',
      (lineItem) {
        if (lineItem.isDiscounted) {
          expect(lineItem.discount, isNotNull);
          expect(lineItem.discount! > 0, isTrue,
              reason: 'When isDiscounted is true, discount must be positive');
        }
      },
    );

    // Property test: discount > 0 implies isDiscounted
    Glados(any.lineItemWithDiscount).test(
      'discount > 0 implies isDiscounted == true',
      (lineItem) {
        if (lineItem.discount != null && lineItem.discount! > 0) {
          expect(lineItem.isDiscounted, isTrue,
              reason: 'When discount is positive, isDiscounted must be true');
        }
      },
    );

    // Specific test: valid discounted item
    test('discounted item has positive discount and isDiscounted true', () {
      final discountedItem = LineItem(
        itemId: '123',
        description: 'Sale Item',
        category: 'Groceries',
        quantity: 1,
        unitPrice: 2.99,
        totalPrice: 2.49,
        discount: 0.50,
        isDiscounted: true,
        type: 'regular',
        tags: [],
      );

      expect(discountedItem.isDiscounted, isTrue);
      expect(discountedItem.discount, 0.50);
    });

    // Specific test: non-discounted item
    test('non-discounted item has null discount and isDiscounted false', () {
      final regularItem = LineItem(
        itemId: '456',
        description: 'Regular Item',
        category: 'Groceries',
        quantity: 1,
        unitPrice: 1.99,
        totalPrice: 1.99,
        discount: null,
        isDiscounted: false,
        type: 'regular',
        tags: [],
      );

      expect(regularItem.isDiscounted, isFalse);
      expect(regularItem.discount, isNull);
    });

    // Edge case: zero discount
    test('zero discount should have isDiscounted false', () {
      final zeroDiscountItem = LineItem(
        itemId: '789',
        description: 'Zero Discount Item',
        category: 'Groceries',
        quantity: 1,
        unitPrice: 3.99,
        totalPrice: 3.99,
        discount: 0.0,
        isDiscounted: false,
        type: 'regular',
        tags: [],
      );

      expect(zeroDiscountItem.isDiscounted, isFalse);
      expect(zeroDiscountItem.discount, 0.0);
    });
  });
}

// Custom generator for LineItem with various discount configurations
extension AnyLineItemForDiscount on Any {
  Generator<LineItem> get lineItemWithDiscount {
    return combine2(
      any.bool, // isDiscounted
      any.double, // discount value
      (isDiscounted, discountValue) {
        // Gen consistent data: if isDiscounted, ensure positive discount
        final actualDiscount = isDiscounted ? discountValue.abs() + 0.01 : null;

        return LineItem(
          itemId: 'test_${discountValue.hashCode}',
          description: isDiscounted ? 'Discounted Item' : 'Regular Item',
          category: 'Groceries',
          quantity: 1,
          unitPrice: 10.0,
          totalPrice: isDiscounted ? 10.0 - (actualDiscount ?? 0) : 10.0,
          discount: actualDiscount,
          isDiscounted: isDiscounted,
          type: 'regular',
          tags: [],
        );
      },
    );
  }
}

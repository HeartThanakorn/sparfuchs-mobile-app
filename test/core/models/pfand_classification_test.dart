import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, test, group;
import 'package:sparfuchs_ai/core/models/receipt.dart';

/// Property 2: Pfand Item Classification
/// Validates: Requirements 1.4
///
/// Property: For any LineItem, isPfand getter returns true
/// if and only if type == 'pfand_bottle'

void main() {
  group('Property 2: Pfand Item Classification', () {
    // Property test: isPfand == true iff type == 'pfand_bottle'
    Glados(any.lineItemWithType).test(
      'isPfand returns true iff type == "pfand_bottle"',
      (lineItem) {
        final expectedIsPfand = lineItem.type == 'pfand_bottle';
        expect(lineItem.isPfand, expectedIsPfand);
      },
    );

    // Specific test: type == 'pfand_bottle' => isPfand == true
    test('isPfand is true when type is "pfand_bottle"', () {
      final pfandItem = LineItem(
        itemId: '123',
        description: 'Pfand Flasche',
        category: 'Deposit',
        quantity: 1,
        unitPrice: 0.25,
        totalPrice: 0.25,
        discount: null,
        isDiscounted: false,
        type: 'pfand_bottle',
        tags: [],
      );

      expect(pfandItem.isPfand, isTrue);
    });

    // Specific test: type != 'pfand_bottle' => isPfand == false
    test('isPfand is false when type is not "pfand_bottle"', () {
      final regularItem = LineItem(
        itemId: '456',
        description: 'Milch',
        category: 'Groceries',
        quantity: 1,
        unitPrice: 1.29,
        totalPrice: 1.29,
        discount: null,
        isDiscounted: false,
        type: 'regular',
        tags: [],
      );

      expect(regularItem.isPfand, isFalse);
    });

    // Edge case: type is null => isPfand == false
    test('isPfand is false when type is null', () {
      final nullTypeItem = LineItem(
        itemId: '789',
        description: 'Unknown Item',
        category: 'Other',
        quantity: 1,
        unitPrice: 2.99,
        totalPrice: 2.99,
        discount: null,
        isDiscounted: false,
        type: null,
        tags: [],
      );

      expect(nullTypeItem.isPfand, isFalse);
    });

    // Edge case: similar but not exact match
    test('isPfand is false for similar but incorrect types', () {
      final similarTypes = [
        'pfand',
        'pfand_bottle_',
        'PFAND_BOTTLE',
        'Pfand_Bottle',
        'pfand_can',
        'deposit',
      ];

      for (final typeName in similarTypes) {
        final item = LineItem(
          itemId: 'test',
          description: 'Test Item',
          category: 'Test',
          quantity: 1,
          unitPrice: 0.25,
          totalPrice: 0.25,
          discount: null,
          isDiscounted: false,
          type: typeName,
          tags: [],
        );

        expect(
          item.isPfand,
          isFalse,
          reason: 'type "$typeName" should not be classified as Pfand',
        );
      }
    });
  });
}

// Custom generator for LineItem with various type values
extension AnyLineItemForPfand on Any {
  Generator<LineItem> get lineItemWithType {
    return combine2(
      // Generate various type values including pfand_bottle
      any.choose([
        'pfand_bottle',
        'regular',
        'discount',
        null,
        'pfand',
        'deposit',
        'PFAND_BOTTLE',
      ]),
      any.double,
      (type, price) => LineItem(
        itemId: 'test_${price.hashCode}',
        description: type == 'pfand_bottle' ? 'Pfand Flasche' : 'Regular Item',
        category: type == 'pfand_bottle' ? 'Deposit' : 'Groceries',
        quantity: 1,
        unitPrice: price.abs(),
        totalPrice: price.abs(),
        discount: null,
        isDiscounted: false,
        type: type,
        tags: [],
      ),
    );
  }
}

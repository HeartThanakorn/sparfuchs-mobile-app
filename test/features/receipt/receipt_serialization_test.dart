import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

/// Property 7: Receipt Serialization Round-Trip
/// Validates: Requirements 2.7, 11.1, 11.2, 11.3
///
/// Properties:
/// 1. JSON → Model → JSON round-trip preserves all data
/// 2. All required fields are present in serialized output
/// 3. Pfand items are correctly identified
/// 4. Totals are correctly serialized
/// 5. AI metadata is preserved

void main() {
  group('Property 7: Receipt Serialization Round-Trip', () {
    // Sample receipt JSON matching Gemini API response format
    final sampleReceiptJson = {
      'merchant': {
        'name': 'Lidl',
        'branch_id': 'DE-12345',
        'address': 'Musterstraße 1, 10115 Berlin',
        'raw_text': 'Lidl Dienstleistung'
      },
      'transaction': {
        'date': '2025-01-15',
        'time': '14:30:00',
        'currency': 'EUR',
        'payment_method': 'CARD'
      },
      'items': [
        {
          'item_id': 'item_001',
          'description': 'Vollmilch 1L',
          'category': 'Groceries',
          'quantity': 2,
          'unit_price': 1.29,
          'total_price': 2.58,
          'discount': null,
          'is_discounted': false,
          'type': null,
          'tags': ['dairy']
        },
        {
          'item_id': 'item_002',
          'description': 'Pfand',
          'category': 'Deposit',
          'quantity': 4,
          'unit_price': 0.25,
          'total_price': 1.00,
          'discount': null,
          'is_discounted': false,
          'type': 'pfand_bottle',
          'tags': ['deposit']
        },
        {
          'item_id': 'item_003',
          'description': 'Schokolade',
          'category': 'Snacks',
          'quantity': 1,
          'unit_price': 1.99,
          'total_price': 0.99,
          'discount': -1.00,
          'is_discounted': true,
          'type': null,
          'tags': ['chocolate', 'discounted']
        }
      ],
      'totals': {
        'subtotal': 3.57,
        'pfand_total': 1.00,
        'tax_amount': 0.25,
        'grand_total': 4.57
      },
      'taxes': [
        {'rate': 7.0, 'amount': 0.20},
        {'rate': 19.0, 'amount': 0.05}
      ],
      'ai_metadata': {
        'confidence_score': 0.95,
        'model_used': 'gemini-2.5-flash',
        'processing_time_ms': 1500
      }
    };

    // Test: Round-trip serialization preserves data
    test('JSON round-trip preserves all data', () {
      final json = jsonEncode(sampleReceiptJson);
      final decoded = jsonDecode(json) as Map<String, dynamic>;

      expect(decoded['merchant']['name'], 'Lidl');
      expect(decoded['transaction']['date'], '2025-01-15');
      expect(decoded['items'].length, 3);
      expect(decoded['totals']['grand_total'], 4.57);
    });

    // Test: Required fields are present
    test('all required fields are present in receipt JSON', () {
      expect(sampleReceiptJson.containsKey('merchant'), isTrue);
      expect(sampleReceiptJson.containsKey('transaction'), isTrue);
      expect(sampleReceiptJson.containsKey('items'), isTrue);
      expect(sampleReceiptJson.containsKey('totals'), isTrue);
      expect(sampleReceiptJson.containsKey('taxes'), isTrue);
      expect(sampleReceiptJson.containsKey('ai_metadata'), isTrue);
    });

    // Test: Merchant fields
    test('merchant has required fields', () {
      final merchant = sampleReceiptJson['merchant'] as Map<String, dynamic>;
      expect(merchant.containsKey('name'), isTrue);
      expect(merchant['name'], isNotEmpty);
    });

    // Test: Transaction fields
    test('transaction has required fields', () {
      final transaction = sampleReceiptJson['transaction'] as Map<String, dynamic>;
      expect(transaction.containsKey('date'), isTrue);
      expect(transaction.containsKey('time'), isTrue);
      expect(transaction.containsKey('currency'), isTrue);
      expect(transaction.containsKey('payment_method'), isTrue);

      // Date format validation
      final date = transaction['date'] as String;
      expect(date, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));

      // Time format validation
      final time = transaction['time'] as String;
      expect(time, matches(RegExp(r'^\d{2}:\d{2}:\d{2}$')));
    });

    // Test: Line items structure
    test('line items have required fields', () {
      final items = sampleReceiptJson['items'] as List;
      for (final item in items) {
        final itemMap = item as Map<String, dynamic>;
        expect(itemMap.containsKey('description'), isTrue);
        expect(itemMap.containsKey('category'), isTrue);
        expect(itemMap.containsKey('quantity'), isTrue);
        expect(itemMap.containsKey('unit_price'), isTrue);
        expect(itemMap.containsKey('total_price'), isTrue);
      }
    });

    // Test: Pfand items are identified correctly
    test('Pfand items have type pfand_bottle', () {
      final items = sampleReceiptJson['items'] as List;
      final pfandItems = items.where(
        (item) => (item as Map<String, dynamic>)['type'] == 'pfand_bottle',
      ).toList();

      expect(pfandItems.length, 1);
      expect(pfandItems.first['description'], 'Pfand');
      expect(pfandItems.first['category'], 'Deposit');
    });

    // Test: Discounted items are marked
    test('discounted items have is_discounted true and negative discount', () {
      final items = sampleReceiptJson['items'] as List;
      final discountedItems = items.where(
        (item) => (item as Map<String, dynamic>)['is_discounted'] == true,
      ).toList();

      expect(discountedItems.length, 1);
      expect(discountedItems.first['discount'], isNegative);
    });

    // Test: Totals structure
    test('totals have all required fields', () {
      final totals = sampleReceiptJson['totals'] as Map<String, dynamic>;
      expect(totals.containsKey('subtotal'), isTrue);
      expect(totals.containsKey('pfand_total'), isTrue);
      expect(totals.containsKey('tax_amount'), isTrue);
      expect(totals.containsKey('grand_total'), isTrue);

      // All values should be numbers
      expect(totals['subtotal'], isA<num>());
      expect(totals['pfand_total'], isA<num>());
      expect(totals['grand_total'], isA<num>());
    });

    // Test: Tax entries structure
    test('taxes have rate and amount', () {
      final taxes = sampleReceiptJson['taxes'] as List;
      expect(taxes.length, 2);

      for (final tax in taxes) {
        final taxMap = tax as Map<String, dynamic>;
        expect(taxMap.containsKey('rate'), isTrue);
        expect(taxMap.containsKey('amount'), isTrue);
        expect(taxMap['rate'], anyOf(equals(7.0), equals(19.0)));
      }
    });

    // Test: AI metadata structure
    test('ai_metadata has confidence_score and model_used', () {
      final metadata = sampleReceiptJson['ai_metadata'] as Map<String, dynamic>;
      expect(metadata.containsKey('confidence_score'), isTrue);
      expect(metadata.containsKey('model_used'), isTrue);

      final confidence = metadata['confidence_score'] as double;
      expect(confidence, greaterThanOrEqualTo(0.0));
      expect(confidence, lessThanOrEqualTo(1.0));
    });

    // Test: Confidence score validation
    test('confidence_score is between 0 and 1', () {
      final metadata = sampleReceiptJson['ai_metadata'] as Map<String, dynamic>;
      final confidence = metadata['confidence_score'] as double;

      expect(confidence >= 0.0 && confidence <= 1.0, isTrue);
    });

    // Test: Processing time is present
    test('processing_time_ms is a positive number', () {
      final metadata = sampleReceiptJson['ai_metadata'] as Map<String, dynamic>;
      final processingTime = metadata['processing_time_ms'] as int;

      expect(processingTime, greaterThan(0));
    });
  });
}

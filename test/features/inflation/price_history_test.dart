import 'package:flutter_test/flutter_test.dart';
import 'package:sparfuchs_ai/core/models/price_history.dart';

/// Property 17: Price History Recording
/// Validates: Requirements 6.1
///
/// Properties:
/// 1. Adding a record preserves previous records (history accumulation)
/// 2. Records are always sorted by date (newest first)
/// 3. Duplicate entries (same date/store) update rather than duplicate
/// 4. Percentage change is calculated correctly based on history
/// 5. Current price always reflects the most recent record

void main() {
  group('Property 17: Price History Recording', () {
    // Helper to create dates relative to now
    DateTime daysAgo(int days) => DateTime.now().subtract(Duration(days: days));

    // Test: Adding records accumulates history
    test('adding records accumulates history', () {
      var history = const PriceHistory(productId: '1', productName: 'Milk');
      expect(history.records.isEmpty, isTrue);

      history = history.addRecord(PriceRecord(
        price: 1.0,
        date: daysAgo(5),
        store: 'Aldi',
      ));
      expect(history.records.length, 1);

      history = history.addRecord(PriceRecord(
        price: 1.2,
        date: daysAgo(1),
        store: 'Aldi',
      ));
      expect(history.records.length, 2);
    });

    // Test: Records sorted by date descending
    test('records are sorted by date descending (newest first)', () {
      var history = const PriceHistory(productId: '1', productName: 'Milk');
      
      final date1 = daysAgo(10);
      final date2 = daysAgo(5);
      final date3 = daysAgo(1); // Newest

      history = history.addRecord(PriceRecord(price: 1.0, date: date2, store: 'A'));
      history = history.addRecord(PriceRecord(price: 1.0, date: date1, store: 'A'));
      history = history.addRecord(PriceRecord(price: 1.0, date: date3, store: 'A'));

      expect(history.records.length, 3);
      expect(history.records[0].date, date3);
      expect(history.records[1].date, date2);
      expect(history.records[2].date, date1);
    });

    // Test: Current price is from newest record
    test('current price reflects newest record', () {
      var history = const PriceHistory(productId: '1', productName: 'Milk');
      history = history.addRecord(PriceRecord(price: 1.50, date: daysAgo(5), store: 'A'));
      history = history.addRecord(PriceRecord(price: 2.00, date: daysAgo(1), store: 'A')); 

      expect(history.currentPrice, 2.00);
    });

    // Test: Duplicate date/store updates record
    test('adding record with same date and store updates existing', () {
      var history = const PriceHistory(productId: '1', productName: 'Milk');
      final date = DateTime(2024, 1, 1);

      history = history.addRecord(PriceRecord(price: 1.00, date: date, store: 'Rewe'));
      expect(history.records.single.price, 1.00);

      // Same store, same date -> Update
      history = history.addRecord(PriceRecord(price: 1.50, date: date, store: 'Rewe'));
      expect(history.records.length, 1);
      expect(history.records.single.price, 1.50);

      // Different store, same date -> New record
      history = history.addRecord(PriceRecord(price: 1.20, date: date, store: 'Aldi'));
      expect(history.records.length, 2);
    });

    // Test: Percentage calculation (Increase)
    test('calculates correct percentage increase', () {
      var history = const PriceHistory(productId: '1', productName: 'Milk');
      
      // Old price: 1.00
      history = history.addRecord(PriceRecord(price: 1.00, date: daysAgo(40), store: 'A'));
      // New price: 1.50
      history = history.addRecord(PriceRecord(price: 1.50, date: daysAgo(1), store: 'A'));

      // (1.50 - 1.00) / 1.00 = 0.50 = 50%
      expect(history.getPriceChangePercentage(30), closeTo(50.0, 0.01));
    });

    // Test: Percentage calculation (Decrease)
    test('calculates correct percentage decrease', () {
      var history = const PriceHistory(productId: '1', productName: 'Milk');
      
      // Old price: 2.00
      history = history.addRecord(PriceRecord(price: 2.00, date: daysAgo(40), store: 'A'));
      // New price: 1.00
      history = history.addRecord(PriceRecord(price: 1.00, date: daysAgo(1), store: 'A'));

      // (1.00 - 2.00) / 2.00 = -0.50 = -50%
      expect(history.getPriceChangePercentage(30), closeTo(-50.0, 0.01));
    });

    // Test: Percentage calculation with no history
    test('percentage change is 0 if no history', () {
      var history = const PriceHistory(productId: '1', productName: 'Milk');
      expect(history.getPriceChangePercentage(), 0.0);

      history = history.addRecord(PriceRecord(price: 1.0, date: DateTime.now(), store: 'A'));
      expect(history.getPriceChangePercentage(), 0.0);
    });

    // Property: Adding unordered records results in ordered history
    test('adding unordered records results in correctly ordered history', () {
      var history = const PriceHistory(productId: '1', productName: 'Test');
      final records = [
        PriceRecord(price: 1, date: daysAgo(5), store: 'A'),
        PriceRecord(price: 2, date: daysAgo(10), store: 'A'),
        PriceRecord(price: 3, date: daysAgo(1), store: 'A'),
        PriceRecord(price: 4, date: daysAgo(20), store: 'A'),
      ];

      for (var r in records) {
        history = history.addRecord(r);
      }

      // Should be sorted by date descending (closest to now first)
      expect(history.records[0].price, 3); // 1 day ago
      expect(history.records[1].price, 1); // 5 days ago
      expect(history.records[2].price, 2); // 10 days ago
      expect(history.records[3].price, 4); // 20 days ago

      // Check strict inequality of dates for sorted property
      for (int i = 0; i < history.records.length - 1; i++) {
        expect(
          history.records[i].date.isAfter(history.records[i+1].date), 
          isTrue
        );
      }
    });

    // Property: Store consistency
    test('records preserve store information', () {
      var history = const PriceHistory(productId: '1', productName: 'Test');
      history = history.addRecord(PriceRecord(price: 1, date: daysAgo(1), store: 'Store A'));
      history = history.addRecord(PriceRecord(price: 1, date: daysAgo(2), store: 'Store B'));

      expect(history.records.any((r) => r.store == 'Store A'), isTrue);
      expect(history.records.any((r) => r.store == 'Store B'), isTrue);
    });
  });
}

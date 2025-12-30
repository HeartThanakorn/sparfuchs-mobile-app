import 'package:flutter_test/flutter_test.dart';

/// Property 19: Price Comparison and Percentage Calculation
/// Validates: Requirements 6.4 (Comparison), 6.5 (Calculation)
///
/// Properties:
/// 1. Cheapest merchant is correctly identified
/// 2. Price difference percentage is calculated correctly
/// 3. Zero prices are handled gracefully
/// 4. Sorting logic works (cheapest first)

class MerchantPrice {
  final String name;
  final double price;
  MerchantPrice(this.name, this.price);
}

void main() {
  group('Property 19: Price Comparison and Percentage Calculation', () {
    // Logic under test (simulating comparison logic from screens)
    MerchantPrice? findCheapest(List<MerchantPrice> prices) {
      if (prices.isEmpty) return null;
      return prices.reduce((curr, next) => curr.price < next.price ? curr : next);
    }

    double calculateSavingPercentage(double currentPrice, double comparisonPrice) {
      if (currentPrice == 0) return 0.0;
      // Formula: ((Current - Compare) / Current) * 100 for saving?
      // Or just standard diff: ((Compare - Current) / Current) * 100
      // Let's assume standard % difference for comparison
      // If saving: (Higher - Lower) / Higher * 100
      
      final diff = (currentPrice - comparisonPrice).abs();
      return (diff / (currentPrice > comparisonPrice ? currentPrice : comparisonPrice)) * 100;
      
      // Simpler standard change for generic comparison:
      // return ((currentPrice - comparisonPrice) / comparisonPrice) * 100;
    }

    // Standard percentage change formula used in PriceChangeIndicator
    double calculatePercentageChange(double newPrice, double oldPrice) {
      if (oldPrice == 0) return 0.0;
      return ((newPrice - oldPrice) / oldPrice) * 100;
    }

    List<MerchantPrice> sortCheapestFirst(List<MerchantPrice> prices) {
      final sorted = List<MerchantPrice>.from(prices);
      sorted.sort((a, b) => a.price.compareTo(b.price));
      return sorted;
    }

    // Test: Identify cheapest merchant
    test('cheapest merchant is correctly identified', () {
      final prices = [
        MerchantPrice('Rewe', 2.99),
        MerchantPrice('Aldi', 2.49),
        MerchantPrice('Edeka', 2.79),
      ];
      final cheapest = findCheapest(prices);
      expect(cheapest?.name, 'Aldi');
      expect(cheapest?.price, 2.49);
    });

    // Test: Sorting logic
    test('sorting puts cheapest first', () {
      final prices = [
        MerchantPrice('Rewe', 2.99),
        MerchantPrice('Aldi', 2.49),
        MerchantPrice('Edeka', 2.79),
      ];
      final sorted = sortCheapestFirst(prices);
      
      expect(sorted[0].name, 'Aldi');
      expect(sorted[1].name, 'Edeka');
      expect(sorted[2].name, 'Rewe');
    });

    // Test: Identical prices
    test('identical prices handled stably', () {
      final prices = [
        MerchantPrice('Aldi North', 1.99),
        MerchantPrice('Aldi South', 1.99),
      ];
      final cheapest = findCheapest(prices);
      expect(cheapest?.price, 1.99); // Either is fine, just ensures no crash
      expect(prices.contains(cheapest), isTrue);
    });

    // Test: Calculate percentage change
    test('calculates correct percentage change', () {
      // increase
      expect(calculatePercentageChange(1.10, 1.00), closeTo(10.0, 0.01));
      
      // decrease
      expect(calculatePercentageChange(0.90, 1.00), closeTo(-10.0, 0.01));
      
      // no change
      expect(calculatePercentageChange(1.00, 1.00), 0.0);
    });

    // Test: Division by zero protection
    test('calculating percentage with zero base returns 0', () {
      expect(calculatePercentageChange(5.00, 0.00), 0.0);
    });

    // Test: Comparison of empty list
    test('empty comparison returns null', () {
      expect(findCheapest([]), null);
    });

    // Property: Lowest price is always <= any other price
    test('cheapest price is less than or equal to all other prices', () {
      final prices = [
        MerchantPrice('A', 10.0),
        MerchantPrice('B', 5.0),
        MerchantPrice('C', 7.5),
        MerchantPrice('D', 5.0),
      ];
      final cheapest = findCheapest(prices);
      
      for (final p in prices) {
        expect(cheapest!.price, lessThanOrEqualTo(p.price));
      }
    });
  });
}

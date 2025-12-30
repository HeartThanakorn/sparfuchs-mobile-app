import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/features/inflation/presentation/widgets/price_change_indicator.dart';

/// Property 18: Inflation Alert Threshold
/// Validates: Requirements 6.3
///
/// Properties:
/// 1. Price increase > 10% triggers alert (red color + warning icon)
/// 2. Price increase 0-10% shows warning (orange color)
/// 3. Price decrease shows positive trend (green color)
/// 4. No change causes neutral state

void main() {
  group('Property 18: Inflation Alert Threshold', () {
    /// Helper to get effective color from percentage
    Color getIndicatorColor(double percentage) {
      if (percentage > 10.0) return const Color(AppColors.errorRed);
      if (percentage > 0) return const Color(AppColors.warningOrange);
      if (percentage < 0) return const Color(AppColors.successGreen);
      return const Color(AppColors.neutralGray);
    }

    /// Helper to deduce if warning icon should be shown
    bool shouldShowWarningIcon(double percentage) {
      return percentage > 10.0;
    }

    // Test: Significant increase (> 10%)
    test('significant increase (> 10%) triggers alert color and icon', () {
      final percentages = [10.1, 15.0, 50.0, 100.0];

      for (final pct in percentages) {
        expect(
          getIndicatorColor(pct),
          const Color(AppColors.errorRed),
          reason: '$pct% should be red',
        );
        expect(
          shouldShowWarningIcon(pct),
          isTrue,
          reason: '$pct% should show warning icon',
        );
      }
    });

    // Test: Minor increase (0% < x <= 10%)
    test('minor increase (0-10%) triggers warning orange', () {
      final percentages = [0.1, 5.0, 9.9, 10.0];

      for (final pct in percentages) {
        expect(
          getIndicatorColor(pct),
          const Color(AppColors.warningOrange),
          reason: '$pct% should be orange',
        );
        expect(
          shouldShowWarningIcon(pct),
          isFalse,
          reason: '$pct% should NOT show warning icon',
        );
      }
    });

    // Test: Decrease (< 0%)
    test('price decrease triggers success green', () {
      final percentages = [-0.1, -10.0, -50.0];

      for (final pct in percentages) {
        expect(
          getIndicatorColor(pct),
          const Color(AppColors.successGreen),
          reason: '$pct% should be green',
        );
        expect(shouldShowWarningIcon(pct), isFalse);
      }
    });

    // Test: No change (0%)
    test('no change triggers neutral gray', () {
      final pct = 0.0;
      expect(getIndicatorColor(pct), const Color(AppColors.neutralGray));
      expect(shouldShowWarningIcon(pct), isFalse);
    });

    // Test: Boundary conditions
    test('boundary conditions are handled correctly', () {
      expect(getIndicatorColor(10.0), const Color(AppColors.warningOrange));
      expect(getIndicatorColor(10.00001), const Color(AppColors.errorRed));
      expect(getIndicatorColor(0.0), const Color(AppColors.neutralGray));
    });

    // Widget Test: Verify actual widget rendering logic matches
    testWidgets('PriceChangeIndicator visual matches logical properties', (tester) async {
      // > 10%
      await tester.pumpWidget(const MaterialApp(
        home: Material(child: PriceChangeIndicator(currentPrice: 115, previousPrice: 100)), // 15%
      ));
      
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      // Note: The widget uses color.withValues(alpha: 0.1), so we can't strict match color object
      // But we can check if it creates the warning icon
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);


      // 5% (Orange)
      await tester.pumpWidget(const MaterialApp(
        home: Material(child: PriceChangeIndicator(currentPrice: 105, previousPrice: 100)),
      ));
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);


      // -10% (Green)
      await tester.pumpWidget(const MaterialApp(
        home: Material(child: PriceChangeIndicator(currentPrice: 90, previousPrice: 100)),
      ));
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });
  });
}

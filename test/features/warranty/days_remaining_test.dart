import 'package:flutter_test/flutter_test.dart';

/// Property 22: Days Remaining Calculation
/// Validates: Requirements 8.5
///
/// Properties:
/// 1. Days remaining is calculated correctly for future dates
/// 2. Days remaining is negative for past dates
/// 3. Days remaining is 0 on the deadline day
/// 4. canStillReturn is true when days >= 0
/// 5. hasValidWarranty is true when warranty days >= 0

/// Calculate days remaining until a deadline
int calculateDaysRemaining(DateTime deadline, DateTime now) {
  return deadline.difference(now).inDays;
}

/// Check if return window is still open
bool canStillReturn(DateTime returnDeadline, DateTime now, bool isReturned) {
  if (isReturned) return false;
  return calculateDaysRemaining(returnDeadline, now) >= 0;
}

/// Check if warranty is still valid
bool hasValidWarranty(DateTime? warrantyExpiry, DateTime now) {
  if (warrantyExpiry == null) return false;
  return calculateDaysRemaining(warrantyExpiry, now) >= 0;
}

void main() {
  group('Property 22: Days Remaining Calculation', () {
    // Test: Future date gives positive days
    test('future deadline gives positive days remaining', () {
      final now = DateTime(2024, 1, 1);
      final deadline = DateTime(2024, 1, 15);

      final days = calculateDaysRemaining(deadline, now);

      expect(days, 14);
      expect(days, greaterThan(0));
    });

    // Test: Past date gives negative days
    test('past deadline gives negative days remaining', () {
      final now = DateTime(2024, 1, 15);
      final deadline = DateTime(2024, 1, 1);

      final days = calculateDaysRemaining(deadline, now);

      expect(days, -14);
      expect(days, lessThan(0));
    });

    // Test: Same day is 0 days
    test('same day deadline gives 0 days remaining', () {
      final now = DateTime(2024, 1, 15);
      final deadline = DateTime(2024, 1, 15);

      final days = calculateDaysRemaining(deadline, now);

      expect(days, 0);
    });

    // Test: canStillReturn with future deadline
    test('canStillReturn is true when deadline is in future', () {
      final now = DateTime(2024, 1, 1);
      final returnDeadline = DateTime(2024, 1, 15);

      expect(canStillReturn(returnDeadline, now, false), isTrue);
    });

    // Test: canStillReturn on same day
    test('canStillReturn is true on deadline day', () {
      final now = DateTime(2024, 1, 15);
      final returnDeadline = DateTime(2024, 1, 15);

      expect(canStillReturn(returnDeadline, now, false), isTrue);
    });

    // Test: canStillReturn with past deadline
    test('canStillReturn is false when deadline passed', () {
      final now = DateTime(2024, 1, 16);
      final returnDeadline = DateTime(2024, 1, 15);

      expect(canStillReturn(returnDeadline, now, false), isFalse);
    });

    // Test: canStillReturn when already returned
    test('canStillReturn is false when already returned', () {
      final now = DateTime(2024, 1, 1);
      final returnDeadline = DateTime(2024, 1, 15);

      expect(canStillReturn(returnDeadline, now, true), isFalse);
    });

    // Test: hasValidWarranty with future expiry
    test('hasValidWarranty is true when warranty not expired', () {
      final now = DateTime(2024, 1, 1);
      final warrantyExpiry = DateTime(2026, 1, 1);

      expect(hasValidWarranty(warrantyExpiry, now), isTrue);
    });

    // Test: hasValidWarranty with past expiry
    test('hasValidWarranty is false when warranty expired', () {
      final now = DateTime(2026, 1, 2);
      final warrantyExpiry = DateTime(2026, 1, 1);

      expect(hasValidWarranty(warrantyExpiry, now), isFalse);
    });

    // Test: hasValidWarranty with null expiry
    test('hasValidWarranty is false when no warranty', () {
      final now = DateTime(2024, 1, 1);

      expect(hasValidWarranty(null, now), isFalse);
    });

    // Test: Days calculation across year boundary
    test('days calculation works across year boundary', () {
      final now = DateTime(2023, 12, 25);
      final deadline = DateTime(2024, 1, 5);

      final days = calculateDaysRemaining(deadline, now);

      expect(days, 11);
    });
  });
}

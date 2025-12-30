import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/features/household/presentation/providers/household_receipts_provider.dart';

/// Time period options for spending analysis
enum SpendingPeriod {
  today,
  thisWeek,
  thisMonth,
  last30Days,
  last90Days,
  thisYear,
  allTime,
}

/// Spending summary for a period
class SpendingSummary {
  final double totalSpending;
  final int receiptCount;
  final double averagePerReceipt;
  final Map<String, double> spendingByCategory;
  final Map<String, double> spendingByMember;
  final SpendingPeriod period;

  const SpendingSummary({
    required this.totalSpending,
    required this.receiptCount,
    required this.averagePerReceipt,
    required this.spendingByCategory,
    required this.spendingByMember,
    required this.period,
  });

  static const empty = SpendingSummary(
    totalSpending: 0,
    receiptCount: 0,
    averagePerReceipt: 0,
    spendingByCategory: {},
    spendingByMember: {},
    period: SpendingPeriod.thisMonth,
  );
}

/// Calculator for household spending statistics
class HouseholdSpendingCalculator {
  /// Calculates spending summary for a list of receipts within a period
  static SpendingSummary calculate(
    List<Receipt> receipts,
    SpendingPeriod period,
  ) {
    final filteredReceipts = _filterByPeriod(receipts, period);

    if (filteredReceipts.isEmpty) {
      return SpendingSummary(
        totalSpending: 0,
        receiptCount: 0,
        averagePerReceipt: 0,
        spendingByCategory: {},
        spendingByMember: {},
        period: period,
      );
    }

    // Calculate totals
    double totalSpending = 0;
    final Map<String, double> byCategory = {};
    final Map<String, double> byMember = {};

    for (final receipt in filteredReceipts) {
      final grandTotal = receipt.receiptData.totals.grandTotal;
      totalSpending += grandTotal;

      // Aggregate by member
      byMember.update(
        receipt.userId,
        (value) => value + grandTotal,
        ifAbsent: () => grandTotal,
      );

      // Aggregate by category
      for (final item in receipt.receiptData.items) {
        byCategory.update(
          item.category,
          (value) => value + item.totalPrice,
          ifAbsent: () => item.totalPrice,
        );
      }
    }

    return SpendingSummary(
      totalSpending: totalSpending,
      receiptCount: filteredReceipts.length,
      averagePerReceipt: totalSpending / filteredReceipts.length,
      spendingByCategory: byCategory,
      spendingByMember: byMember,
      period: period,
    );
  }

  /// Filters receipts by the selected time period
  static List<Receipt> _filterByPeriod(
    List<Receipt> receipts,
    SpendingPeriod period,
  ) {
    final now = DateTime.now();
    final DateTime startDate;

    switch (period) {
      case SpendingPeriod.today:
        startDate = DateTime(now.year, now.month, now.day);
      case SpendingPeriod.thisWeek:
        startDate = now.subtract(Duration(days: now.weekday - 1));
      case SpendingPeriod.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
      case SpendingPeriod.last30Days:
        startDate = now.subtract(const Duration(days: 30));
      case SpendingPeriod.last90Days:
        startDate = now.subtract(const Duration(days: 90));
      case SpendingPeriod.thisYear:
        startDate = DateTime(now.year, 1, 1);
      case SpendingPeriod.allTime:
        return receipts;
    }

    return receipts.where((r) => r.createdAt.isAfter(startDate)).toList();
  }
}

/// Provider for the selected spending period
final selectedSpendingPeriodProvider = StateProvider<SpendingPeriod>((ref) {
  return SpendingPeriod.thisMonth;
});

/// Provider for household spending summary
final householdSpendingSummaryProvider = Provider<SpendingSummary>((ref) {
  final asyncReceipts = ref.watch(householdReceiptsProvider);
  final period = ref.watch(selectedSpendingPeriodProvider);

  return asyncReceipts.maybeWhen(
    data: (receipts) => HouseholdSpendingCalculator.calculate(receipts, period),
    orElse: () => SpendingSummary.empty,
  );
});

/// Provider for spending comparison (current vs previous period)
final spendingComparisonProvider = Provider<double>((ref) {
  final asyncReceipts = ref.watch(householdReceiptsProvider);
  final period = ref.watch(selectedSpendingPeriodProvider);

  return asyncReceipts.maybeWhen(
    data: (receipts) {
      final current = HouseholdSpendingCalculator.calculate(receipts, period);
      final previous = _getPreviousPeriodSpending(receipts, period);

      if (previous == 0) return 0;
      return ((current.totalSpending - previous) / previous) * 100;
    },
    orElse: () => 0,
  );
});

double _getPreviousPeriodSpending(List<Receipt> receipts, SpendingPeriod period) {
  final now = DateTime.now();
  DateTime startDate;
  DateTime endDate;

  switch (period) {
    case SpendingPeriod.thisMonth:
      startDate = DateTime(now.year, now.month - 1, 1);
      endDate = DateTime(now.year, now.month, 1);
    case SpendingPeriod.thisWeek:
      startDate = now.subtract(Duration(days: now.weekday + 6));
      endDate = now.subtract(Duration(days: now.weekday - 1));
    case SpendingPeriod.last30Days:
      startDate = now.subtract(const Duration(days: 60));
      endDate = now.subtract(const Duration(days: 30));
    default:
      return 0;
  }

  final filtered = receipts.where((r) =>
      r.createdAt.isAfter(startDate) && r.createdAt.isBefore(endDate));

  return filtered.fold<double>(
      0, (total, r) => total + r.receiptData.totals.grandTotal);
}

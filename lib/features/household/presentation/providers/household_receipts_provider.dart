
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/features/household/presentation/providers/household_provider.dart';
import 'package:sparfuchs_ai/features/receipt/presentation/providers/receipt_provider.dart';

/// StreamProvider for all receipts belonging to the current household
/// Receipts are ordered by transaction date descending
final householdReceiptsProvider = StreamProvider<List<Receipt>>((ref) {
  final asyncHousehold = ref.watch(householdProvider);
  final firestore = ref.watch(firestoreProvider);

  return asyncHousehold.when(
    data: (household) {
      if (household == null) {
        return Stream.value([]);
      }

      return firestore
          .collection('receipts')
          .where('householdId', isEqualTo: household.id)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Receipt.fromJson(doc.data()..['receiptId'] = doc.id))
              .toList());
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Provider for household receipts count
final householdReceiptsCountProvider = Provider<int>((ref) {
  final asyncReceipts = ref.watch(householdReceiptsProvider);
  return asyncReceipts.maybeWhen(
    data: (receipts) => receipts.length,
    orElse: () => 0,
  );
});

/// Provider for total spending of the household
final householdTotalSpendingProvider = Provider<double>((ref) {
  final asyncReceipts = ref.watch(householdReceiptsProvider);
  return asyncReceipts.maybeWhen(
    data: (receipts) => receipts.fold<double>(
      0.0,
      (total, receipt) => total + receipt.receiptData.totals.grandTotal,
    ),
    orElse: () => 0.0,
  );
});

/// Provider for filtering household receipts by member
final householdReceiptsByMemberProvider =
    Provider.family<List<Receipt>, String>((ref, memberId) {
  final asyncReceipts = ref.watch(householdReceiptsProvider);
  return asyncReceipts.maybeWhen(
    data: (receipts) => receipts.where((r) => r.userId == memberId).toList(),
    orElse: () => [],
  );
});

/// Provider for recent household receipts (last 7 days)
final recentHouseholdReceiptsProvider = Provider<List<Receipt>>((ref) {
  final asyncReceipts = ref.watch(householdReceiptsProvider);
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

  return asyncReceipts.maybeWhen(
    data: (receipts) => receipts.where((r) => r.createdAt.isAfter(sevenDaysAgo)).toList(),
    orElse: () => [],
  );
});

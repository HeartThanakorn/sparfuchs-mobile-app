import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/features/receipt/data/repositories/local_receipt_repository.dart';

/// Provider for LocalReceiptRepository (Local Only - No Auth Required)
final receiptRepositoryProvider = Provider<LocalReceiptRepository>((ref) {
  return LocalReceiptRepository();
});

/// StreamProvider for all receipts from local storage
/// Receipts are ordered by transaction date descending
final receiptsStreamProvider = StreamProvider<List<Receipt>>((ref) {
  final repository = ref.watch(receiptRepositoryProvider);
  return repository.watchReceipts();
});

/// Provider for a single receipt by ID
final receiptByIdProvider = FutureProvider.family<Receipt?, String>((ref, receiptId) async {
  final repository = ref.watch(receiptRepositoryProvider);
  return repository.getReceipt(receiptId);
});

/// Provider for bookmarked receipts only
final bookmarkedReceiptsProvider = Provider<List<Receipt>>((ref) {
  final asyncReceipts = ref.watch(receiptsStreamProvider);
  return asyncReceipts.maybeWhen(
    data: (receipts) => receipts.where((r) => r.isBookmarked).toList(),
    orElse: () => [],
  );
});

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/features/receipt/data/repositories/receipt_repository.dart';

/// Provider for Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for ReceiptRepository
final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ReceiptRepository(firestore: firestore);
});

/// StreamProvider for all receipts of the current user
/// Receipts are ordered by transaction date descending
final receiptsStreamProvider = StreamProvider<List<Receipt>>((ref) {
  final repository = ref.watch(receiptRepositoryProvider);
  return repository.watchReceipts(); // Uses current user from Auth by default
});

/// Provider for a single receipt by ID (Future, not Stream, consistent with Repo)
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

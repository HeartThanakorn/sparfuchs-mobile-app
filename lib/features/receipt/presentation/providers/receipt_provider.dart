import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/core/providers/user_provider.dart';
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

/// StreamProvider for all receipts of the current user's household
/// Receipts are ordered by transaction date descending
final receiptsProvider = StreamProvider<List<Receipt>>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(receiptRepositoryProvider);
  return repository.watchReceiptsForUser(userId);
});

/// Provider for a single receipt by ID
final receiptByIdProvider = StreamProvider.family<Receipt?, String>((ref, receiptId) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) {
    return Stream.value(null);
  }

  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('households')
      .doc(userId)
      .collection('receipts')
      .doc(receiptId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        return Receipt.fromJson(doc.data()!..['id'] = doc.id);
      });
});

/// Provider for bookmarked receipts only
final bookmarkedReceiptsProvider = Provider<List<Receipt>>((ref) {
  final asyncReceipts = ref.watch(receiptsProvider);
  return asyncReceipts.maybeWhen(
    data: (receipts) => receipts.where((r) => r.isBookmarked).toList(),
    orElse: () => [],
  );
});

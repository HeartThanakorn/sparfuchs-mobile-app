import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/features/receipt/data/repositories/local_receipt_repository.dart';

/// Provider for LocalReceiptRepository (Local Only - No Auth Required)
final receiptRepositoryProvider = Provider<LocalReceiptRepository>((ref) {
  return LocalReceiptRepository();
});

/// Provider for receipts stream
final receiptsStreamProvider = StreamProvider<List<Receipt>>((ref) {
  final repository = ref.watch(receiptRepositoryProvider);
  return repository.watchReceipts();
});

import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt.freezed.dart';
part 'receipt.g.dart';

/// Main Receipt model representing a scanned and processed receipt
@freezed
class Receipt with _$Receipt {
  const factory Receipt({
    required String receiptId,
    required String userId,
    String? householdId,
    required String imageUrl,
    @Default(false) bool isBookmarked,
    required ReceiptData receiptData,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Receipt;

  factory Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);
}

/// Structured data extracted from receipt
@freezed
class ReceiptData with _$ReceiptData {
  const factory ReceiptData({
    required Merchant merchant,
    required Transaction transaction,
    required List<LineItem> items,
    required Totals totals,
    required List<TaxEntry> taxes,
    required AiMetadata aiMetadata,
  }) = _ReceiptData;

  factory ReceiptData.fromJson(Map<String, dynamic> json) => _$ReceiptDataFromJson(json);
}

/// Merchant information
@freezed
class Merchant with _$Merchant {
  const factory Merchant({
    required String name,
    String? branchId,
    String? address,
    String? rawText,
  }) = _Merchant;

  factory Merchant.fromJson(Map<String, dynamic> json) => _$MerchantFromJson(json);
}

/// Transaction details
@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String date, // Format: YYYY-MM-DD
    required String time, // Format: HH:MM:SS
    required String currency, // e.g. EUR
    required String paymentMethod, // CASH, CARD
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}

/// Individual line item on the receipt
@freezed
class LineItem with _$LineItem {
  const LineItem._(); // Added constructor for adding methods/getters

  const factory LineItem({
    // Optional because it might not be generated yet during parsing
    String? itemId, 
    required String description,
    required String category,
    required int quantity,
    required double unitPrice,
    required double totalPrice,
    double? discount,
    @Default(false) bool isDiscounted,
    String? type,
    List<String>? tags,
  }) = _LineItem;

  factory LineItem.fromJson(Map<String, dynamic> json) => _$LineItemFromJson(json);

  /// Helper to check if this item is a Pfand (bottle deposit)
  bool get isPfand => type == 'pfand_bottle';
}

/// Totals summary
@freezed
class Totals with _$Totals {
  const factory Totals({
    required double subtotal,
    required double pfandTotal,
    required double taxAmount,
    required double grandTotal,
  }) = _Totals;

  factory Totals.fromJson(Map<String, dynamic> json) => _$TotalsFromJson(json);
}

/// Tax entry
@freezed
class TaxEntry with _$TaxEntry {
  const factory TaxEntry({
    required double rate,
    required double amount,
  }) = _TaxEntry;

  factory TaxEntry.fromJson(Map<String, dynamic> json) => _$TaxEntryFromJson(json);
}

/// Metadata from AI processing
@freezed
class AiMetadata with _$AiMetadata {
  const AiMetadata._(); // Added constructor for adding methods/getters

  const factory AiMetadata({
    required double confidenceScore,
    required String modelUsed,
    int? processingTimeMs,
  }) = _AiMetadata;

  factory AiMetadata.fromJson(Map<String, dynamic> json) => _$AiMetadataFromJson(json);

  /// Helper to check if manual review is needed (confidence < 0.8)
  bool get needsReview => confidenceScore < 0.8;
}

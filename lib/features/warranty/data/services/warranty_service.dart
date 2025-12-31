import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';

/// Model for a warranty item
class WarrantyItem {
  final String id;
  final String receiptId;
  final String userId;
  final String itemDescription;
  final String category;
  final double price;
  final DateTime purchaseDate;
  final DateTime returnDeadline;
  final DateTime? warrantyExpiry;
  final String? merchantName;
  final bool isReturned;
  final bool isExpired;

  const WarrantyItem({
    required this.id,
    required this.receiptId,
    required this.userId,
    required this.itemDescription,
    required this.category,
    required this.price,
    required this.purchaseDate,
    required this.returnDeadline,
    this.warrantyExpiry,
    this.merchantName,
    this.isReturned = false,
    this.isExpired = false,
  });

  factory WarrantyItem.fromJson(Map<String, dynamic> json, String id) {
    return WarrantyItem(
      id: id,
      receiptId: json['receiptId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      itemDescription: json['itemDescription'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      purchaseDate:
          (json['purchaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      returnDeadline:
          (json['returnDeadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      warrantyExpiry: (json['warrantyExpiry'] as Timestamp?)?.toDate(),
      merchantName: json['merchantName'] as String?,
      isReturned: json['isReturned'] as bool? ?? false,
      isExpired: json['isExpired'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'receiptId': receiptId,
        'userId': userId,
        'itemDescription': itemDescription,
        'category': category,
        'price': price,
        'purchaseDate': Timestamp.fromDate(purchaseDate),
        'returnDeadline': Timestamp.fromDate(returnDeadline),
        'warrantyExpiry':
            warrantyExpiry != null ? Timestamp.fromDate(warrantyExpiry!) : null,
        'merchantName': merchantName,
        'isReturned': isReturned,
        'isExpired': isExpired,
      };

  /// Days remaining until return deadline
  int get daysUntilReturnDeadline {
    final now = DateTime.now();
    return returnDeadline.difference(now).inDays;
  }

  /// Days remaining until warranty expires
  int? get daysUntilWarrantyExpiry {
    if (warrantyExpiry == null) return null;
    final now = DateTime.now();
    return warrantyExpiry!.difference(now).inDays;
  }

  /// Check if return window is still open
  bool get canStillReturn =>
      !isReturned && daysUntilReturnDeadline >= 0;

  /// Check if warranty is still valid
  bool get hasValidWarranty =>
      warrantyExpiry != null && (daysUntilWarrantyExpiry ?? -1) >= 0;
}

/// Service for tracking warranty items
class WarrantyService {
  final FirebaseFirestore _firestore;

  static const _returnPeriodDays = 14;
  static const _electronicsWarrantyYears = 2;
  static const _fashionWarrantyMonths = 6;

  /// Categories that qualify for warranty tracking
  static const _warrantyCategories = ['electronics', 'fashion'];

  WarrantyService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _warrantyCollection =>
      _firestore.collection('warranty_items');

  /// Tracks warranty items from a receipt
  /// Filters items in Electronics or Fashion categories
  /// Creates warranty records with return deadline and warranty expiry
  Future<List<WarrantyItem>> trackWarrantyItems(Receipt receipt) async {
    try {
      // 1. Filter eligible items
      final eligibleItems = _filterWarrantyEligibleItems(receipt.receiptData.items);
      if (eligibleItems.isEmpty) {
        debugPrint('WarrantyService: No warranty-eligible items found');
        return [];
      }

      // 2. Parse purchase date
      final purchaseDate = _parsePurchaseDate(receipt.receiptData.transaction.date);

      // 3. Create warranty items
      final warrantyItems = <WarrantyItem>[];
      for (final item in eligibleItems) {
        final warrantyItem = _createWarrantyItem(
          item: item,
          receipt: receipt,
          purchaseDate: purchaseDate,
        );

        // Save to Firestore
        final docRef = await _warrantyCollection.add(warrantyItem.toJson());
        warrantyItems.add(WarrantyItem.fromJson(warrantyItem.toJson(), docRef.id));

        debugPrint('WarrantyService: Tracked ${item.description}');
      }

      return warrantyItems;
    } catch (e) {
      debugPrint('WarrantyService.trackWarrantyItems error: $e');
      rethrow;
    }
  }

  /// Filters items that qualify for warranty tracking
  List<LineItem> _filterWarrantyEligibleItems(List<LineItem> items) {
    return items
        .where((item) =>
            _warrantyCategories.contains(item.category.toLowerCase()) &&
            !item.isPfand)
        .toList();
  }

  /// Creates a warranty item record
  WarrantyItem _createWarrantyItem({
    required LineItem item,
    required Receipt receipt,
    required DateTime purchaseDate,
  }) {
    final returnDeadline = purchaseDate.add(const Duration(days: _returnPeriodDays));

    // Electronics get 2-year warranty, Fashion gets 6 months
    DateTime? warrantyExpiry;
    if (item.category.toLowerCase() == 'electronics') {
      warrantyExpiry = DateTime(
        purchaseDate.year + _electronicsWarrantyYears,
        purchaseDate.month,
        purchaseDate.day,
      );
    } else if (item.category.toLowerCase() == 'fashion') {
      warrantyExpiry = DateTime(
        purchaseDate.year,
        purchaseDate.month + _fashionWarrantyMonths,
        purchaseDate.day,
      );
    }

    return WarrantyItem(
      id: '',
      receiptId: receipt.receiptId,
      userId: receipt.userId,
      itemDescription: item.description,
      category: item.category,
      price: item.totalPrice,
      purchaseDate: purchaseDate,
      returnDeadline: returnDeadline,
      warrantyExpiry: warrantyExpiry,
      merchantName: receipt.receiptData.merchant.name,
    );
  }

  /// Parses purchase date from receipt date string
  DateTime _parsePurchaseDate(String dateStr) {
    try {
      // Expected format: YYYY-MM-DD
      return DateTime.parse(dateStr);
    } catch (e) {
      debugPrint('WarrantyService: Could not parse date $dateStr, using now');
      return DateTime.now();
    }
  }

  /// Gets all warranty items for a user
  Future<List<WarrantyItem>> getWarrantyItems(String userId) async {
    final snapshot = await _warrantyCollection
        .where('userId', isEqualTo: userId)
        .orderBy('returnDeadline', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => WarrantyItem.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Gets items with upcoming return deadlines (within 7 days)
  Future<List<WarrantyItem>> getUpcomingReturns(String userId) async {
    final items = await getWarrantyItems(userId);
    return items
        .where((item) =>
            item.canStillReturn && item.daysUntilReturnDeadline <= 7)
        .toList();
  }

  /// Marks an item as returned
  Future<void> markAsReturned(String itemId) async {
    await _warrantyCollection.doc(itemId).update({
      'isReturned': true,
    });
  }

  /// Stream of warranty items for real-time updates
  Stream<List<WarrantyItem>> watchWarrantyItems(String userId) {
    return _warrantyCollection
        .where('userId', isEqualTo: userId)
        .orderBy('returnDeadline')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WarrantyItem.fromJson(doc.data(), doc.id))
            .toList());
  }
}

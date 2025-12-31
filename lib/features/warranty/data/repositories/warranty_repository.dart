import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Repository for warranty items with Firestore
class WarrantyRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WarrantyRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _warrantyCollection =>
      _firestore.collection('warranty_items');

  /// Stream of user's warranty items
  Stream<List<WarrantyItem>> watchWarrantyItems() {
    final userId = _userId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _warrantyCollection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .orderBy('returnDeadline', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WarrantyItem.fromFirestore(doc);
      }).toList();
    });
  }

  /// Get items with upcoming return deadlines
  Future<List<WarrantyItem>> getUpcomingReturns({int daysAhead = 7}) async {
    final userId = _userId;
    if (userId == null) return [];

    final now = DateTime.now();
    final deadline = now.add(Duration(days: daysAhead));

    try {
      final snapshot = await _warrantyCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .where('returnDeadline', isLessThanOrEqualTo: Timestamp.fromDate(deadline))
          .where('returnDeadline', isGreaterThan: Timestamp.fromDate(now))
          .get();

      return snapshot.docs.map((doc) {
        return WarrantyItem.fromFirestore(doc);
      }).toList();
    } catch (e) {
      debugPrint('WarrantyRepository.getUpcomingReturns error: $e');
      return [];
    }
  }

  /// Mark item as returned
  Future<void> markAsReturned(String warrantyId) async {
    await _warrantyCollection.doc(warrantyId).update({
      'status': 'returned',
      'returnedAt': Timestamp.now(),
    });
  }

  /// Delete warranty item
  Future<void> deleteWarrantyItem(String warrantyId) async {
    await _warrantyCollection.doc(warrantyId).delete();
  }

  /// Create warranty item from receipt
  Future<String> createWarrantyItem({
    required String itemDescription,
    required String category,
    required String receiptId,
    required DateTime purchaseDate,
    int returnDays = 14,
    int warrantyYears = 2,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final docRef = await _warrantyCollection.add({
      'userId': userId,
      'receiptId': receiptId,
      'itemDescription': itemDescription,
      'category': category,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'returnDeadline': Timestamp.fromDate(purchaseDate.add(Duration(days: returnDays))),
      'warrantyExpiry': Timestamp.fromDate(
        DateTime(purchaseDate.year + warrantyYears, purchaseDate.month, purchaseDate.day),
      ),
      'status': 'active',
      'createdAt': Timestamp.now(),
    });

    return docRef.id;
  }
}

/// Model for warranty item
class WarrantyItem {
  final String warrantyId;
  final String userId;
  final String receiptId;
  final String itemDescription;
  final String category;
  final DateTime purchaseDate;
  final DateTime returnDeadline;
  final DateTime? warrantyExpiry;
  final String status;

  WarrantyItem({
    required this.warrantyId,
    required this.userId,
    required this.receiptId,
    required this.itemDescription,
    required this.category,
    required this.purchaseDate,
    required this.returnDeadline,
    this.warrantyExpiry,
    required this.status,
  });

  factory WarrantyItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return WarrantyItem(
      warrantyId: doc.id,
      userId: data['userId'] as String,
      receiptId: data['receiptId'] as String,
      itemDescription: data['itemDescription'] as String,
      category: data['category'] as String? ?? 'Other',
      purchaseDate: (data['purchaseDate'] as Timestamp).toDate(),
      returnDeadline: (data['returnDeadline'] as Timestamp).toDate(),
      warrantyExpiry: data['warrantyExpiry'] != null
          ? (data['warrantyExpiry'] as Timestamp).toDate()
          : null,
      status: data['status'] as String? ?? 'active',
    );
  }

  int get daysUntilReturnDeadline {
    return returnDeadline.difference(DateTime.now()).inDays;
  }

  int? get daysUntilWarrantyExpiry {
    if (warrantyExpiry == null) return null;
    return warrantyExpiry!.difference(DateTime.now()).inDays;
  }

  bool get isReturnDeadlinePassed => daysUntilReturnDeadline < 0;
  bool get isWarrantyExpired => daysUntilWarrantyExpiry != null && daysUntilWarrantyExpiry! < 0;
}

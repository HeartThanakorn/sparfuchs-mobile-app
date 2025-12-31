import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:sparfuchs_ai/core/models/receipt.dart';

/// Repository for Receipt CRUD operations with Firestore and Storage
class ReceiptRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  ReceiptRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Collection reference
  CollectionReference<Map<String, dynamic>> get _receiptsCollection =>
      _firestore.collection('receipts');

  /// Stream of user's receipts (sorted by date descending)
  Stream<List<Receipt>> watchReceipts({String? householdId}) {
    final userId = _userId;
    if (userId == null) {
      return Stream.value([]);
    }

    Query<Map<String, dynamic>> query;

    if (householdId != null) {
      // Get household receipts
      query = _receiptsCollection
          .where('householdId', isEqualTo: householdId)
          .orderBy('createdAt', descending: true);
    } else {
      // Get user's personal receipts
      query = _receiptsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['receiptId'] = doc.id;
        return Receipt.fromJson(_convertTimestamps(data));
      }).toList();
    });
  }

  /// Get a single receipt by ID
  Future<Receipt?> getReceipt(String receiptId) async {
    try {
      final doc = await _receiptsCollection.doc(receiptId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['receiptId'] = doc.id;
      return Receipt.fromJson(_convertTimestamps(data));
    } catch (e) {
      debugPrint('ReceiptRepository.getReceipt error: $e');
      return null;
    }
  }

  /// Upload receipt image to Firebase Storage
  Future<String> uploadReceiptImage(File imageFile) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final ref = _storage.ref().child('users/$userId/receipts/$fileName');

    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Save receipt image locally on device (Fallback)
  Future<String> saveImageLocally(File imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
    final savedImage = await imageFile.copy('${appDir.path}/$fileName');
    return savedImage.path;
  }

  /// Save a new receipt
  Future<String> saveReceipt({
    required ReceiptData receiptData,
    required String imageUrl,
    String? householdId,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final now = DateTime.now();
    final docRef = await _receiptsCollection.add({
      'userId': userId,
      'householdId': householdId,
      'imageUrl': imageUrl,
      'isBookmarked': false,
      'receiptData': receiptData.toJson(),
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    debugPrint('ReceiptRepository: Saved receipt ${docRef.id}');
    return docRef.id;
  }

  /// Update receipt data
  Future<void> updateReceipt(String receiptId, ReceiptData receiptData) async {
    await _receiptsCollection.doc(receiptId).update({
      'receiptData': receiptData.toJson(),
      'updatedAt': Timestamp.now(),
    });
  }

  /// Toggle bookmark status
  Future<void> toggleBookmark(String receiptId, bool isBookmarked) async {
    await _receiptsCollection.doc(receiptId).update({
      'isBookmarked': isBookmarked,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Delete a receipt
  Future<void> deleteReceipt(String receiptId) async {
    await _receiptsCollection.doc(receiptId).delete();
  }

  /// Search receipts by merchant or item description
  Future<List<Receipt>> searchReceipts(String query) async {
    final userId = _userId;
    if (userId == null) return [];

    // Get all user receipts and filter client-side
    // (Firestore doesn't support full-text search)
    final snapshot = await _receiptsCollection
        .where('userId', isEqualTo: userId)
        .get();

    final lowerQuery = query.toLowerCase();
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          data['receiptId'] = doc.id;
          return Receipt.fromJson(_convertTimestamps(data));
        })
        .where((receipt) {
          final merchantMatch = receipt.receiptData.merchant.name
              .toLowerCase()
              .contains(lowerQuery);
          final itemMatch = receipt.receiptData.items.any(
              (item) => item.description.toLowerCase().contains(lowerQuery));
          return merchantMatch || itemMatch;
        })
        .toList();
  }

  /// Convert Firestore Timestamps to ISO strings
  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) {
        return MapEntry(key, value.toDate().toIso8601String());
      } else if (value is Map<String, dynamic>) {
        return MapEntry(key, _convertTimestamps(value));
      } else if (value is List) {
        return MapEntry(
          key,
          value.map((item) {
            if (item is Map<String, dynamic>) {
              return _convertTimestamps(item);
            } else if (item is Timestamp) {
              return item.toDate().toIso8601String();
            }
            return item;
          }).toList(),
        );
      }
      return MapEntry(key, value);
    });
  }
}

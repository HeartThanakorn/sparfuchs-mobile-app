import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Repository for product price history (Inflation Tracker)
class ProductRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProductRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection('products');

  /// Stream of tracked products with price history
  Stream<List<TrackedProduct>> watchTrackedProducts() {
    final userId = _userId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _productsCollection
        .where('trackedBy', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TrackedProduct.fromFirestore(doc);
      }).toList();
    });
  }

  /// Get trending products (biggest price changes)
  Future<List<TrackedProduct>> getTrendingProducts({int limit = 10}) async {
    try {
      final snapshot = await _productsCollection
          .orderBy('priceChangePercent', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return TrackedProduct.fromFirestore(doc);
      }).toList();
    } catch (e) {
      debugPrint('ProductRepository.getTrendingProducts error: $e');
      return [];
    }
  }

  /// Get price history for a product
  Future<List<PricePoint>> getPriceHistory(String productId) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (!doc.exists) return [];

      final data = doc.data()!;
      final history = data['priceHistory'] as List<dynamic>? ?? [];

      return history.map((item) {
        return PricePoint(
          date: (item['date'] as Timestamp).toDate(),
          price: (item['price'] as num).toDouble(),
          merchant: item['merchant'] as String,
        );
      }).toList();
    } catch (e) {
      debugPrint('ProductRepository.getPriceHistory error: $e');
      return [];
    }
  }

  /// Track a product for price alerts
  Future<void> trackProduct(String productId) async {
    final userId = _userId;
    if (userId == null) return;

    await _productsCollection.doc(productId).update({
      'trackedBy': FieldValue.arrayUnion([userId]),
    });
  }

  /// Untrack a product
  Future<void> untrackProduct(String productId) async {
    final userId = _userId;
    if (userId == null) return;

    await _productsCollection.doc(productId).update({
      'trackedBy': FieldValue.arrayRemove([userId]),
    });
  }

  /// Add price point from scanned receipt
  Future<void> addPricePoint({
    required String normalizedName,
    required double price,
    required String merchant,
    required String receiptId,
  }) async {
    final productId = _normalizeProductId(normalizedName);

    final docRef = _productsCollection.doc(productId);
    final doc = await docRef.get();

    final pricePoint = {
      'date': Timestamp.now(),
      'price': price,
      'merchant': merchant,
      'receiptId': receiptId,
    };

    if (doc.exists) {
      // Update existing product
      final data = doc.data()!;
      final oldPrice = data['latestPrice'] as double? ?? price;
      final changePercent = ((price - oldPrice) / oldPrice * 100);

      await docRef.update({
        'priceHistory': FieldValue.arrayUnion([pricePoint]),
        'latestPrice': price,
        'priceChangePercent': changePercent,
        'updatedAt': Timestamp.now(),
      });
    } else {
      // Create new product
      await docRef.set({
        'normalizedName': normalizedName,
        'latestPrice': price,
        'priceChangePercent': 0.0,
        'priceHistory': [pricePoint],
        'trackedBy': [],
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    }
  }

  String _normalizeProductId(String name) {
    return name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
  }
}

/// Model for tracked product
class TrackedProduct {
  final String productId;
  final String name;
  final double latestPrice;
  final double priceChangePercent;
  final String? latestMerchant;

  TrackedProduct({
    required this.productId,
    required this.name,
    required this.latestPrice,
    required this.priceChangePercent,
    this.latestMerchant,
  });

  factory TrackedProduct.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final history = data['priceHistory'] as List<dynamic>? ?? [];
    String? latestMerchant;
    if (history.isNotEmpty) {
      latestMerchant = history.last['merchant'] as String?;
    }

    return TrackedProduct(
      productId: doc.id,
      name: data['normalizedName'] as String? ?? 'Unknown',
      latestPrice: (data['latestPrice'] as num?)?.toDouble() ?? 0.0,
      priceChangePercent: (data['priceChangePercent'] as num?)?.toDouble() ?? 0.0,
      latestMerchant: latestMerchant,
    );
  }
}

/// Model for price point
class PricePoint {
  final DateTime date;
  final double price;
  final String merchant;

  PricePoint({
    required this.date,
    required this.price,
    required this.merchant,
  });
}

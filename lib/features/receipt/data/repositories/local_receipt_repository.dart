import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/core/services/local_database_service.dart';

/// Local repository for Receipt CRUD operations using Hive
/// No authentication required - all data stored locally on device
class LocalReceiptRepository {
  final _uuid = const Uuid();

  /// Stream of all receipts (sorted by date descending)
  Stream<List<Receipt>> watchReceipts() {
    // Create a stream that emits current data and watches for changes
    return LocalDatabaseService.receiptsBox
        .watch()
        .map((_) => _getAllReceipts())
        .asyncMap((_) async => _getAllReceipts())
        .startWith(_getAllReceipts());
  }

  /// Get all receipts from local storage
  List<Receipt> _getAllReceipts() {
    final box = LocalDatabaseService.receiptsBox;
    final receipts = <Receipt>[];
    
    for (final key in box.keys) {
      try {
        final data = Map<String, dynamic>.from(box.get(key) as Map);
        data['receiptId'] = key.toString();
        receipts.add(Receipt.fromJson(_convertDates(data)));
      } catch (e) {
        debugPrint('Error parsing receipt $key: $e');
      }
    }
    
    // Sort by createdAt descending
    receipts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return receipts;
  }

  /// Get all receipts (one-time fetch)
  Future<List<Receipt>> getAllReceipts() async {
    return _getAllReceipts();
  }

  /// Get a single receipt by ID
  Future<Receipt?> getReceipt(String receiptId) async {
    try {
      final data = LocalDatabaseService.receiptsBox.get(receiptId);
      if (data == null) return null;

      final map = Map<String, dynamic>.from(data);
      map['receiptId'] = receiptId;
      return Receipt.fromJson(_convertDates(map));
    } catch (e) {
      debugPrint('LocalReceiptRepository.getReceipt error: $e');
      return null;
    }
  }

  /// Save receipt image locally
  Future<String> saveImageLocally(File imageFile) async {
    final imagesDir = await LocalDatabaseService.getImagesDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
    final savedImage = await imageFile.copy('${imagesDir.path}/$fileName');
    debugPrint('LocalReceiptRepository: Image saved to ${savedImage.path}');
    return savedImage.path;
  }

  /// Save a new receipt
  Future<String> saveReceipt({
    required ReceiptData receiptData,
    required String imageUrl,
    String? householdId,
  }) async {
    final receiptId = _uuid.v4();
    final now = DateTime.now();

    final data = {
      'userId': 'local_user', // No auth needed for local storage
      'householdId': householdId,
      'imageUrl': imageUrl,
      'isBookmarked': false,
      'receiptData': jsonDecode(jsonEncode(receiptData.toJson())),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };

    await LocalDatabaseService.receiptsBox.put(receiptId, data);
    debugPrint('LocalReceiptRepository: Saved receipt $receiptId');
    return receiptId;
  }

  /// Update receipt data
  Future<void> updateReceipt(String receiptId, ReceiptData receiptData) async {
    final existing = LocalDatabaseService.receiptsBox.get(receiptId);
    if (existing == null) {
      throw Exception('Receipt not found: $receiptId');
    }

    final data = Map<String, dynamic>.from(existing);
    data['receiptData'] = jsonDecode(jsonEncode(receiptData.toJson()));
    data['updatedAt'] = DateTime.now().toIso8601String();

    await LocalDatabaseService.receiptsBox.put(receiptId, data);
    debugPrint('LocalReceiptRepository: Updated receipt $receiptId');
  }

  /// Toggle bookmark status
  Future<void> toggleBookmark(String receiptId, bool isBookmarked) async {
    final existing = LocalDatabaseService.receiptsBox.get(receiptId);
    if (existing == null) return;

    final data = Map<String, dynamic>.from(existing);
    data['isBookmarked'] = isBookmarked;
    data['updatedAt'] = DateTime.now().toIso8601String();

    await LocalDatabaseService.receiptsBox.put(receiptId, data);
  }

  /// Delete a receipt
  Future<void> deleteReceipt(String receiptId) async {
    // Also delete the image file
    final existing = LocalDatabaseService.receiptsBox.get(receiptId);
    if (existing != null) {
      final imageUrl = existing['imageUrl'] as String?;
      if (imageUrl != null && imageUrl.startsWith('/')) {
        try {
          final file = File(imageUrl);
          if (await file.exists()) {
            await file.delete();
            debugPrint('LocalReceiptRepository: Deleted image $imageUrl');
          }
        } catch (e) {
          debugPrint('Error deleting image: $e');
        }
      }
    }

    await LocalDatabaseService.receiptsBox.delete(receiptId);
    debugPrint('LocalReceiptRepository: Deleted receipt $receiptId');
  }

  /// Search receipts by merchant or item description
  Future<List<Receipt>> searchReceipts(String query) async {
    final lowerQuery = query.toLowerCase();
    final allReceipts = _getAllReceipts();
    
    return allReceipts.where((receipt) {
      // Search in merchant name
      if (receipt.receiptData.merchant.name.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      // Search in item descriptions
      for (final item in receipt.receiptData.items) {
        if (item.description.toLowerCase().contains(lowerQuery)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  /// Convert ISO date strings back to proper format for parsing
  Map<String, dynamic> _convertDates(Map<String, dynamic> data) {
    // Handle createdAt
    if (data['createdAt'] is String) {
      // Already a string, keep it
    }
    // Handle updatedAt
    if (data['updatedAt'] is String) {
      // Already a string, keep it
    }
    return data;
  }
}

/// Extension to add startWith to Stream (for initial value emission)
extension StreamStartWith<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    await for (final item in this) {
      yield item;
    }
  }
}

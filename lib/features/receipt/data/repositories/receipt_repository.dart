import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';

/// Repository for managing receipt data and images
class ReceiptRepository {
  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;

  ReceiptRepository({
    FirebaseStorage? storage,
    FirebaseFirestore? firestore,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Collection reference for receipts
  CollectionReference<Map<String, dynamic>> get _receiptsCollection =>
      _firestore.collection('receipts');

  /// Uploads an image to Firebase Storage
  /// Returns the download URL of the uploaded image
  ///
  /// Path format: receipts/{userId}/{timestamp}.jpg
  Future<String> uploadImage({
    required File imageFile,
    required String userId,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$timestamp.jpg';
      final storagePath = 'receipts/$userId/$fileName';

      // Create storage reference
      final storageRef = _storage.ref().child(storagePath);

      // Set metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload file with progress tracking
      final uploadTask = storageRef.putFile(imageFile, metadata);

      // Listen to progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();

      debugPrint('ReceiptRepository.uploadImage: Uploaded to $storagePath');
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('ReceiptRepository.uploadImage error: ${e.code} - ${e.message}');
      throw ReceiptRepositoryException(
        'Bild konnte nicht hochgeladen werden: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      debugPrint('ReceiptRepository.uploadImage error: $e');
      throw ReceiptRepositoryException('Unbekannter Fehler beim Hochladen: $e');
    }
  }

  /// Saves a receipt to Firestore
  Future<void> saveReceipt(Receipt receipt) async {
    try {
      await _receiptsCollection.doc(receipt.receiptId).set(receipt.toJson());
      debugPrint('ReceiptRepository.saveReceipt: Saved ${receipt.receiptId}');
    } on FirebaseException catch (e) {
      debugPrint('ReceiptRepository.saveReceipt error: ${e.code} - ${e.message}');
      throw ReceiptRepositoryException(
        'Beleg konnte nicht gespeichert werden: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Gets a single receipt by ID
  Future<Receipt?> getReceipt(String receiptId) async {
    try {
      final doc = await _receiptsCollection.doc(receiptId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return Receipt.fromJson(doc.data()!);
    } on FirebaseException catch (e) {
      debugPrint('ReceiptRepository.getReceipt error: ${e.code} - ${e.message}');
      throw ReceiptRepositoryException(
        'Beleg konnte nicht geladen werden: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Gets all receipts for a user
  Future<List<Receipt>> getReceiptsForUser(String userId) async {
    try {
      final snapshot = await _receiptsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Receipt.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('ReceiptRepository.getReceiptsForUser error: ${e.code}');
      throw ReceiptRepositoryException(
        'Belege konnten nicht geladen werden: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Updates an existing receipt
  Future<void> updateReceipt(Receipt receipt) async {
    try {
      await _receiptsCollection.doc(receipt.receiptId).update(receipt.toJson());
      debugPrint('ReceiptRepository.updateReceipt: Updated ${receipt.receiptId}');
    } on FirebaseException catch (e) {
      debugPrint('ReceiptRepository.updateReceipt error: ${e.code}');
      throw ReceiptRepositoryException(
        'Beleg konnte nicht aktualisiert werden: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Deletes a receipt and its image
  Future<void> deleteReceipt(String receiptId) async {
    try {
      // Get receipt to find image URL
      final receipt = await getReceipt(receiptId);
      if (receipt != null && receipt.imageUrl.isNotEmpty) {
        // Delete image from storage
        try {
          await _storage.refFromURL(receipt.imageUrl).delete();
        } catch (e) {
          debugPrint('ReceiptRepository.deleteReceipt: Could not delete image: $e');
          // Continue with document deletion even if image deletion fails
        }
      }

      // Delete document from Firestore
      await _receiptsCollection.doc(receiptId).delete();
      debugPrint('ReceiptRepository.deleteReceipt: Deleted $receiptId');
    } on FirebaseException catch (e) {
      debugPrint('ReceiptRepository.deleteReceipt error: ${e.code}');
      throw ReceiptRepositoryException(
        'Beleg konnte nicht gelöscht werden: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Toggles the bookmark status of a receipt
  Future<void> toggleBookmark(String receiptId, bool isBookmarked) async {
    try {
      await _receiptsCollection.doc(receiptId).update({
        'isBookmarked': isBookmarked,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      debugPrint('ReceiptRepository.toggleBookmark error: ${e.code}');
      throw ReceiptRepositoryException(
        'Lesezeichen konnte nicht aktualisiert werden: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Stream of receipts for real-time updates
  Stream<List<Receipt>> watchReceiptsForUser(String userId) {
    return _receiptsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Receipt.fromJson(doc.data())).toList());
  }
}

/// Exception class for repository errors
class ReceiptRepositoryException implements Exception {
  final String message;
  final String? code;

  ReceiptRepositoryException(this.message, {this.code});

  @override
  String toString() => 'ReceiptRepositoryException: $message (code: $code)';
}

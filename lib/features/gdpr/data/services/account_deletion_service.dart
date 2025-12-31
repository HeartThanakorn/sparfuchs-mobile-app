import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Service for GDPR-compliant account deletion
class AccountDeletionService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  AccountDeletionService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Deletes all user data and the account itself
  /// 
  /// This is an irreversible operation that:
  /// 1. Removes user from all households
  /// 2. Deletes all user receipts
  /// 3. Deletes all warranty items
  /// 4. Deletes user profile and settings
  /// 5. Deletes all Storage files
  /// 6. Deletes the Firebase Auth account
  Future<void> deleteAccount(String userId) async {
    try {
      debugPrint('AccountDeletionService: Starting deletion for $userId');

      // 1. Remove user from households (and transfer ownership if needed)
      await _handleHouseholdsOnDeletion(userId);

      // 2. Delete all user receipts
      await _deleteCollection('receipts', userId);

      // 3. Delete all warranty items
      await _deleteCollection('warranty_items', userId);

      // 4. Delete user profile
      await _deleteDocument('users', userId);

      // 5. Delete user settings
      await _deleteDocument('user_settings', userId);

      // 6. Delete all Storage files
      await _deleteStorageFiles(userId);

      // 7. Delete Firebase Auth account
      await _deleteAuthAccount();

      debugPrint('AccountDeletionService: Deletion completed for $userId');
    } catch (e) {
      debugPrint('AccountDeletionService.deleteAccount error: $e');
      rethrow;
    }
  }

  /// Handles household cleanup before deletion
  Future<void> _handleHouseholdsOnDeletion(String userId) async {
    try {
      // Find all households where user is a member
      final householdsSnapshot = await _firestore
          .collection('households')
          .where('memberIds', arrayContains: userId)
          .get();

      for (final doc in householdsSnapshot.docs) {
        final data = doc.data();
        final memberIds = List<String>.from(data['memberIds'] ?? []);
        final ownerId = data['ownerId'] as String?;

        if (memberIds.length == 1) {
          // User is sole member - delete household
          await doc.reference.delete();
          debugPrint('AccountDeletionService: Deleted household ${doc.id}');
        } else {
          // Remove user from members
          memberIds.remove(userId);

          // Transfer ownership if user was owner
          String newOwnerId = ownerId ?? '';
          if (ownerId == userId && memberIds.isNotEmpty) {
            newOwnerId = memberIds.first;
          }

          await doc.reference.update({
            'memberIds': memberIds,
            'ownerId': newOwnerId,
          });
          debugPrint('AccountDeletionService: Removed from household ${doc.id}');
        }
      }
    } catch (e) {
      debugPrint('AccountDeletionService: Error handling households - $e');
      // Continue with deletion even if household cleanup fails
    }
  }

  /// Deletes all documents from a collection matching userId
  Future<void> _deleteCollection(String collection, String userId) async {
    try {
      final batch = _firestore.batch();
      int deleteCount = 0;

      final snapshot = await _firestore
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
        deleteCount++;

        // Commit in batches of 500 (Firestore limit)
        if (deleteCount % 500 == 0) {
          await batch.commit();
          debugPrint('AccountDeletionService: Committed batch of 500 from $collection');
        }
      }

      // Commit remaining
      if (deleteCount % 500 != 0) {
        await batch.commit();
      }

      debugPrint('AccountDeletionService: Deleted $deleteCount docs from $collection');
    } catch (e) {
      debugPrint('AccountDeletionService: Error deleting $collection - $e');
    }
  }

  /// Deletes a single document
  Future<void> _deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
      debugPrint('AccountDeletionService: Deleted $collection/$docId');
    } catch (e) {
      debugPrint('AccountDeletionService: Error deleting $collection/$docId - $e');
    }
  }

  /// Deletes all Storage files for a user
  Future<void> _deleteStorageFiles(String userId) async {
    try {
      // Delete receipt images folder
      final receiptsRef = _storage.ref('receipts/$userId');
      await _deleteStorageFolder(receiptsRef);

      // Delete user assets folder
      final assetsRef = _storage.ref('users/$userId');
      await _deleteStorageFolder(assetsRef);

      debugPrint('AccountDeletionService: Deleted Storage files');
    } catch (e) {
      debugPrint('AccountDeletionService: Error deleting Storage - $e');
    }
  }

  /// Recursively deletes a Storage folder
  Future<void> _deleteStorageFolder(Reference folderRef) async {
    try {
      final result = await folderRef.listAll();

      // Delete all files
      for (final fileRef in result.items) {
        await fileRef.delete();
      }

      // Recursively delete subfolders
      for (final prefixRef in result.prefixes) {
        await _deleteStorageFolder(prefixRef);
      }
    } catch (e) {
      // Folder may not exist, which is fine
      debugPrint('AccountDeletionService: Folder not found or error - $e');
    }
  }

  /// Deletes the Firebase Auth account
  Future<void> _deleteAuthAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        debugPrint('AccountDeletionService: Deleted Auth account');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw AccountDeletionException(
          'Bitte erneut anmelden vor der Löschung',
          code: 'requires_reauthentication',
        );
      }
      rethrow;
    }
  }

  /// Confirms deletion is allowed (for UI confirmation)
  Future<DeletionPreview> previewDeletion(String userId) async {
    int receiptCount = 0;
    int warrantyCount = 0;
    int householdCount = 0;

    try {
      final receiptsSnapshot = await _firestore
          .collection('receipts')
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      receiptCount = receiptsSnapshot.count ?? 0;

      final warrantySnapshot = await _firestore
          .collection('warranty_items')
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      warrantyCount = warrantySnapshot.count ?? 0;

      final householdsSnapshot = await _firestore
          .collection('households')
          .where('memberIds', arrayContains: userId)
          .count()
          .get();
      householdCount = householdsSnapshot.count ?? 0;
    } catch (e) {
      debugPrint('AccountDeletionService: Error getting preview - $e');
    }

    return DeletionPreview(
      receiptCount: receiptCount,
      warrantyCount: warrantyCount,
      householdCount: householdCount,
    );
  }
}

/// Preview of data to be deleted
class DeletionPreview {
  final int receiptCount;
  final int warrantyCount;
  final int householdCount;

  const DeletionPreview({
    required this.receiptCount,
    required this.warrantyCount,
    required this.householdCount,
  });

  int get totalItems => receiptCount + warrantyCount;
}

/// Exception for account deletion errors
class AccountDeletionException implements Exception {
  final String message;
  final String? code;

  AccountDeletionException(this.message, {this.code});

  @override
  String toString() => 'AccountDeletionException: $message (code: $code)';
}

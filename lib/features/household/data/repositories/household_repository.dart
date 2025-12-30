import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Model for a household
class Household {
  final String id;
  final String name;
  final String joinCode;
  final String ownerId;
  final List<String> memberIds;
  final DateTime createdAt;

  const Household({
    required this.id,
    required this.name,
    required this.joinCode,
    required this.ownerId,
    required this.memberIds,
    required this.createdAt,
  });

  factory Household.fromJson(Map<String, dynamic> json, String id) {
    return Household(
      id: id,
      name: json['name'] as String? ?? '',
      joinCode: json['joinCode'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      memberIds: (json['memberIds'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'joinCode': joinCode,
        'ownerId': ownerId,
        'memberIds': memberIds,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  Household copyWith({
    String? id,
    String? name,
    String? joinCode,
    String? ownerId,
    List<String>? memberIds,
    DateTime? createdAt,
  }) {
    return Household(
      id: id ?? this.id,
      name: name ?? this.name,
      joinCode: joinCode ?? this.joinCode,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Repository for managing household operations
class HouseholdRepository {
  final FirebaseFirestore _firestore;

  HouseholdRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _householdsCollection =>
      _firestore.collection('households');

  /// Creates a new household with the given name
  /// Returns the created household
  Future<Household> createHousehold({
    required String name,
    required String userId,
  }) async {
    try {
      final joinCode = _generateJoinCode();

      final household = Household(
        id: '', // Will be set after creation
        name: name,
        joinCode: joinCode,
        ownerId: userId,
        memberIds: [userId],
        createdAt: DateTime.now(),
      );

      final docRef = await _householdsCollection.add(household.toJson());

      debugPrint('HouseholdRepository.createHousehold: Created ${docRef.id}');
      return household.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      debugPrint('HouseholdRepository.createHousehold error: ${e.code}');
      throw HouseholdRepositoryException(
        'Haushalt konnte nicht erstellt werden: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Joins an existing household using the invite code
  Future<Household> joinHousehold({
    required String joinCode,
    required String userId,
  }) async {
    try {
      // Find household by join code
      final snapshot = await _householdsCollection
          .where('joinCode', isEqualTo: joinCode.toUpperCase())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw HouseholdRepositoryException(
          'Kein Haushalt mit diesem Code gefunden',
          code: 'not-found',
        );
      }

      final doc = snapshot.docs.first;
      final household = Household.fromJson(doc.data(), doc.id);

      // Check if already a member
      if (household.memberIds.contains(userId)) {
        throw HouseholdRepositoryException(
          'Du bist bereits Mitglied dieses Haushalts',
          code: 'already-member',
        );
      }

      // Add user to members
      await doc.reference.update({
        'memberIds': FieldValue.arrayUnion([userId]),
      });

      debugPrint('HouseholdRepository.joinHousehold: $userId joined ${doc.id}');
      return household.copyWith(
        memberIds: [...household.memberIds, userId],
      );
    } on HouseholdRepositoryException {
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint('HouseholdRepository.joinHousehold error: ${e.code}');
      throw HouseholdRepositoryException(
        'Haushalt konnte nicht beigetreten werden: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Leaves the current household
  /// If user is owner, transfers ownership or deletes household
  Future<void> leaveHousehold({
    required String householdId,
    required String userId,
  }) async {
    try {
      final doc = await _householdsCollection.doc(householdId).get();
      if (!doc.exists) {
        throw HouseholdRepositoryException(
          'Haushalt nicht gefunden',
          code: 'not-found',
        );
      }

      final household = Household.fromJson(doc.data()!, doc.id);

      if (household.memberIds.length == 1) {
        // Last member - delete household
        await doc.reference.delete();
        debugPrint('HouseholdRepository.leaveHousehold: Deleted $householdId');
      } else if (household.ownerId == userId) {
        // Owner leaving - transfer to next member
        final newOwner = household.memberIds.firstWhere((id) => id != userId);
        await doc.reference.update({
          'memberIds': FieldValue.arrayRemove([userId]),
          'ownerId': newOwner,
        });
        debugPrint(
            'HouseholdRepository.leaveHousehold: Transferred ownership to $newOwner');
      } else {
        // Regular member leaving
        await doc.reference.update({
          'memberIds': FieldValue.arrayRemove([userId]),
        });
        debugPrint('HouseholdRepository.leaveHousehold: $userId left $householdId');
      }
    } on HouseholdRepositoryException {
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint('HouseholdRepository.leaveHousehold error: ${e.code}');
      throw HouseholdRepositoryException(
        'Haushalt konnte nicht verlassen werden: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Gets a household by ID
  Future<Household?> getHousehold(String householdId) async {
    try {
      final doc = await _householdsCollection.doc(householdId).get();
      if (!doc.exists || doc.data() == null) return null;
      return Household.fromJson(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      debugPrint('HouseholdRepository.getHousehold error: ${e.code}');
      throw HouseholdRepositoryException(
        'Haushalt konnte nicht geladen werden: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Watches a household for real-time updates
  Stream<Household?> watchHousehold(String householdId) {
    return _householdsCollection.doc(householdId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Household.fromJson(doc.data()!, doc.id);
    });
  }

  /// Regenerates the join code for a household (owner only)
  Future<String> regenerateJoinCode({
    required String householdId,
    required String userId,
  }) async {
    try {
      final doc = await _householdsCollection.doc(householdId).get();
      if (!doc.exists) {
        throw HouseholdRepositoryException(
          'Haushalt nicht gefunden',
          code: 'not-found',
        );
      }

      final household = Household.fromJson(doc.data()!, doc.id);
      if (household.ownerId != userId) {
        throw HouseholdRepositoryException(
          'Nur der Besitzer kann den Code erneuern',
          code: 'permission-denied',
        );
      }

      final newCode = _generateJoinCode();
      await doc.reference.update({'joinCode': newCode});

      debugPrint('HouseholdRepository.regenerateJoinCode: New code for $householdId');
      return newCode;
    } on HouseholdRepositoryException {
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint('HouseholdRepository.regenerateJoinCode error: ${e.code}');
      throw HouseholdRepositoryException(
        'Code konnte nicht erneuert werden: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Generates a unique 8-character invite code
  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Excluded I, O, 0, 1
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }
}

/// Exception class for repository errors
class HouseholdRepositoryException implements Exception {
  final String message;
  final String? code;

  HouseholdRepositoryException(this.message, {this.code});

  @override
  String toString() => 'HouseholdRepositoryException: $message (code: $code)';
}

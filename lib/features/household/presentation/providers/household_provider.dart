import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparfuchs_ai/core/providers/user_provider.dart';
import 'package:sparfuchs_ai/features/receipt/presentation/providers/receipt_provider.dart';

/// Household model
class Household {
  final String id;
  final String name;
  final List<String> memberIds;
  final String ownerId;
  final DateTime createdAt;

  const Household({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.ownerId,
    required this.createdAt,
  });

  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      memberIds: (json['memberIds'] as List<dynamic>?)?.cast<String>() ?? [],
      ownerId: json['ownerId'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'memberIds': memberIds,
    'ownerId': ownerId,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

/// StreamProvider for current user's household
final householdProvider = StreamProvider<Household?>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) {
    return Stream.value(null);
  }

  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('households')
      .where('memberIds', arrayContains: userId)
      .limit(1)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;
        final doc = snapshot.docs.first;
        return Household.fromJson(doc.data()..['id'] = doc.id);
      });
});

/// Provider for household members count
final householdMemberCountProvider = Provider<int>((ref) {
  final asyncHousehold = ref.watch(householdProvider);
  return asyncHousehold.maybeWhen(
    data: (household) => household?.memberIds.length ?? 0,
    orElse: () => 0,
  );
});

/// Provider for checking if user is household owner
final isHouseholdOwnerProvider = Provider<bool>((ref) {
  final userId = ref.watch(userIdProvider);
  final asyncHousehold = ref.watch(householdProvider);
  return asyncHousehold.maybeWhen(
    data: (household) => household?.ownerId == userId,
    orElse: () => false,
  );
});

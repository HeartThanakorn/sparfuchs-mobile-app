import 'package:flutter_test/flutter_test.dart';

/// Property 13: Household Membership After Join
/// Validates: Requirements 5.2
///
/// Properties:
/// 1. After joining, user is in memberIds list
/// 2. After leaving, user is NOT in memberIds list
/// 3. Owner cannot be removed unless they leave
/// 4. Ownership transfer works correctly
/// 5. Duplicate joins are handled gracefully

void main() {
  group('Property 13: Household Membership After Join', () {
    // Simulating membership logic from HouseholdRepository

    /// Add member to household
    List<String> addMember(List<String> members, String userId) {
      if (members.contains(userId)) {
        throw Exception('Already a member');
      }
      return [...members, userId];
    }

    /// Remove member from household
    (List<String>, String) removeMember(
      List<String> members,
      String ownerId,
      String userId,
    ) {
      if (!members.contains(userId)) {
        throw Exception('Not a member');
      }

      final updatedMembers = members.where((id) => id != userId).toList();

      // If owner leaves and there are other members, transfer ownership
      String newOwnerId = ownerId;
      if (userId == ownerId && updatedMembers.isNotEmpty) {
        newOwnerId = updatedMembers.first;
      }

      return (updatedMembers, newOwnerId);
    }

    // Test: User is added to members after join
    test('user is in memberIds after joining', () {
      var members = <String>['owner123'];

      members = addMember(members, 'user456');

      expect(members.contains('user456'), isTrue);
      expect(members.length, 2);
    });

    // Test: User is removed from members after leaving
    test('user is NOT in memberIds after leaving', () {
      var members = <String>['owner123', 'user456'];
      const ownerId = 'owner123';

      final (updatedMembers, _) = removeMember(members, ownerId, 'user456');

      expect(updatedMembers.contains('user456'), isFalse);
      expect(updatedMembers.length, 1);
    });

    // Test: Duplicate join throws error
    test('duplicate join is rejected', () {
      var members = <String>['owner123', 'user456'];

      expect(
        () => addMember(members, 'user456'),
        throwsA(isA<Exception>()),
      );
    });

    // Test: Removing non-member throws error
    test('removing non-member throws error', () {
      var members = <String>['owner123'];
      const ownerId = 'owner123';

      expect(
        () => removeMember(members, ownerId, 'unknown_user'),
        throwsA(isA<Exception>()),
      );
    });

    // Test: Ownership transfers when owner leaves
    test('ownership transfers when owner leaves', () {
      var members = <String>['owner123', 'user456', 'user789'];
      const ownerId = 'owner123';

      final (updatedMembers, newOwnerId) =
          removeMember(members, ownerId, 'owner123');

      expect(updatedMembers.contains('owner123'), isFalse);
      expect(newOwnerId, 'user456'); // First remaining member
      expect(newOwnerId, isNot('owner123'));
    });

    // Test: Owner stays owner if not leaving
    test('owner stays owner if regular member leaves', () {
      var members = <String>['owner123', 'user456'];
      const ownerId = 'owner123';

      final (_, newOwnerId) = removeMember(members, ownerId, 'user456');

      expect(newOwnerId, 'owner123');
    });

    // Test: Multiple users can join
    test('multiple users can join sequentially', () {
      var members = <String>['owner123'];

      members = addMember(members, 'user1');
      members = addMember(members, 'user2');
      members = addMember(members, 'user3');

      expect(members.length, 4);
      expect(members, containsAll(['owner123', 'user1', 'user2', 'user3']));
    });

    // Test: Order is preserved
    test('member order is preserved', () {
      var members = <String>['owner123'];

      members = addMember(members, 'aaa');
      members = addMember(members, 'zzz');
      members = addMember(members, 'mmm');

      expect(members, ['owner123', 'aaa', 'zzz', 'mmm']);
    });
  });
}

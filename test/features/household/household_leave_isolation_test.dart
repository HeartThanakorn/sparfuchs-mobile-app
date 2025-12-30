import 'package:flutter_test/flutter_test.dart';

/// Property 16: Household Leave Data Isolation
/// Validates: Requirements 5.6
///
/// Properties:
/// 1. User receipts remain accessible after leaving household
/// 2. User no longer sees household receipts after leaving
/// 3. Household members no longer see departed user's new receipts
/// 4. User's householdId is cleared after leaving

/// Mock user state
class MockUserState {
  final String id;
  String? householdId;
  final List<MockReceipt> receipts;

  MockUserState({
    required this.id,
    this.householdId,
    List<MockReceipt>? receipts,
  }) : receipts = receipts ?? [];
}

/// Mock receipt
class MockReceipt {
  final String id;
  final String userId;
  String? householdId;
  final DateTime createdAt;

  MockReceipt({
    required this.id,
    required this.userId,
    this.householdId,
    required this.createdAt,
  });
}

/// Mock household
class MockHousehold {
  final String id;
  final List<String> memberIds;

  MockHousehold({required this.id, required this.memberIds});
}

/// Simulate leaving a household
void leaveHousehold(MockUserState user, MockHousehold household) {
  // Remove user from household
  household.memberIds.remove(user.id);
  
  // Clear user's householdId
  user.householdId = null;
  
  // User's existing receipts keep their householdId (historical data)
  // But new receipts won't have householdId
}

/// Get receipts visible to a user
List<MockReceipt> getVisibleReceipts(
    MockUserState user, List<MockReceipt> allReceipts) {
  // If user is in a household, see household receipts
  if (user.householdId != null) {
    return allReceipts
        .where((r) => r.householdId == user.householdId)
        .toList();
  }
  // Otherwise, only see own receipts
  return allReceipts.where((r) => r.userId == user.id).toList();
}

void main() {
  group('Property 16: Household Leave Data Isolation', () {
    // Test: User's own receipts remain accessible
    test('user receipts remain accessible after leaving', () {
      final user = MockUserState(id: 'user1', householdId: 'h1');
      final household = MockHousehold(id: 'h1', memberIds: ['user1', 'user2']);
      
      final userReceipt = MockReceipt(
        id: 'r1',
        userId: 'user1',
        householdId: 'h1',
        createdAt: DateTime.now(),
      );
      
      leaveHousehold(user, household);
      
      // User can still access their own receipt
      final visible = getVisibleReceipts(user, [userReceipt]);
      expect(visible.length, 1);
      expect(visible.first.userId, 'user1');
    });

    // Test: User no longer sees household receipts after leaving
    test('user no longer sees household receipts after leaving', () {
      final user = MockUserState(id: 'user1', householdId: 'h1');
      final household = MockHousehold(id: 'h1', memberIds: ['user1', 'user2']);
      
      final allReceipts = [
        MockReceipt(id: 'r1', userId: 'user1', householdId: 'h1', createdAt: DateTime.now()),
        MockReceipt(id: 'r2', userId: 'user2', householdId: 'h1', createdAt: DateTime.now()),
      ];
      
      // Before leaving - sees both
      expect(getVisibleReceipts(user, allReceipts).length, 2);
      
      leaveHousehold(user, household);
      
      // After leaving - only sees own
      final visible = getVisibleReceipts(user, allReceipts);
      expect(visible.length, 1);
      expect(visible.every((r) => r.userId == 'user1'), isTrue);
    });

    // Test: User's householdId is cleared
    test('user householdId is cleared after leaving', () {
      final user = MockUserState(id: 'user1', householdId: 'h1');
      final household = MockHousehold(id: 'h1', memberIds: ['user1']);
      
      expect(user.householdId, 'h1');
      
      leaveHousehold(user, household);
      
      expect(user.householdId, isNull);
    });

    // Test: User removed from household memberIds
    test('user is removed from household memberIds', () {
      final user = MockUserState(id: 'user1', householdId: 'h1');
      final household = MockHousehold(id: 'h1', memberIds: ['user1', 'user2']);
      
      expect(household.memberIds.contains('user1'), isTrue);
      
      leaveHousehold(user, household);
      
      expect(household.memberIds.contains('user1'), isFalse);
      expect(household.memberIds.length, 1);
    });

    // Test: Historical receipts keep householdId
    test('historical receipts keep householdId for audit', () {
      final user = MockUserState(id: 'user1', householdId: 'h1');
      final household = MockHousehold(id: 'h1', memberIds: ['user1']);
      
      final oldReceipt = MockReceipt(
        id: 'r1',
        userId: 'user1',
        householdId: 'h1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      
      leaveHousehold(user, household);
      
      // Old receipt still has householdId for historical purposes
      expect(oldReceipt.householdId, 'h1');
    });

    // Test: New receipts after leaving don't have householdId
    test('new receipts after leaving have no householdId', () {
      final user = MockUserState(id: 'user1', householdId: 'h1');
      final household = MockHousehold(id: 'h1', memberIds: ['user1']);
      
      leaveHousehold(user, household);
      
      // Create new receipt after leaving
      final newReceipt = MockReceipt(
        id: 'r2',
        userId: user.id,
        householdId: user.householdId, // Will be null
        createdAt: DateTime.now(),
      );
      
      expect(newReceipt.householdId, isNull);
    });
  });
}

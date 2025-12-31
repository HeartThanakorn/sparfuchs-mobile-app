import 'package:flutter_test/flutter_test.dart';

/// Property 23: Reminder Cancellation on Return
/// Validates: Requirements 8.6
///
/// Properties:
/// 1. Return notification is cancelled when item marked as returned
/// 2. Warranty notification is cancelled when item marked as returned
/// 3. Notification IDs are generated consistently for same item
/// 4. Cancellation is idempotent (can cancel already cancelled)

/// Mock notification manager for testing
class MockNotificationManager {
  final Set<int> _scheduledNotifications = {};
  final List<String> _cancelLog = [];

  /// Schedule a notification
  void schedule(int id, String title) {
    _scheduledNotifications.add(id);
  }

  /// Cancel a notification
  void cancel(int id) {
    _scheduledNotifications.remove(id);
    _cancelLog.add('cancelled:$id');
  }

  /// Check if notification is scheduled
  bool isScheduled(int id) => _scheduledNotifications.contains(id);

  /// Get cancel log
  List<String> get cancelLog => List.unmodifiable(_cancelLog);

  /// Get count of scheduled notifications
  int get scheduledCount => _scheduledNotifications.length;
}

/// Generate notification ID from item ID and type
int generateNotificationId(String itemId, String type) {
  return '${itemId}_$type'.hashCode.abs();
}

/// Cancel all reminders for an item
void cancelWarrantyReminders(MockNotificationManager manager, String itemId) {
  manager.cancel(generateNotificationId(itemId, 'return'));
  manager.cancel(generateNotificationId(itemId, 'warranty'));
}

void main() {
  group('Property 23: Reminder Cancellation on Return', () {
    late MockNotificationManager manager;

    setUp(() {
      manager = MockNotificationManager();
    });

    // Test: Return notification cancelled on mark as returned
    test('return notification is cancelled when marked as returned', () {
      const itemId = 'item123';
      final returnId = generateNotificationId(itemId, 'return');

      // Schedule return notification
      manager.schedule(returnId, 'Return reminder');
      expect(manager.isScheduled(returnId), isTrue);

      // Mark as returned
      cancelWarrantyReminders(manager, itemId);

      expect(manager.isScheduled(returnId), isFalse);
    });

    // Test: Warranty notification cancelled on mark as returned
    test('warranty notification is cancelled when marked as returned', () {
      const itemId = 'item123';
      final warrantyId = generateNotificationId(itemId, 'warranty');

      // Schedule warranty notification
      manager.schedule(warrantyId, 'Warranty reminder');
      expect(manager.isScheduled(warrantyId), isTrue);

      // Mark as returned
      cancelWarrantyReminders(manager, itemId);

      expect(manager.isScheduled(warrantyId), isFalse);
    });

    // Test: Both notifications cancelled together
    test('both notifications cancelled when marked as returned', () {
      const itemId = 'item456';
      final returnId = generateNotificationId(itemId, 'return');
      final warrantyId = generateNotificationId(itemId, 'warranty');

      // Schedule both
      manager.schedule(returnId, 'Return reminder');
      manager.schedule(warrantyId, 'Warranty reminder');
      expect(manager.scheduledCount, 2);

      // Mark as returned
      cancelWarrantyReminders(manager, itemId);

      expect(manager.scheduledCount, 0);
    });

    // Test: Notification ID is consistent
    test('notification ID is consistent for same item', () {
      const itemId = 'item789';

      final id1 = generateNotificationId(itemId, 'return');
      final id2 = generateNotificationId(itemId, 'return');

      expect(id1, id2);
    });

    // Test: Different items have different IDs
    test('different items have different notification IDs', () {
      final id1 = generateNotificationId('item1', 'return');
      final id2 = generateNotificationId('item2', 'return');

      expect(id1, isNot(id2));
    });

    // Test: Return and warranty have different IDs
    test('return and warranty have different notification IDs', () {
      const itemId = 'item123';

      final returnId = generateNotificationId(itemId, 'return');
      final warrantyId = generateNotificationId(itemId, 'warranty');

      expect(returnId, isNot(warrantyId));
    });

    // Test: Cancellation is idempotent
    test('cancellation is idempotent', () {
      const itemId = 'item123';

      // Cancel without scheduling (should not throw)
      cancelWarrantyReminders(manager, itemId);
      cancelWarrantyReminders(manager, itemId);

      // Cancel log should show attempts
      expect(manager.cancelLog.length, 4); // 2 calls × 2 types
    });

    // Test: Other items not affected
    test('cancelling one item does not affect other items', () {
      final returnId1 = generateNotificationId('item1', 'return');
      final returnId2 = generateNotificationId('item2', 'return');

      manager.schedule(returnId1, 'Item 1 return');
      manager.schedule(returnId2, 'Item 2 return');

      // Cancel only item1
      cancelWarrantyReminders(manager, 'item1');

      expect(manager.isScheduled(returnId1), isFalse);
      expect(manager.isScheduled(returnId2), isTrue);
    });
  });
}

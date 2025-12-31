import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sparfuchs_ai/features/warranty/data/services/warranty_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Service for scheduling warranty-related push notifications
class WarrantyNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const _returnChannelId = 'warranty_return_reminders';
  static const _warrantyChannelId = 'warranty_expiry_reminders';
  static const _daysBeforeReminder = 3;

  /// Initialize the notification service
  static Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    debugPrint('WarrantyNotificationService: Initialized');
  }

  /// Request notification permissions (iOS)
  static Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// Schedule notifications for a warranty item
  static Future<void> scheduleWarrantyReminders(WarrantyItem item) async {
    // Schedule return deadline reminder
    await _scheduleReturnReminder(item);

    // Schedule warranty expiry reminder
    if (item.warrantyExpiry != null) {
      await _scheduleWarrantyExpiryReminder(item);
    }
  }

  /// Schedule reminder 3 days before return deadline
  static Future<void> _scheduleReturnReminder(WarrantyItem item) async {
    final reminderDate = item.returnDeadline.subtract(
      const Duration(days: _daysBeforeReminder),
    );

    // Don't schedule if reminder date is in the past
    if (reminderDate.isBefore(DateTime.now())) {
      debugPrint('WarrantyNotificationService: Return reminder date passed');
      return;
    }

    final notificationId = _generateNotificationId(item.id, 'return');

    await _notifications.zonedSchedule(
      notificationId,
      'Rückgabefrist in 3 Tagen! ⏰',
      '${item.itemDescription} bei ${item.merchantName} läuft bald ab',
      tz.TZDateTime.from(reminderDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _returnChannelId,
          'Rückgabe-Erinnerungen',
          channelDescription: 'Erinnerungen an ablaufende Rückgabefristen',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint(
        'WarrantyNotificationService: Scheduled return reminder for ${item.itemDescription}');
  }

  /// Schedule reminder 3 days before warranty expires
  static Future<void> _scheduleWarrantyExpiryReminder(WarrantyItem item) async {
    final warrantyExpiry = item.warrantyExpiry;
    if (warrantyExpiry == null) return;

    final reminderDate = warrantyExpiry.subtract(
      const Duration(days: _daysBeforeReminder),
    );

    // Don't schedule if reminder date is in the past
    if (reminderDate.isBefore(DateTime.now())) {
      debugPrint('WarrantyNotificationService: Warranty reminder date passed');
      return;
    }

    final notificationId = _generateNotificationId(item.id, 'warranty');

    await _notifications.zonedSchedule(
      notificationId,
      'Garantie läuft bald ab! 🛡️',
      '${item.itemDescription} - Garantie endet in 3 Tagen',
      tz.TZDateTime.from(reminderDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _warrantyChannelId,
          'Garantie-Erinnerungen',
          channelDescription: 'Erinnerungen an ablaufende Garantien',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint(
        'WarrantyNotificationService: Scheduled warranty reminder for ${item.itemDescription}');
  }

  /// Cancel all notifications for a warranty item
  static Future<void> cancelWarrantyReminders(String itemId) async {
    await _notifications.cancel(_generateNotificationId(itemId, 'return'));
    await _notifications.cancel(_generateNotificationId(itemId, 'warranty'));
    debugPrint('WarrantyNotificationService: Cancelled reminders for $itemId');
  }

  /// Cancel all pending notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('WarrantyNotificationService: Cancelled all notifications');
  }

  /// Get all pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Generate unique notification ID from item ID and type
  static int _generateNotificationId(String itemId, String type) {
    return '${itemId}_$type'.hashCode.abs();
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('WarrantyNotificationService: Notification tapped - ${response.payload}');
    // TODO: Navigate to warranty list screen
  }
}

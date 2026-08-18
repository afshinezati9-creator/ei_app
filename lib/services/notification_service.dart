// ============================================================
// مسیر: lib/services/notification_service.dart
// ============================================================
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/notification.dart';
import '../providers/notification_provider.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ===== مقداردهی اولیه =====
  Future<void> init() async {
    if (_initialized) return;

    // تنظیم منطقه زمانی
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Tehran'));

    // تنظیمات اندروید
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

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  // ===== دریافت مجوزها =====
  Future<bool> requestPermissions() async {
    final permissions = await _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    return permissions ?? false;
  }

  // ===== زمان‌بندی نوتیفیکیشن =====
  Future<void> scheduleNotification(AppNotification notification) async {
    if (!_initialized) await init();

    // تبدیل تاریخ شمسی به میلادی
    final scheduledDateTime = _convertToDateTime(
      notification.scheduledDate,
      notification.scheduledTime,
    );

    if (scheduledDateTime == null) return;

    // لغو نوتیفیکیشن‌های قبلی اگر بیش از ۳ عدد فعال باشند
    await _cancelExcessNotifications();

    final id = int.parse(notification.id.hashCode.toString().substring(0, 8));
    final payload = notification.id;

    // تنظیمات اندروید
    final androidDetails = AndroidNotificationDetails(
      'ei_notifications',
      'ei اعلان‌ها',
      channelDescription: 'اعلان‌های برنامه حسابدار شخصی',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      autoCancel: true,
      timeoutAfter: 60000, // 1 دقیقه
    );

    final iosDetails = DarwinNotificationDetails(
      sound: 'notification.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // زمان‌بندی
    await _plugin.zonedSchedule(
      id,
      notification.title,
      notification.body,
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ===== لغو یک نوتیفیکیشن =====
  Future<void> cancelNotification(String id) async {
    final intId = int.parse(id.hashCode.toString().substring(0, 8));
    await _plugin.cancel(intId);
  }

  // ===== لغو همه نوتیفیکیشن‌ها =====
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  // ===== لغو نوتیفیکیشن‌های اضافی (بیش از ۳ عدد) =====
  Future<void> _cancelExcessNotifications() async {
    final pending = await _plugin.pendingNotificationRequests();
    if (pending.length >= 3) {
      // لغو قدیمی‌ترین‌ها (به ترتیب id)
      final sorted = pending.toList()..sort((a, b) => a.id.compareTo(b.id));
      for (int i = 0; i < sorted.length - 2; i++) {
        await _plugin.cancel(sorted[i].id);
      }
    }
  }

  // ===== تبدیل تاریخ شمسی به میلادی =====
  DateTime? _convertToDateTime(String date, String time) {
    try {
      final dateParts = date.split('/');
      final timeParts = time.split(':');
      if (dateParts.length != 3 || timeParts.length != 2) return null;

      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // تبدیل شمسی به میلادی (تقریبی)
      final gregorianYear = year + 621;
      return DateTime(gregorianYear, month, day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  // ===== رویداد کلیک روی نوتیفیکیشن =====
  void _onNotificationTap(NotificationResponse response) {
    // در اینجا می‌توانید به صفحه اعلان‌ها بروید
    // پیاده‌سازی در main.dart انجام می‌شود
    if (response.payload != null) {
      // به صفحه جزئیات اعلان برو
      // با استفاده از GlobalKey یا MethodChannel
    }
  }

  // ===== ارسال فوری (برای تست) =====
  Future<void> showImmediateNotification(AppNotification notification) async {
    if (!_initialized) await init();

    final id = int.parse(notification.id.hashCode.toString().substring(0, 8));
    final payload = notification.id;

    final androidDetails = AndroidNotificationDetails(
      'ei_notifications',
      'ei اعلان‌ها',
      channelDescription: 'اعلان‌های برنامه حسابدار شخصی',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      autoCancel: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id,
      notification.title,
      notification.body,
      details,
      payload: payload,
    );
  }

  // ===== بررسی نوتیفیکیشن‌های زمان‌رسیده =====
  Future<void> checkAndSendDueNotifications(NotificationProvider provider) async {
    final dueNotifications = provider.getActiveNotifications();
    for (var notif in dueNotifications) {
      // اگر وضعیت pending است و زمانش رسیده
      if (notif.status == NotificationStatus.pending && notif.isTimeReached) {
        // ارسال نوتیفیکیشن
        await scheduleNotification(notif);
        // تغییر وضعیت به shown
        await provider.changeStatus(notif.id, NotificationStatus.shown);
      }
    }
  }
}
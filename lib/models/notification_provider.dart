// ============================================================
// مسیر: lib/providers/notification_provider.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification.dart';
import 'date_provider.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  List<String> _categories = ['چک', 'یادآوری کاری', 'سررسید', 'شخصی', 'سفارشی'];

  List<AppNotification> get notifications => _notifications;
  List<String> get categories => _categories;

  NotificationProvider() {
    _loadNotifications();
  }

  // ===== دریافت اعلان‌ها بر اساس وضعیت =====
  List<AppNotification> getByStatus(NotificationStatus status) {
    return _notifications.where((n) => n.status == status).toList();
  }

  // ===== دریافت اعلان‌های فعال (pending و زمانشان رسیده) =====
  List<AppNotification> getActiveNotifications() {
    return _notifications.where((n) =>
      n.status == NotificationStatus.pending &&
      n.isTimeReached &&
      !n.isExpired
    ).toList();
  }

  // ===== دریافت اعلان‌های امروز =====
  List<AppNotification> getTodayNotifications() {
    final today = DateProvider().getToday();
    return _notifications.where((n) =>
      n.scheduledDate == today &&
      n.status == NotificationStatus.pending &&
      !n.isExpired
    ).toList();
  }

  // ===== دریافت بر اساس دسته‌بندی =====
  List<AppNotification> getByCategory(String category) {
    return _notifications.where((n) => n.category == category).toList();
  }

  // ===== افزودن اعلان =====
  Future<void> addNotification(AppNotification notification) async {
    _notifications.add(notification);
    await _saveNotifications();
    notifyListeners();
  }

  // ===== ویرایش اعلان =====
  Future<void> updateNotification(AppNotification notification) async {
    final index = _notifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      _notifications[index] = notification;
      await _saveNotifications();
      notifyListeners();
    }
  }

  // ===== حذف اعلان =====
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    await _saveNotifications();
    notifyListeners();
  }

  // ===== تغییر وضعیت =====
  Future<void> changeStatus(String id, NotificationStatus newStatus) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final updated = _notifications[index].copyWith(
        status: newStatus,
        updatedAt: DateProvider().getToday() + ' ' + _getCurrentTime(),
      );
      _notifications[index] = updated;
      await _saveNotifications();
      notifyListeners();
    }
  }

  // ===== افزودن دسته‌بندی جدید =====
  Future<void> addCategory(String category) async {
    if (!_categories.contains(category) && category.trim().isNotEmpty) {
      _categories.add(category.trim());
      await _saveCategories();
      notifyListeners();
    }
  }

  // ===== حذف دسته‌بندی =====
  Future<void> deleteCategory(String category) async {
    // اگر دسته‌بندی پیش‌فرض نباشد
    if (!['چک', 'یادآوری کاری', 'سررسید', 'شخصی', 'سفارشی'].contains(category)) {
      _categories.remove(category);
      await _saveCategories();
      notifyListeners();
    }
  }

  // ===== دریافت تعداد اعلان‌های فعال =====
  int get activeCount => getActiveNotifications().length;

  // ===== ذخیره و بارگذاری =====
  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('notifications');
    if (data != null && data.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        _notifications = decoded.map((item) => AppNotification.fromJson(item)).toList();
      } catch (e) {
        _notifications = [];
      }
    } else {
      // نمونه داده برای تست
      _addSampleNotifications();
    }

    final String? catData = prefs.getString('notification_categories');
    if (catData != null && catData.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(catData);
        _categories = decoded.map((e) => e.toString()).toList();
      } catch (e) {
        _categories = ['چک', 'یادآوری کاری', 'سررسید', 'شخصی', 'سفارشی'];
      }
    }

    notifyListeners();
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications', jsonEncode(_notifications.map((n) => n.toJson()).toList()));
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_categories', jsonEncode(_categories));
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  // ===== داده‌های نمونه برای تست =====
  void _addSampleNotifications() {
    final today = DateProvider().getToday();
    _notifications.addAll([
      AppNotification(
        id: 'notif_1',
        title: 'چک شماره ۱۲۳۴۵',
        body: 'چک ۵۰ میلیون تومانی سررسید امروز',
        scheduledDate: today,
        scheduledTime: '۱۰:۰۰',
        category: 'چک',
        type: NotificationType.check,
        priority: NotificationPriority.high,
        createdAt: today + ' ۰۹:۰۰',
        updatedAt: today + ' ۰۹:۰۰',
      ),
      AppNotification(
        id: 'notif_2',
        title: 'جلسه با تیم',
        body: 'جلسه برنامه‌ریزی مالی ساعت ۱۴',
        scheduledDate: today,
        scheduledTime: '۱۴:۰۰',
        category: 'یادآوری کاری',
        type: NotificationType.reminder,
        priority: NotificationPriority.medium,
        createdAt: today + ' ۰۸:۰۰',
        updatedAt: today + ' ۰۸:۰۰',
      ),
    ]);
  }
}
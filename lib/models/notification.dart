// ============================================================
// مسیر: lib/models/notification.dart
// ============================================================

enum NotificationStatus {
  pending,   // در انتظار (زمانش نرسیده)
  shown,     // نمایش داده شده به کاربر
  dismissed, // توسط کاربر بسته شده
  expired,   // منقضی شده
}

enum NotificationType {
  reminder,  // یادآوری
  check,     // چک
  task,      // وظیفه
  goal,      // هدف
  custom,    // سفارشی
}

enum NotificationPriority {
  low,
  medium,
  high,
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String scheduledDate;   // تاریخ شمسی (۱۴۰۴/۰۶/۰۱)
  final String scheduledTime;   // ساعت (۱۴:۳۰)
  final String? expiryDate;     // تاریخ انقضا (اختیاری)
  final NotificationStatus status;
  final NotificationType type;
  final String category;        // دسته‌بندی (مثلاً "چک")
  final NotificationPriority priority;
  final bool isRecurring;
  final String? recurringType;  // 'daily', 'weekly', 'monthly'
  final String? relatedId;      // id تراکنش یا هدف مرتبط (اختیاری)
  final String createdAt;
  final String updatedAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.scheduledTime,
    this.expiryDate,
    this.status = NotificationStatus.pending,
    this.type = NotificationType.custom,
    this.category = 'سفارشی',
    this.priority = NotificationPriority.medium,
    this.isRecurring = false,
    this.recurringType,
    this.relatedId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'scheduledDate': scheduledDate,
    'scheduledTime': scheduledTime,
    'expiryDate': expiryDate,
    'status': status.name,
    'type': type.name,
    'category': category,
    'priority': priority.name,
    'isRecurring': isRecurring,
    'recurringType': recurringType,
    'relatedId': relatedId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    title: json['title'] ?? '',
    body: json['body'] ?? '',
    scheduledDate: json['scheduledDate'] ?? '',
    scheduledTime: json['scheduledTime'] ?? '۰۰:۰۰',
    expiryDate: json['expiryDate'],
    status: NotificationStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => NotificationStatus.pending,
    ),
    type: NotificationType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => NotificationType.custom,
    ),
    category: json['category'] ?? 'سفارشی',
    priority: NotificationPriority.values.firstWhere(
      (e) => e.name == json['priority'],
      orElse: () => NotificationPriority.medium,
    ),
    isRecurring: json['isRecurring'] ?? false,
    recurringType: json['recurringType'],
    relatedId: json['relatedId'],
    createdAt: json['createdAt'] ?? '',
    updatedAt: json['updatedAt'] ?? '',
  );

  // کپی با تغییرات
  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? scheduledDate,
    String? scheduledTime,
    String? expiryDate,
    NotificationStatus? status,
    NotificationType? type,
    String? category,
    NotificationPriority? priority,
    bool? isRecurring,
    String? recurringType,
    String? relatedId,
    String? createdAt,
    String? updatedAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      type: type ?? this.type,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      relatedId: relatedId ?? this.relatedId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // دریافت وضعیت به فارسی
  String get statusLabel {
    switch (status) {
      case NotificationStatus.pending:
        return 'در انتظار';
      case NotificationStatus.shown:
        return 'دیده شده';
      case NotificationStatus.dismissed:
        return 'بسته شده';
      case NotificationStatus.expired:
        return 'منقضی';
    }
  }

  // دریافت نوع به فارسی
  String get typeLabel {
    switch (type) {
      case NotificationType.reminder:
        return 'یادآوری';
      case NotificationType.check:
        return 'چک';
      case NotificationType.task:
        return 'وظیفه';
      case NotificationType.goal:
        return 'هدف';
      case NotificationType.custom:
        return 'سفارشی';
    }
  }

  // دریافت اولویت به فارسی
  String get priorityLabel {
    switch (priority) {
      case NotificationPriority.low:
        return 'کم';
      case NotificationPriority.medium:
        return 'متوسط';
      case NotificationPriority.high:
        return 'بالا';
    }
  }

  // رنگ اولویت
  int get priorityColor {
    switch (priority) {
      case NotificationPriority.low:
        return 0xFF4CAF50;
      case NotificationPriority.medium:
        return 0xFFFF9800;
      case NotificationPriority.high:
        return 0xFFF44336;
    }
  }

  // دریافت رنگ وضعیت
  int get statusColor {
    switch (status) {
      case NotificationStatus.pending:
        return 0xFFFF9800;
      case NotificationStatus.shown:
        return 0xFF4CAF50;
      case NotificationStatus.dismissed:
        return 0xFF9E9E9E;
      case NotificationStatus.expired:
        return 0xFFF44336;
    }
  }

  // آیا زمان اعلان رسیده است؟
  bool get isTimeReached {
    final now = DateTime.now();
    final dateParts = scheduledDate.split('/');
    final timeParts = scheduledTime.split(':');
    if (dateParts.length != 3 || timeParts.length != 2) return false;
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final scheduled = DateTime(year, month, day, hour, minute);
    return now.isAfter(scheduled) || now.isAtSameMomentAs(scheduled);
  }

  // آیا اعلان منقضی شده است؟
  bool get isExpired {
    if (expiryDate == null || expiryDate!.isEmpty) return false;
    final today = DateTime.now();
    final parts = expiryDate!.split('/');
    if (parts.length != 3) return false;
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    final expiry = DateTime(year, month, day);
    return today.isAfter(expiry);
  }
}
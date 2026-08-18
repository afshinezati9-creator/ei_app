// ============================================================
// مسیر: lib/models/goal.dart
// ============================================================
import 'package:flutter/material.dart';

enum GoalStatus {
  inProgress,  // در حال انجام
  completed,   // تکمیل شده
  cancelled,   // لغو شده
}

enum GoalPriority {
  low,    // کم
  medium, // متوسط
  high,   // بالا
}

class Goal {
  final String id;
  final String title;
  final String description;
  final double targetAmount;
  double currentAmount;
  final String deadline;
  final GoalPriority priority;
  GoalStatus status;
  final String color;
  final String? note;
  final String createdAt;

  Goal({
    required this.id,
    required this.title,
    this.description = '',
    required this.targetAmount,
    this.currentAmount = 0,
    required this.deadline,
    this.priority = GoalPriority.medium,
    this.status = GoalStatus.inProgress,
    this.color = '#6C5CE7',
    this.note,
    required this.createdAt,
  });

  double get progress {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  int get progressPercent => (progress * 100).round();

  double get remainingAmount => (targetAmount - currentAmount).clamp(0.0, double.infinity);

  bool get isCompleted => status == GoalStatus.completed || currentAmount >= targetAmount;

  String get statusLabel {
    switch (status) {
      case GoalStatus.inProgress:
        return 'در حال انجام';
      case GoalStatus.completed:
        return 'تکمیل شده';
      case GoalStatus.cancelled:
        return 'لغو شده';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case GoalPriority.low:
        return 'کم';
      case GoalPriority.medium:
        return 'متوسط';
      case GoalPriority.high:
        return 'بالا';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case GoalPriority.low:
        return Colors.green;
      case GoalPriority.medium:
        return Colors.orange;
      case GoalPriority.high:
        return Colors.red;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'deadline': deadline,
        'priority': priority.name,
        'status': status.name,
        'color': color,
        'note': note,
        'createdAt': createdAt,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        targetAmount: (json['targetAmount'] ?? 0).toDouble(),
        currentAmount: (json['currentAmount'] ?? 0).toDouble(),
        deadline: json['deadline'] ?? '',
        priority: GoalPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => GoalPriority.medium,
        ),
        status: GoalStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => GoalStatus.inProgress,
        ),
        color: json['color'] ?? '#6C5CE7',
        note: json['note'],
        createdAt: json['createdAt'] ?? '',
      );

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    String? deadline,
    GoalPriority? priority,
    GoalStatus? status,
    String? color,
    String? note,
    String? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      color: color ?? this.color,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
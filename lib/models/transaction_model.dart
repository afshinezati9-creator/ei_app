// ============================================================
// مسیر: lib/models/transaction_model.dart
// ============================================================
class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String date;
  final String time;
  final String type;
  final String categoryId;
  final String categoryName;
  final String paymentMethod;
  final String? contact;
  final String? note;
  final String? priority;
  final String? recurrence;
  final double? target;
  final String? goalId; // ✅ اضافه شد

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.time,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.paymentMethod,
    this.contact,
    this.note,
    this.priority,
    this.recurrence,
    this.target,
    this.goalId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date,
        'time': time,
        'type': type,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'paymentMethod': paymentMethod,
        'contact': contact,
        'note': note,
        'priority': priority,
        'recurrence': recurrence,
        'target': target,
        'goalId': goalId,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        date: json['date'] ?? '',
        time: json['time'] ?? '',
        type: json['type'] ?? '',
        categoryId: json['categoryId'] ?? '',
        categoryName: json['categoryName'] ?? '',
        paymentMethod: json['paymentMethod'] ?? '',
        contact: json['contact'],
        note: json['note'],
        priority: json['priority'],
        recurrence: json['recurrence'],
        target: json['target']?.toDouble(),
        goalId: json['goalId'],
      );
}
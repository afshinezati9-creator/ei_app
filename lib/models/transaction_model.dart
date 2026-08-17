class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String date;      // تاریخ شمسی
  final String time;      // ساعت
  final String type;      // 'income', 'expense', 'saving', 'goal', 'loan', 'debt', 'credit'
  final String categoryId; // شناسه دسته‌بندی
  final String categoryName; // نام دسته‌بندی (برای نمایش سریع)
  final String paymentMethod; // 'cash', 'card', 'check', 'transfer'
  final String? contact;     // طرف حساب
  final String? note;        // یادداشت
  final String? priority;    // 'low', 'medium', 'high'
  final String? recurrence;  // 'once', 'monthly', 'yearly'
  final double? target;      // برای اهداف

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
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        date: json['date'] ?? '',
        time: json['time'] ?? '',
        type: json['type'] ?? 'expense',
        categoryId: json['categoryId'] ?? '',
        categoryName: json['categoryName'] ?? 'سایر',
        paymentMethod: json['paymentMethod'] ?? 'cash',
        contact: json['contact'],
        note: json['note'],
        priority: json['priority'],
        recurrence: json['recurrence'],
        target: (json['target'] as num?)?.toDouble(),
      );
}
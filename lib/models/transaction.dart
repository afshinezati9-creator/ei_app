class Transaction {
  final String id;
  final String title;
  final double amount;
  final String date;
  final String time;
  final String type; // expense, income, saving, goal, loan, debt, credit
  final String category;
  final String? extra;
  final String? note;
  final String? accountId; // id حساب بانکی یا 'cash' برای نقدی
  final int reminder; // ساعت قبل
  final double? target; // فقط برای goals

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.time,
    required this.type,
    this.category = '',
    this.extra,
    this.note,
    this.accountId,
    this.reminder = 0,
    this.target,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date,
        'time': time,
        'type': type,
        'category': category,
        'extra': extra,
        'note': note,
        'accountId': accountId,
        'reminder': reminder,
        'target': target,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        date: json['date'] ?? '',
        time: json['time'] ?? '۱۲:۰۰',
        type: json['type'] ?? 'expense',
        category: json['category'] ?? '',
        extra: json['extra'],
        note: json['note'],
        accountId: json['accountId'],
        reminder: json['reminder'] ?? 0,
        target: (json['target'] as num?)?.toDouble(),
      );
}
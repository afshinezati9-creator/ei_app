class Transaction {
  final String id;
  final String title;
  final double amount;
  final String date;
  final String type;
  final String? extra;
  final String? note;
  final double? target;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.extra,
    this.note,
    this.target,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date,
        'type': type,
        'extra': extra,
        'note': note,
        'target': target,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        date: json['date'] ?? '',
        type: json['type'] ?? 'expense',
        extra: json['extra'],
        note: json['note'],
        target: (json['target'] as num?)?.toDouble(),
      );
}
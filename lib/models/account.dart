class Account {
  final String id;
  final String name;
  final String type; // 'bank', 'card', 'cash'
  final String number;
  final String holder;
  double balance;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.number,
    required this.holder,
    this.balance = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'number': number,
        'holder': holder,
        'balance': balance,
      };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: json['name'] ?? '',
        type: json['type'] ?? 'cash',
        number: json['number'] ?? '',
        holder: json['holder'] ?? '',
        balance: (json['balance'] ?? 0).toDouble(),
      );

  String getDisplayName() {
    if (type == 'cash') return 'نقدی';
    if (type == 'bank') return '$name (بانک)';
    if (type == 'card') return '$name (کارت)';
    return name;
  }

  String getShortNumber() {
    if (number.length < 4) return number;
    return '...${number.substring(number.length - 4)}';
  }
}
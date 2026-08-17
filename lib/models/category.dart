class Category {
  final String id;
  final String name;
  final String icon;   // Emoji یا کد آیکون
  final String type;   // 'income', 'expense', 'saving', 'goal', 'loan', 'debt', 'credit'
  final String color;  // کد رنگ به صورت hex

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'type': type,
        'color': color,
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: json['name'] ?? '',
        icon: json['icon'] ?? '📌',
        type: json['type'] ?? 'expense',
        color: json['color'] ?? '#6C5CE7',
      );
}
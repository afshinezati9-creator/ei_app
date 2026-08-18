// ============================================================
// مسیر: lib/models/note_category.dart
// ============================================================
class NoteCategory {
  final String id;
  final String name;
  final String color;

  NoteCategory({
    required this.id,
    required this.name,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
      };

  factory NoteCategory.fromJson(Map<String, dynamic> json) => NoteCategory(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        color: json['color'] ?? '#6C5CE7',
      );
}
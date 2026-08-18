// ============================================================
// مسیر: lib/models/note.dart
// ============================================================
class Note {
  final String id;
  final String title;
  final String body;
  final String categoryId;
  final String created;
  final String updated;

  Note({
    required this.id,
    required this.title,
    required this.body,
    this.categoryId = '',
    required this.created,
    required this.updated,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'categoryId': categoryId,
        'created': created,
        'updated': updated,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        categoryId: json['categoryId'] ?? '',
        created: json['created'] ?? '',
        updated: json['updated'] ?? '',
      );
}
// lib/models/news.dart
// Hafta 2: API'den gelen News verisinin Dart modeli

class News {
  final int id;
  final String title;
  final String content;
  final DateTime publishedAt;

  const News({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'publishedAt': publishedAt.toIso8601String(),
      };
}

// lib/models/news.dart
// Hafta 2: API'den gelen News verisinin Dart modeli

class News {
  final int id;
  final String title;
  final String content;
  final DateTime publishedAt;
  final String? source;
  final bool isPublished;

  const News({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
    this.source,
    this.isPublished = true,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      publishedAt:
          DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
          DateTime.now(),
      source: json['source'] as String?,
      isPublished: json['isPublished'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'publishedAt': publishedAt.toIso8601String(),
    'source': source,
    'isPublished': isPublished,
  };
}

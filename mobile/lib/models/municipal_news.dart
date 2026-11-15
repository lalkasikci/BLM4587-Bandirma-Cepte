class MunicipalNews {
  final String title;
  final String source;
  final String url;
  final String? summary;

  const MunicipalNews({
    required this.title,
    required this.source,
    required this.url,
    this.summary,
  });

  factory MunicipalNews.fromJson(Map<String, dynamic> json) => MunicipalNews(
    title: json['title'] as String? ?? '',
    source: json['source'] as String? ?? 'Bandırma Belediyesi',
    url: json['url'] as String? ?? '',
    summary: json['summary'] as String?,
  );
}

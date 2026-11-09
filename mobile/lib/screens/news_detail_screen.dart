import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/news.dart';
import '../services/api_service.dart';

class NewsDetailScreen extends StatefulWidget {
  final int newsId;
  const NewsDetailScreen({super.key, required this.newsId});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final _api = ApiService();
  late Future<News> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getNewsById(widget.newsId);
  }

  void _retry() => setState(() => _future = _api.getNewsById(widget.newsId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Haber Detayı'),
        backgroundColor: const Color(0xFF123B5D),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<News>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      size: 48,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Haber ayrıntısı yüklenemedi.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            );
          }

          final news = snapshot.data!;
          final date = DateFormat(
            'dd MMMM yyyy, HH:mm',
            'tr',
          ).format(news.publishedAt.toLocal());
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3FF),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'YEREL HABER',
                        style: TextStyle(
                          color: Color(0xFF176B88),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      news.title,
                      style: const TextStyle(
                        fontSize: 25,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18364B),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    if (news.source?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Kaynak: ${news.source}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF147D9A),
                        ),
                      ),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Divider(),
                    ),
                    SelectableText(
                      news.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.65,
                        color: Color(0xFF344955),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

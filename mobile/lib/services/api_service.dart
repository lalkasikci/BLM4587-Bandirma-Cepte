// lib/services/api_service.dart
// HTTP servis katmanı — Bandırma Cepte Web API'sine bağlanır.
//
// API base URL: http://10.0.2.2:5000 (Android emülatör → localhost)
// Gerçek cihazda: bilgisayarın LAN IP'si ile değiştir (örn. http://192.168.1.x:5000)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news.dart';
import '../models/bus_line.dart';
import '../models/auth_response.dart';

class ApiService {
  // Android emülatöründe localhost'a erişim için 10.0.2.2 kullanılır.
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  // ─── Auth ───────────────────────────────────────────────────────────────────

  /// POST /api/auth/login — JWT token döner
  Future<AuthResponse> login(String username, String password) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else if (response.statusCode == 401) {
      throw Exception('Geçersiz kullanıcı adı veya şifre.');
    } else {
      throw Exception('Giriş başarısız: ${response.statusCode}');
    }
  }

  // ─── News ────────────────────────────────────────────────────────────────────

  /// GET /api/news — tüm haberleri getirir (herkese açık)
  Future<List<News>> getNews() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/api/news'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => News.fromJson(e as Map<String, dynamic>))
          .where((news) => news.isPublished)
          .toList();
    } else {
      throw Exception('Haberler alınamadı: ${response.statusCode}');
    }
  }

  /// GET /api/news/{id} — haber ayrıntısını getirir.
  Future<News> getNewsById(int id) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/api/news/$id'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return News.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    if (response.statusCode == 404) throw Exception('Haber bulunamadı.');
    throw Exception('Haber ayrıntısı alınamadı: ${response.statusCode}');
  }

  // ─── Bus Lines ───────────────────────────────────────────────────────────────

  /// GET /api/buslines — tüm otobüs hatlarını getirir (herkese açık)
  Future<List<BusLine>> getBusLines() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/api/buslines'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => BusLine.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Otobüs hatları alınamadı: ${response.statusCode}');
    }
  }
}

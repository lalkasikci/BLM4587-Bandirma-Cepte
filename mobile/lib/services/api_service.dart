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
import '../models/local_info.dart';
import '../models/municipal_news.dart';

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

  /// POST /api/auth/register — normal kullanıcı hesabı oluşturur.
  Future<void> register(String username, String password) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_responseError(response, 'Hesap oluşturulamadı'));
    }
  }

  // ─── News ────────────────────────────────────────────────────────────────────

  /// GET /api/news — tüm haberleri getirir (herkese açık)
  Future<List<News>> getNews({bool includeUnpublished = false}) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/api/news'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      final news =
          data.map((e) => News.fromJson(e as Map<String, dynamic>)).toList();
      return includeUnpublished
          ? news
          : news.where((item) => item.isPublished).toList();
    } else {
      throw Exception('Haberler alınamadı: ${response.statusCode}');
    }
  }

  /// GET /api/news/municipal — belediyeden kazınan ve backend'de önbelleklenen haberler.
  Future<List<MunicipalNews>> getMunicipalNews() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/api/news/municipal'))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception(_responseError(response, 'Belediye haberleri alınamadı'));
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => MunicipalNews.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<News> createNews(News news, {required String token}) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/news'),
          headers: _authorizedJsonHeaders(token),
          body: jsonEncode(news.toJson()),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return News.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception(_responseError(response, 'Haber oluşturulamadı'));
  }

  Future<void> updateNews(News news, {required String token}) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/api/news/${news.id}'),
          headers: _authorizedJsonHeaders(token),
          body: jsonEncode(news.toJson()),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_responseError(response, 'Haber güncellenemedi'));
    }
  }

  Future<void> deleteNews(int id, {required String token}) async {
    final response = await http
        .delete(
          Uri.parse('$_baseUrl/api/news/$id'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_responseError(response, 'Haber silinemedi'));
    }
  }

  Map<String, String> _authorizedJsonHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  String _responseError(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final message = body['message'];
        if (message is String && message.isNotEmpty) return message;
        final errors = body['errors'];
        if (errors is Map<String, dynamic>) {
          final messages =
              errors.values
                  .whereType<List<dynamic>>()
                  .expand((value) => value)
                  .whereType<String>()
                  .toSet();
          if (messages.isNotEmpty) return messages.join('\n');
        }
        final title = body['title'];
        if (title is String && title.isNotEmpty) return title;
      }
    } on FormatException {
      // API boş veya JSON dışı yanıt döndürdüyse durum kodunu göster.
    }
    if (response.statusCode == 401) {
      return 'Oturum süresi dolmuş. Yeniden giriş yap.';
    }
    if (response.statusCode == 403) {
      return 'Bu işlem için yönetici yetkisi gerekiyor.';
    }
    return '$fallback (${response.statusCode})';
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

  Future<void> createBusLine(BusLine line, {required String token}) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/buslines'),
          headers: _authorizedJsonHeaders(token),
          body: jsonEncode(line.toJson()),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_responseError(response, 'Otobüs hattı eklenemedi'));
    }
  }

  Future<void> updateBusLine(BusLine line, {required String token}) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/api/buslines/${line.id}'),
          headers: _authorizedJsonHeaders(token),
          body: jsonEncode(line.toJson()),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_responseError(response, 'Otobüs hattı güncellenemedi'));
    }
  }

  Future<void> deleteBusLine(int id, {required String token}) async {
    await _deleteAuthorized('buslines', id, token, 'Otobüs hattı silinemedi');
  }

  Future<void> createBusSchedule(
    BusLine line,
    BusSchedule schedule, {
    required String token,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/busschedules'),
          headers: _authorizedJsonHeaders(token),
          body: jsonEncode(line.scheduleToJson(schedule)),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_responseError(response, 'Sefer saati eklenemedi'));
    }
  }

  Future<void> updateBusSchedule(
    BusLine line,
    BusSchedule schedule, {
    required String token,
  }) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/api/busschedules/${schedule.id}'),
          headers: _authorizedJsonHeaders(token),
          body: jsonEncode(line.scheduleToJson(schedule)),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_responseError(response, 'Sefer saati güncellenemedi'));
    }
  }

  Future<void> deleteBusSchedule(int id, {required String token}) async {
    await _deleteAuthorized(
      'busschedules',
      id,
      token,
      'Sefer saati silinemedi',
    );
  }

  Future<List<Pharmacy>> getPharmacies() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/api/pharmacies'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Eczaneler alınamadı: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Pharmacy.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createPharmacy(Pharmacy item, {required String token}) async {
    await _postAuthorized(
      'pharmacies',
      item.toJson(),
      token,
      'Eczane eklenemedi',
    );
  }

  Future<void> updatePharmacy(Pharmacy item, {required String token}) async {
    await _putAuthorized(
      'pharmacies',
      item.id,
      item.toJson(),
      token,
      'Eczane güncellenemedi',
    );
  }

  Future<void> deletePharmacy(int id, {required String token}) async {
    await _deleteAuthorized('pharmacies', id, token, 'Eczane silinemedi');
  }

  Future<List<EmergencyContact>> getEmergencyContacts() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/api/emergencycontacts'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Acil numaralar alınamadı: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => EmergencyContact.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createEmergencyContact(
    EmergencyContact item, {
    required String token,
  }) async {
    await _postAuthorized(
      'emergencycontacts',
      item.toJson(),
      token,
      'Acil numara eklenemedi',
    );
  }

  Future<void> updateEmergencyContact(
    EmergencyContact item, {
    required String token,
  }) async {
    await _putAuthorized(
      'emergencycontacts',
      item.id,
      item.toJson(),
      token,
      'Acil numara güncellenemedi',
    );
  }

  Future<void> deleteEmergencyContact(int id, {required String token}) async {
    await _deleteAuthorized(
      'emergencycontacts',
      id,
      token,
      'Acil numara silinemedi',
    );
  }

  Future<void> _postAuthorized(
    String path,
    Map<String, dynamic> body,
    String token,
    String fallback,
  ) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/$path'),
          headers: _authorizedJsonHeaders(token),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_responseError(response, fallback));
    }
  }

  Future<void> _putAuthorized(
    String path,
    int id,
    Map<String, dynamic> body,
    String token,
    String fallback,
  ) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/api/$path/$id'),
          headers: _authorizedJsonHeaders(token),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_responseError(response, fallback));
    }
  }

  Future<void> _deleteAuthorized(
    String path,
    int id,
    String token,
    String fallback,
  ) async {
    final response = await http
        .delete(
          Uri.parse('$_baseUrl/api/$path/$id'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_responseError(response, fallback));
    }
  }

  Future<List<Earthquake>> getEarthquakes() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/api/earthquakes'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Deprem verileri alınamadı: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Earthquake.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Backend'de hava durumu uç noktası olmadığı için Bandırma koordinatlarıyla Open-Meteo kullanılır.
  Future<WeatherSnapshot> getWeather() async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '40.352',
      'longitude': '27.976',
      'current':
          'temperature_2m,apparent_temperature,relative_humidity_2m,is_day,weather_code,wind_speed_10m',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
      'forecast_days': '5',
      'timezone': 'Europe/Istanbul',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('Hava durumu alınamadı: ${response.statusCode}');
    }
    return WeatherSnapshot.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

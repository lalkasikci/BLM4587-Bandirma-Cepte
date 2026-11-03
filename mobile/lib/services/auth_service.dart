// lib/services/auth_service.dart
// Hafta 2: JWT token'ı flutter_secure_storage ile güvenli şekilde saklar/okur/siler

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_response.dart';
import 'api_service.dart';

class AuthService {
  static const _keyToken    = 'jwt_token';
  static const _keyUsername = 'username';
  static const _keyRole     = 'role';

  final _storage = const FlutterSecureStorage();
  final _api     = ApiService();

  // Şu anki oturum bilgisi (uygulama açıkken bellekte tutulur)
  AuthResponse? _current;
  AuthResponse? get current => _current;
  bool get isLoggedIn => _current != null;
  bool get isAdmin => _current?.isAdmin ?? false;

  /// Uygulama başlangıcında depoda kayıtlı token varsa yükler
  Future<void> tryRestoreSession() async {
    final token    = await _storage.read(key: _keyToken);
    final username = await _storage.read(key: _keyUsername);
    final role     = await _storage.read(key: _keyRole);
    if (token != null && username != null && role != null) {
      _current = AuthResponse(token: token, username: username, role: role);
    }
  }

  /// Kullanıcı adı + şifre ile giriş yapar, token'ı depoya kaydeder
  Future<AuthResponse> login(String username, String password) async {
    final auth = await _api.login(username, password);
    _current = auth;
    await _storage.write(key: _keyToken,    value: auth.token);
    await _storage.write(key: _keyUsername, value: auth.username);
    await _storage.write(key: _keyRole,     value: auth.role);
    return auth;
  }

  /// Çıkış yapar, depodaki token'ı siler
  Future<void> logout() async {
    _current = null;
    await _storage.deleteAll();
  }
}

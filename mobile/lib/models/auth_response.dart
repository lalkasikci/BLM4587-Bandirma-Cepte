// lib/models/auth_response.dart
// Hafta 2: Login endpoint'inden dönen JWT + kullanıcı bilgisi modeli

class AuthResponse {
  final String token;
  final String username;
  final String role;

  const AuthResponse({
    required this.token,
    required this.username,
    required this.role,
  });

  bool get isAdmin => role == 'Admin';

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
    );
  }
}

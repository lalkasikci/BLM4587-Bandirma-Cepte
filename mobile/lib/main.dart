// lib/main.dart
// Hafta 1: Uygulama giriş noktası — AuthService yüklenir, router başlatılır

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app_router.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe tarih formatı için intl yerelleştirmesi
  await initializeDateFormatting('tr', null);

  // Uygulama başlarken depoda kayıtlı oturumu yükle
  final authService = AuthService();
  await authService.tryRestoreSession();

  runApp(BandirmaCepteApp(authService: authService));
}

class BandirmaCepteApp extends StatelessWidget {
  final AuthService authService;
  const BandirmaCepteApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    final router = createRouter(authService);

    return MaterialApp.router(
      title: 'Bandırma Cepte',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F3864),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}

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
          seedColor: const Color(0xFF087E8B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F7F6),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFF073B4C),
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFD8F0E9),
          elevation: 8,
          height: 72,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 12,
              fontWeight:
                  states.contains(WidgetState.selected)
                      ? FontWeight.w800
                      : FontWeight.w500,
              color:
                  states.contains(WidgetState.selected)
                      ? const Color(0xFF087E8B)
                      : const Color(0xFF72838D),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF6FAF9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9E7E5)),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          elevation: 1,
          margin: EdgeInsets.zero,
        ),
      ),
      routerConfig: router,
    );
  }
}

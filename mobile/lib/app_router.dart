// lib/app_router.dart
// Hafta 1: go_router ile uygulama yönlendirme yapısı

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/news_screen.dart';
import 'screens/bus_lines_screen.dart';
import 'screens/placeholder_screen.dart';
import 'services/auth_service.dart';

GoRouter createRouter(AuthService authService) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => _MainNavigation(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => HomeScreen(authService: authService),
          ),
          GoRoute(path: '/news', builder: (_, __) => const NewsScreen()),
          GoRoute(
            path: '/bus-lines',
            builder: (_, __) => const BusLinesScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => LoginScreen(authService: authService),
      ),
      GoRoute(
        path: '/pharmacies',
        builder:
            (_, __) => const PlaceholderScreen(
              title: 'Nöbetçi Eczaneler',
              icon: Icons.local_pharmacy,
            ),
      ),
      GoRoute(
        path: '/emergency',
        builder:
            (_, __) => const PlaceholderScreen(
              title: 'Acil Numaralar',
              icon: Icons.emergency,
            ),
      ),
      GoRoute(
        path: '/weather',
        builder:
            (_, __) => const PlaceholderScreen(
              title: 'Hava Durumu',
              icon: Icons.cloud,
            ),
      ),
      GoRoute(
        path: '/earthquakes',
        builder:
            (_, __) => const PlaceholderScreen(
              title: 'Depremler',
              icon: Icons.vibration,
            ),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(child: Text('Sayfa bulunamadı: ${state.uri}')),
        ),
  );
}

class _MainNavigation extends StatelessWidget {
  final Widget child;
  const _MainNavigation({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selected =
        location.startsWith('/news')
            ? 1
            : location.startsWith('/bus-lines')
            ? 2
            : 0;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected:
            (index) => context.go(['/', '/news', '/bus-lines'][index]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'Haberler',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_bus_outlined),
            selectedIcon: Icon(Icons.directions_bus),
            label: 'Otobüs',
          ),
        ],
      ),
    );
  }
}

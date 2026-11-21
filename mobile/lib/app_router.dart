// lib/app_router.dart
// Hafta 1: go_router ile uygulama yönlendirme yapısı

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/news_screen.dart';
import 'screens/bus_lines_screen.dart';
import 'screens/local_info_screens.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_management_screens.dart';
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
          GoRoute(
            path: '/news',
            builder: (_, __) => NewsScreen(authService: authService),
          ),
          GoRoute(
            path: '/bus-lines',
            builder: (_, __) => const BusLinesScreen(),
          ),
          GoRoute(
            path: '/pharmacies',
            builder: (_, __) => const PharmaciesScreen(),
          ),
          GoRoute(
            path: '/emergency',
            builder: (_, __) => const EmergencyContactsScreen(),
          ),
          GoRoute(path: '/weather', builder: (_, __) => const WeatherScreen()),
          GoRoute(
            path: '/earthquakes',
            builder: (_, __) => const EarthquakesScreen(),
          ),
          GoRoute(
            path: '/admin',
            redirect: (_, __) => _adminRedirect(authService),
            builder: (_, __) => AdminDashboardScreen(authService: authService),
          ),
          GoRoute(
            path: '/admin/bus-lines',
            redirect: (_, __) => _adminRedirect(authService),
            builder: (_, __) => AdminBusLinesScreen(authService: authService),
          ),
          GoRoute(
            path: '/admin/pharmacies',
            redirect: (_, __) => _adminRedirect(authService),
            builder: (_, __) => AdminPharmaciesScreen(authService: authService),
          ),
          GoRoute(
            path: '/admin/emergency-contacts',
            redirect: (_, __) => _adminRedirect(authService),
            builder:
                (_, __) =>
                    AdminEmergencyContactsScreen(authService: authService),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => LoginScreen(authService: authService),
      ),
      GoRoute(
        path: '/admin-login',
        builder:
            (_, __) => LoginScreen(authService: authService, adminOnly: true),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(child: Text('Sayfa bulunamadı: ${state.uri}')),
        ),
  );
}

String? _adminRedirect(AuthService authService) {
  if (!authService.isLoggedIn) return '/admin-login';
  if (!authService.isAdmin) return '/';
  return null;
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

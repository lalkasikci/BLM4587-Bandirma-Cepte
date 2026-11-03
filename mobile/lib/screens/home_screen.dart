// lib/screens/home_screen.dart
// Hafta 1: Ana sayfa iskeleti — menü kartları ile tüm bölümlere yönlendirme

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService authService;
  const HomeScreen({super.key, required this.authService});

  static const _items = [
    _MenuItem(icon: Icons.newspaper,       label: 'Haberler',         route: '/news'),
    _MenuItem(icon: Icons.directions_bus,  label: 'Otobüs Hatları',   route: '/bus-lines'),
    _MenuItem(icon: Icons.local_pharmacy,  label: 'Nöbetçi Eczane',   route: '/pharmacies'),
    _MenuItem(icon: Icons.emergency,       label: 'Acil Numaralar',   route: '/emergency'),
    _MenuItem(icon: Icons.cloud,           label: 'Hava Durumu',      route: '/weather'),
    _MenuItem(icon: Icons.vibration,       label: 'Depremler',        route: '/earthquakes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bandırma Cepte'),
        backgroundColor: const Color(0xFF1F3864),
        foregroundColor: Colors.white,
        actions: [
          if (authService.isLoggedIn)
            PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle),
              onSelected: (value) async {
                if (value == 'logout') {
                  await authService.logout();
                  if (context.mounted) context.go('/');
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text(
                    '${authService.current?.username ?? ''} (${authService.current?.role ?? ''})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'logout', child: Text('Çıkış Yap')),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.login),
              tooltip: 'Giriş Yap',
              onPressed: () => context.go('/login'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Üst banner
          Container(
            width: double.infinity,
            color: const Color(0xFF1F3864),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bandırma\'ya dair her şey\nbir dokunuşta.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (authService.isAdmin) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '👑 Admin paneli aktif',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Menü grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return _MenuCard(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String route;
  const _MenuItem({required this.icon, required this.label, required this.route});
}

class _MenuCard extends StatelessWidget {
  final _MenuItem item;
  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go(item.route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 42, color: const Color(0xFF1F3864)),
              const SizedBox(height: 10),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

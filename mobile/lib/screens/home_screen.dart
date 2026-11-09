import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService authService;
  const HomeScreen({super.key, required this.authService});

  static const _shortcuts = [
    (Icons.newspaper_rounded, 'Yerel haberler', '/news', Color(0xFFEAF3FF)),
    (
      Icons.directions_bus_rounded,
      'Otobüs saatleri',
      '/bus-lines',
      Color(0xFFE8F7F3),
    ),
    (
      Icons.local_pharmacy_rounded,
      'Nöbetçi eczane',
      '/pharmacies',
      Color(0xFFFFF1E8),
    ),
    (
      Icons.emergency_rounded,
      'Acil numaralar',
      '/emergency',
      Color(0xFFFFECEC),
    ),
    (Icons.cloud_rounded, 'Hava durumu', '/weather', Color(0xFFEAF6FB)),
    (Icons.vibration_rounded, 'Depremler', '/earthquakes', Color(0xFFF2EEFA)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Bandırma Cepte',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFF123B5D),
        foregroundColor: Colors.white,
        actions: [
          if (authService.isLoggedIn)
            PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle_outlined),
              onSelected: (value) async {
                if (value == 'logout') {
                  await authService.logout();
                  if (context.mounted) context.go('/');
                }
              },
              itemBuilder:
                  (_) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Text(
                        '${authService.current?.username} (${authService.current?.role})',
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Text('Çıkış Yap'),
                    ),
                  ],
            )
          else
            IconButton(
              tooltip: 'Giriş yap',
              onPressed: () => context.push('/login'),
              icon: const Icon(Icons.login),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF123B5D), Color(0xFF147D9A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'BANDIRMA’DAN HABERDAR OL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Şehrin cebinizde.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bandırma’ya dair güncel bilgiye kolayca ulaşın.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .84),
                    fontSize: 14,
                  ),
                ),
                if (authService.isAdmin) ...[
                  const SizedBox(height: 14),
                  const Chip(
                    avatar: Icon(Icons.admin_panel_settings, size: 18),
                    label: Text('Yönetici oturumu açık'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Hızlı erişim',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF18364B),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _shortcuts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final item = _shortcuts[index];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => context.go(item.$3),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: item.$4,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(item.$1, color: const Color(0xFF176B88)),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.$2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 17,
                              color: Color(0xFF78909C),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          Card(
            color: const Color(0xFFEAF5F7),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => context.go('/bus-lines'),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: Color(0xFF147D9A)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Otobüs seferlerini görüntüle',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

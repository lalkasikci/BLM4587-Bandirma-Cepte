import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final AuthService authService;
  const HomeScreen({super.key, required this.authService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _shortcuts = [
    (Icons.newspaper_rounded, 'Yerel haberler', '/news', Color(0xFFE4F3F0)),
    (
      Icons.directions_bus_rounded,
      'Otobüs saatleri',
      '/bus-lines',
      Color(0xFFE1F4ED),
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
    final authService = widget.authService;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F6),
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/bandirma_cepte_icon.png',
                width: 38,
                height: 38,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Bandırma Cepte',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF073B4C),
        foregroundColor: Colors.white,
        actions: [
          if (authService.isLoggedIn)
            PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle_outlined),
              onSelected: (value) async {
                if (value == 'logout') {
                  try {
                    await authService.logout();
                    if (!context.mounted) return;
                    setState(() {});
                    context.go('/');
                  } catch (error) {
                    if (!context.mounted) return;
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Oturum kapatıldı ancak kayıtlı oturum temizlenemedi: $error',
                        ),
                      ),
                    );
                  }
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
            PopupMenuButton<String>(
              tooltip: 'Oturum aç',
              icon: const Icon(Icons.login_rounded),
              onSelected: (value) => context.push(value),
              itemBuilder:
                  (_) => const [
                    PopupMenuItem(
                      value: '/login',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.person_outline),
                        title: Text('Kullanıcı girişi'),
                      ),
                    ),
                    PopupMenuItem(
                      value: '/admin-login',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.admin_panel_settings_outlined),
                        title: Text('Yönetici girişi'),
                      ),
                    ),
                  ],
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
                colors: [
                  Color(0xFF073B4C),
                  Color(0xFF087E8B),
                  Color(0xFF20A39E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.asset(
                        'assets/bandirma_cepte_icon.png',
                        width: 66,
                        height: 82,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'BANDIRMA’DAN\nHABERDAR OL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w800,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
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
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/admin'),
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text('Yönetim panelini aç'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!authService.isLoggedIn) ...[
            const SizedBox(height: 14),
            Material(
              color: const Color(0xFF102B49),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => context.push('/admin-login'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0x33E6B85C),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: Color(0xFFE6B85C),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yönetici misiniz?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Yönetim paneline giriş yapın',
                              style: TextStyle(
                                color: Color(0xFFD9E6ED),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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

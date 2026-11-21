import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/section_app_bar.dart';

class AdminDashboardScreen extends StatefulWidget {
  final AuthService authService;
  const AdminDashboardScreen({super.key, required this.authService});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _api = ApiService();
  late Future<_DashboardCounts> _counts;

  static const _sections = [
    _AdminSection(
      icon: Icons.newspaper_rounded,
      title: 'Haberler',
      description: 'Haber ekle, düzenle ve yayımla',
      route: '/news',
      color: Color(0xFF2D6CDF),
      tint: Color(0xFFEAF1FF),
    ),
    _AdminSection(
      icon: Icons.directions_bus_rounded,
      title: 'Otobüs hatları',
      description: 'Hat ve sefer saatlerini yönet',
      route: '/admin/bus-lines',
      color: Color(0xFF138B75),
      tint: Color(0xFFE5F6F1),
    ),
    _AdminSection(
      icon: Icons.local_pharmacy_rounded,
      title: 'Nöbetçi eczaneler',
      description: 'Adres ve nöbet bilgilerini düzenle',
      route: '/admin/pharmacies',
      color: Color(0xFFE18B39),
      tint: Color(0xFFFFF2E5),
    ),
    _AdminSection(
      icon: Icons.emergency_rounded,
      title: 'Acil numaralar',
      description: 'Kurum ve telefon kayıtlarını yönet',
      route: '/admin/emergency-contacts',
      color: Color(0xFFD95757),
      tint: Color(0xFFFFECEC),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _counts = _loadCounts();
  }

  Future<_DashboardCounts> _loadCounts() async {
    final results = await Future.wait([
      _api.getNews(includeUnpublished: true),
      _api.getBusLines(),
      _api.getPharmacies(),
      _api.getEmergencyContacts(),
    ]);
    return _DashboardCounts(
      news: (results[0] as List).length,
      buses: (results[1] as List).length,
      pharmacies: (results[2] as List).length,
      emergency: (results[3] as List).length,
    );
  }

  void _refresh() {
    setState(() {
      _counts = _loadCounts();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF3F6FB),
    appBar: sectionAppBar(
      context,
      'Yönetim Merkezi',
      actions: [
        IconButton(
          tooltip: 'Özet bilgileri yenile',
          onPressed: _refresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        children: [
          _WelcomeBanner(
            username: widget.authService.current?.username ?? 'Yönetici',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Genel Bakış',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18364B),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Uygulamadaki yönetilen kayıtlar',
                      style: TextStyle(color: Color(0xFF748693), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.insights_rounded, color: Color(0xFF147D9A)),
            ],
          ),
          const SizedBox(height: 10),
          FutureBuilder<_DashboardCounts>(
            future: _counts,
            builder: (context, snapshot) {
              final counts = snapshot.data;
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: [
                  _CountCard(
                    icon: Icons.newspaper_rounded,
                    label: 'Haber',
                    count: counts?.news,
                    color: const Color(0xFF2D6CDF),
                  ),
                  _CountCard(
                    icon: Icons.directions_bus_rounded,
                    label: 'Otobüs hattı',
                    count: counts?.buses,
                    color: const Color(0xFF138B75),
                  ),
                  _CountCard(
                    icon: Icons.local_pharmacy_rounded,
                    label: 'Eczane',
                    count: counts?.pharmacies,
                    color: const Color(0xFFE18B39),
                  ),
                  _CountCard(
                    icon: Icons.emergency_rounded,
                    label: 'Acil kayıt',
                    count: counts?.emergency,
                    color: const Color(0xFFD95757),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          const Text(
            'Yönetim Alanları',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF18364B),
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            itemCount: _sections.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.05,
            ),
            itemBuilder:
                (context, index) => _SectionCard(
                  section: _sections[index],
                  onTap: () => context.push(_sections[index].route),
                ),
          ),
          const SizedBox(height: 14),
          const _SecurityNote(),
        ],
      ),
    ),
  );
}

class _WelcomeBanner extends StatelessWidget {
  final String username;
  const _WelcomeBanner({required this.username});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        colors: [Color(0xFF102B49), Color(0xFF176987), Color(0xFF218F9A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF123B5D).withValues(alpha: .2),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Stack(
      children: [
        const Positioned(
          right: -10,
          top: -20,
          child: Icon(
            Icons.shield_rounded,
            size: 116,
            color: Color(0x22FFFFFF),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    size: 15,
                    color: Color(0xFFFFD879),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'YÖNETİCİ MODU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Merhaba, $username',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Bandırma Cepte içerik ve şehir hizmetlerini buradan yönetebilirsin.',
              style: TextStyle(color: Color(0xFFD9EEF2), height: 1.4),
            ),
          ],
        ),
      ],
    ),
  );
}

class _CountCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  final Color color;
  const _CountCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE8EDF2)),
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count?.toString() ?? '–',
                style: TextStyle(
                  fontSize: 19,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Color(0xFF667B87)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AdminSection {
  final IconData icon;
  final String title;
  final String description;
  final String route;
  final Color color;
  final Color tint;
  const _AdminSection({
    required this.icon,
    required this.title,
    required this.description,
    required this.route,
    required this.color,
    required this.tint,
  });
}

class _SectionCard extends StatelessWidget {
  final _AdminSection section;
  final VoidCallback onTap;
  const _SectionCard({required this.section, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: section.tint,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(section.icon, color: section.color, size: 24),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_outward_rounded,
                  color: section.color,
                  size: 20,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF19384B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  section.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    color: Color(0xFF758894),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF5F7),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline_rounded, color: Color(0xFF147D9A), size: 20),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Yönetim işlemleri JWT ile doğrulanır. Kayıtları yalnızca Admin rolüne sahip hesaplar değiştirebilir.',
            style: TextStyle(
              color: Color(0xFF466674),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}

class _DashboardCounts {
  final int news;
  final int buses;
  final int pharmacies;
  final int emergency;
  const _DashboardCounts({
    required this.news,
    required this.buses,
    required this.pharmacies,
    required this.emergency,
  });
}

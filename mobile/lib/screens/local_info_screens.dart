import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/local_info.dart';
import '../services/api_service.dart';
import '../widgets/section_app_bar.dart';

class PharmaciesScreen extends StatefulWidget {
  const PharmaciesScreen({super.key});

  @override
  State<PharmaciesScreen> createState() => _PharmaciesScreenState();
}

class _PharmaciesScreenState extends State<PharmaciesScreen> {
  final _api = ApiService();
  late Future<List<Pharmacy>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getPharmacies();
  }

  void _refresh() => setState(() => _future = _api.getPharmacies());

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: sectionAppBar(context, 'Nöbetçi Eczaneler'),
    body: AsyncListView<Pharmacy>(
      future: _future,
      emptyMessage: 'Eczane kaydı bulunamadı.',
      emptyIcon: Icons.local_pharmacy_outlined,
      onRetry: _refresh,
      itemBuilder:
          (context, pharmacy) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor:
                        pharmacy.isOnCall
                            ? const Color(0xFFFFE9E9)
                            : const Color(0xFFEAF3FF),
                    child: Icon(
                      Icons.local_pharmacy_rounded,
                      color:
                          pharmacy.isOnCall
                              ? Colors.redAccent
                              : const Color(0xFF176B88),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                pharmacy.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (pharmacy.isOnCall)
                              const _StatusChip(
                                label: 'NÖBETÇİ',
                                color: Colors.redAccent,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pharmacy.address,
                          style: const TextStyle(
                            color: Color(0xFF5B707A),
                            height: 1.35,
                          ),
                        ),
                        if (pharmacy.phone?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 9),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 16,
                                color: Color(0xFF147D9A),
                              ),
                              const SizedBox(width: 6),
                              SelectableText(
                                pharmacy.phone!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF147D9A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    ),
  );
}

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final _api = ApiService();
  late Future<List<EmergencyContact>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getEmergencyContacts();
  }

  void _refresh() => setState(() => _future = _api.getEmergencyContacts());

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: sectionAppBar(context, 'Acil Numaralar'),
    body: AsyncListView<EmergencyContact>(
      future: _future,
      emptyMessage: 'Acil numara kaydı bulunamadı.',
      emptyIcon: Icons.emergency_outlined,
      onRetry: _refresh,
      itemBuilder:
          (context, contact) => Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFFFECEC),
                    child: Icon(Icons.call_rounded, color: Colors.redAccent),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                contact.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (contact.category?.isNotEmpty ?? false)
                              _StatusChip(
                                label: contact.category!,
                                color: const Color(0xFF176B88),
                              ),
                          ],
                        ),
                        if (contact.description?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 5),
                          Text(
                            contact.description!,
                            style: const TextStyle(
                              color: Color(0xFF5B707A),
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                        const SizedBox(height: 9),
                        SelectableText(
                          contact.phoneNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF147D9A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    ),
  );
}

class EarthquakesScreen extends StatefulWidget {
  const EarthquakesScreen({super.key});

  @override
  State<EarthquakesScreen> createState() => _EarthquakesScreenState();
}

class _EarthquakesScreenState extends State<EarthquakesScreen> {
  final _api = ApiService();
  late Future<List<Earthquake>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getEarthquakes();
  }

  void _refresh() => setState(() => _future = _api.getEarthquakes());

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: sectionAppBar(context, 'Deprem Bilgileri'),
    body: AsyncListView<Earthquake>(
      future: _future,
      emptyMessage: 'Deprem kaydı bulunamadı.',
      emptyIcon: Icons.vibration_rounded,
      onRetry: _refresh,
      itemBuilder: (context, earthquake) {
        final strong = earthquake.magnitude >= 3.5;
        final date = DateFormat(
          'dd MMM yyyy · HH:mm',
          'tr',
        ).format(earthquake.occurrenceTime.toLocal());
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color:
                        strong
                            ? const Color(0xFFFFE9E9)
                            : const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.waves_rounded,
                        size: 18,
                        color:
                            strong ? Colors.redAccent : const Color(0xFF176B88),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        earthquake.magnitude.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color:
                              strong
                                  ? Colors.redAccent
                                  : const Color(0xFF176B88),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        earthquake.location,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        date,
                        style: const TextStyle(
                          color: Color(0xFF5B707A),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            'Derinlik: ${earthquake.depth.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5B707A),
                            ),
                          ),
                          if (earthquake.source?.isNotEmpty ?? false) ...[
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                earthquake.source!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF147D9A),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _api = ApiService();
  late Future<WeatherSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getWeather();
  }

  void _refresh() => setState(() => _future = _api.getWeather());

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: sectionAppBar(context, 'Bandırma Hava Durumu'),
    body: FutureBuilder<WeatherSnapshot>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Hava durumu yüklenemedi.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Yeniden Dene'),
                  ),
                ],
              ),
            ),
          );
        }
        final weather = snapshot.data!;
        final condition = _weatherCondition(weather.weatherCode);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF147D9A), Color(0xFF65B8C8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BANDIRMA · BALIKESİR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(condition.$2, size: 58, color: Colors.white),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weather.temperature.round()}°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 52,
                              height: 1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            condition.$1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 21),
                  Row(
                    children: [
                      Expanded(
                        child: _WeatherMetric(
                          icon: Icons.thermostat,
                          label: 'Hissedilen',
                          value: '${weather.apparentTemperature.round()}°',
                        ),
                      ),
                      Expanded(
                        child: _WeatherMetric(
                          icon: Icons.water_drop_outlined,
                          label: 'Nem',
                          value: '%${weather.humidity}',
                        ),
                      ),
                      Expanded(
                        child: _WeatherMetric(
                          icon: Icons.air_rounded,
                          label: 'Rüzgâr',
                          value: '${weather.windSpeed.round()} km/sa',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              '5 günlük tahmin',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF18364B),
              ),
            ),
            const SizedBox(height: 10),
            ...weather.forecast.map((day) {
              final dayCondition = _weatherCondition(day.weatherCode);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('EEEE, d MMM', 'tr').format(day.date),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(dayCondition.$2, color: const Color(0xFF147D9A)),
                      const SizedBox(width: 10),
                      Text(
                        '${day.minimum.round()}°',
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        '${day.maximum.round()}°',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Kaynak: Open-Meteo · Tahmin verisidir.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey, fontSize: 11),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _WeatherMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _WeatherMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: Colors.white70, size: 19),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
    ],
  );
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900),
    ),
  );
}

(String, IconData) _weatherCondition(int code) {
  if (code == 0) return ('Açık', Icons.wb_sunny_rounded);
  if (code <= 3) return ('Parçalı bulutlu', Icons.cloud_rounded);
  if (code == 45 || code == 48) return ('Sisli', Icons.foggy);
  if (code >= 51 && code <= 67 || code >= 80 && code <= 82) {
    return ('Yağmurlu', Icons.umbrella_rounded);
  }
  if (code >= 71 && code <= 77 || code >= 85 && code <= 86) {
    return ('Karlı', Icons.ac_unit_rounded);
  }
  if (code >= 95) {
    return ('Gök gürültülü', Icons.thunderstorm_rounded);
  }
  return ('Bulutlu', Icons.cloud_rounded);
}

// lib/screens/bus_lines_screen.dart
// Hafta 1 + 2: Otobüs hatları ekranı — GET /api/buslines

import 'package:flutter/material.dart';
import '../models/bus_line.dart';
import '../services/api_service.dart';

class BusLinesScreen extends StatefulWidget {
  const BusLinesScreen({super.key});

  @override
  State<BusLinesScreen> createState() => _BusLinesScreenState();
}

class _BusLinesScreenState extends State<BusLinesScreen> {
  final _api = ApiService();
  late Future<List<BusLine>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getBusLines();
  }

  void _refresh() => setState(() => _future = _api.getBusLines());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Otobüs Hatları'),
        backgroundColor: const Color(0xFF1F3864),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder<List<BusLine>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }
          final lines = snapshot.data ?? [];
          if (lines.isEmpty) {
            return const Center(
              child: Text(
                'Otobüs hattı bulunamadı.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: lines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _BusLineCard(line: lines[i]),
          );
        },
      ),
    );
  }
}

class _BusLineCard extends StatelessWidget {
  final BusLine line;
  const _BusLineCard({required this.line});

  @override
  Widget build(BuildContext context) {
    final schedules = line.schedules;
    final times = line.scheduleList;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F3864),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Hat ${line.lineNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    line.route,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.blueGrey),
              ],
            ),
            if (line.description.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                line.description,
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ],
            if (schedules.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                'Sefer Saatleri:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              ...schedules.map(
                (schedule) => Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              schedule.departureTime,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF147D74),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                schedule.dayType,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${schedule.departurePoint.isEmpty ? 'Kalkış' : schedule.departurePoint}  →  ${schedule.arrivalPoint.isEmpty ? line.route : schedule.arrivalPoint}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (schedules.isEmpty && times.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                'Sefer Saatleri:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children:
                    times
                        .map(
                          (time) => Chip(
                            label: Text(
                              time,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: const Color(0xFFE8EDF5),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
              ),
            ],
            if (schedules.isEmpty && times.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Sefer saati bilgisi bulunmuyor.',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            message.replaceFirst('Exception: ', ''),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F3864),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

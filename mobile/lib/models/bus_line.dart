// lib/models/bus_line.dart
// Hafta 2: API'den gelen BusLine verisinin Dart modeli

class BusLine {
  final int id;
  final String lineNumber;
  final String route;
  final String scheduleCsv;

  const BusLine({
    required this.id,
    required this.lineNumber,
    required this.route,
    required this.scheduleCsv,
  });

  /// CSV saatlerini listeye çevirir: "07:30,08:00" → ["07:30", "08:00"]
  List<String> get scheduleList =>
      scheduleCsv.isEmpty ? [] : scheduleCsv.split(',').map((s) => s.trim()).toList();

  factory BusLine.fromJson(Map<String, dynamic> json) {
    return BusLine(
      id: json['id'] as int,
      lineNumber: json['lineNumber'] as String,
      route: json['route'] as String,
      scheduleCsv: json['scheduleCsv'] as String? ?? '',
    );
  }
}

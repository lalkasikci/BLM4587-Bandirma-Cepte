// API'den gelen hat ve hatta bağlı kalkış bilgileri.
class BusSchedule {
  final int id;
  final String departureTime;
  final String departurePoint;
  final String arrivalPoint;
  final String dayType;

  const BusSchedule({
    required this.id,
    required this.departureTime,
    required this.departurePoint,
    required this.arrivalPoint,
    required this.dayType,
  });

  factory BusSchedule.fromJson(Map<String, dynamic> json) => BusSchedule(
    id: json['id'] as int? ?? 0,
    departureTime: json['departureTime'] as String? ?? '',
    departurePoint: json['departurePoint'] as String? ?? '',
    arrivalPoint: json['arrivalPoint'] as String? ?? '',
    dayType: json['dayType'] as String? ?? 'Her gün',
  );
}

class BusLine {
  final int id;
  final String lineNumber;
  final String route;
  final String description;
  final String scheduleCsv;
  final List<BusSchedule> schedules;

  const BusLine({
    required this.id,
    required this.lineNumber,
    required this.route,
    required this.description,
    required this.scheduleCsv,
    required this.schedules,
  });

  List<String> get scheduleList {
    if (schedules.isNotEmpty) {
      return schedules.map((schedule) => schedule.departureTime).toList();
    }
    return scheduleCsv.isEmpty
        ? []
        : scheduleCsv.split(',').map((time) => time.trim()).toList();
  }

  factory BusLine.fromJson(Map<String, dynamic> json) => BusLine(
    id: json['id'] as int? ?? 0,
    lineNumber: json['lineNumber'] as String? ?? '',
    route: json['route'] as String? ?? '',
    description: json['description'] as String? ?? '',
    scheduleCsv: json['scheduleCsv'] as String? ?? '',
    schedules:
        (json['schedules'] as List<dynamic>? ?? [])
            .map((item) => BusSchedule.fromJson(item as Map<String, dynamic>))
            .toList(),
  );
}

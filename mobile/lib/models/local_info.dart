class Pharmacy {
  final int id;
  final String name;
  final String address;
  final bool isOnCall;
  final String? phone;

  const Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.isOnCall,
    this.phone,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) => Pharmacy(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    address: json['address'] as String? ?? '',
    isOnCall: json['isOnCall'] as bool? ?? false,
    phone: json['phone'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'isOnCall': isOnCall,
    'phone': phone,
  };
}

class EmergencyContact {
  final int id;
  final String name;
  final String phoneNumber;
  final String? category;
  final String? description;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.category,
    this.description,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        category: json['category'] as String?,
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'category': category,
    'description': description,
  };
}

class Earthquake {
  final int id;
  final double magnitude;
  final String location;
  final double depth;
  final DateTime occurrenceTime;
  final String? source;

  const Earthquake({
    required this.id,
    required this.magnitude,
    required this.location,
    required this.depth,
    required this.occurrenceTime,
    this.source,
  });

  factory Earthquake.fromJson(Map<String, dynamic> json) => Earthquake(
    id: json['id'] as int? ?? 0,
    magnitude: (json['magnitude'] as num?)?.toDouble() ?? 0,
    location: json['location'] as String? ?? '',
    depth: (json['depth'] as num?)?.toDouble() ?? 0,
    occurrenceTime:
        DateTime.tryParse(json['occurrenceTime'] as String? ?? '') ??
        DateTime.now(),
    source: json['source'] as String?,
  );
}

class DailyForecast {
  final DateTime date;
  final double minimum;
  final double maximum;
  final int weatherCode;

  const DailyForecast({
    required this.date,
    required this.minimum,
    required this.maximum,
    required this.weatherCode,
  });
}

class WeatherSnapshot {
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final bool isDay;
  final List<DailyForecast> forecast;

  const WeatherSnapshot({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.isDay,
    required this.forecast,
  });

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    final dates = daily['time'] as List<dynamic>;
    final minimums = daily['temperature_2m_min'] as List<dynamic>;
    final maximums = daily['temperature_2m_max'] as List<dynamic>;
    final codes = daily['weather_code'] as List<dynamic>;
    return WeatherSnapshot(
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).round(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      isDay: (current['is_day'] as num).toInt() == 1,
      forecast: List.generate(
        dates.length,
        (index) => DailyForecast(
          date: DateTime.parse(dates[index] as String),
          minimum: (minimums[index] as num).toDouble(),
          maximum: (maximums[index] as num).toDouble(),
          weatherCode: (codes[index] as num).toInt(),
        ),
      ),
    );
  }
}

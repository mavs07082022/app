class SensorReading {
  final String zoneId;
  final double? airTemperatureC;
  final double? airHumidityPct;
  final double soilTemperatureC;
  final double soilMoisturePct;
  final double soilEcMsCm;
  final double soilSalinity;
  final double soilNMgKg;
  final double soilPMgKg;
  final double soilKMgKg;
  final double soilPh;
  final DateTime? timestamp;

  SensorReading({
    required this.zoneId,
    this.airTemperatureC,
    this.airHumidityPct,
    required this.soilTemperatureC,
    required this.soilMoisturePct,
    this.soilEcMsCm = 0.8,
    this.soilSalinity = 0.5,
    this.soilNMgKg = 80.0,
    this.soilPMgKg = 40.0,
    this.soilKMgKg = 120.0,
    required this.soilPh,
    this.timestamp,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    double? dn(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    double d(dynamic v, [double fallback = 0]) => dn(v) ?? fallback;

    return SensorReading(
      zoneId: (json['zone_id'] ?? '').toString(),
      airTemperatureC: dn(json['air_temperature_c']),
      airHumidityPct: dn(json['air_humidity_pct']),
      soilTemperatureC: d(json['soil_temperature_c']),
      soilMoisturePct: d(json['soil_moisture_pct']),
      soilEcMsCm: d(json['soil_ec_ms_cm'], 0.8),
      soilSalinity: d(json['soil_salinity'], 0.5),
      soilNMgKg: d(json['soil_n_mg_kg'], 80),
      soilPMgKg: d(json['soil_p_mg_kg'], 40),
      soilKMgKg: d(json['soil_k_mg_kg'], 120),
      soilPh: d(json['soil_ph'], 6.5),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'zone_id': zoneId,
        if (airTemperatureC != null) 'air_temperature_c': airTemperatureC,
        if (airHumidityPct != null) 'air_humidity_pct': airHumidityPct,
        'soil_temperature_c': soilTemperatureC,
        'soil_moisture_pct': soilMoisturePct,
        'soil_ec_ms_cm': soilEcMsCm,
        'soil_salinity': soilSalinity,
        'soil_n_mg_kg': soilNMgKg,
        'soil_p_mg_kg': soilPMgKg,
        'soil_k_mg_kg': soilKMgKg,
        'soil_ph': soilPh,
        if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
      };
}
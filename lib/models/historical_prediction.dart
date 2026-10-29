class HistoryDataPoint {
  final String timeStr;
  final DateTime parsedTime;
  final double moisture;
  final double temp;
  final double humidity;
  final String bestCrop;

  HistoryDataPoint({
    required this.timeStr,
    required this.parsedTime,
    required this.moisture, 
    required this.temp, 
    required this.humidity,
    required this.bestCrop,
  });

  factory HistoryDataPoint.fromJson(Map<String, dynamic> json) {
    // FORCE THE PHONE'S TIME INSTEAD OF THE PI'S TIME
    return HistoryDataPoint(
      timeStr: json['time']?.toString() ?? '',
      parsedTime: DateTime.now(), // <--- This fixes the AM/PM issue
      moisture: (json['moisture'] as num?)?.toDouble() ?? 0.0,
      temp: (json['temp'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      bestCrop: (json['best_crop'] ?? 'Unknown').toString(),
    );
  }
}

class ZoneHistory {
  final String zoneId;
  final String zoneName;
  final List<HistoryDataPoint> data;

  ZoneHistory({required this.zoneId, required this.zoneName, required this.data});

  factory ZoneHistory.fromJson(Map<String, dynamic> json) {
    return ZoneHistory(
      zoneId: (json['zone_id'] ?? '').toString(),
      zoneName: (json['zone_name'] ?? '').toString(),
      data: (json['data'] as List?)?.map((e) => HistoryDataPoint.fromJson((e as Map).cast<String, dynamic>())).toList() ?? [],
    );
  }
}

class AllHistoricalPredictions {
  final List<ZoneHistory> items;
  final DateTime serverTime;
  final String note;

  AllHistoricalPredictions({required this.items, required this.serverTime, required this.note});

  factory AllHistoricalPredictions.fromJson(Map<String, dynamic> json) {
    return AllHistoricalPredictions(
      items: (json['historical'] as List?)?.map((e) => ZoneHistory.fromJson((e as Map).cast<String, dynamic>())).toList() ?? [],
      serverTime: DateTime.now(),
      note: (json['note'] ?? '').toString(),
    );
  }
}
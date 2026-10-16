class ApiConfig {
static String baseUrl = 'http://10.42.0.1:8000';
  static const String health = '/health';
  static const String zones = '/zones';
  static const String predict = '/predict';
  static const String crops = '/crops';
  static const String historical = '/historical';

  static const Duration timeout = Duration(seconds: 15);
  static const Duration pollInterval = Duration(seconds: 5);
}
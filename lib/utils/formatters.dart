import 'package:intl/intl.dart';

class Fmt {
  static final _time  = DateFormat('HH:mm:ss');
  static final _clock = DateFormat('HH:mm');

  static String time(DateTime? dt)  => dt == null ? '--:--' : _time.format(dt.toLocal());
  static String clock(DateTime? dt) => dt == null ? '--:--' : _clock.format(dt.toLocal());
  static String one(double v) => v.toStringAsFixed(1);
  static String two(double v) => v.toStringAsFixed(2);
  static String pct(double v) => '${(v * 100).toStringAsFixed(1)}%';

  static String ago(DateTime? dt) {
    if (dt == null) return 'never';

    // Normalize both to UTC to avoid timezone/clock-drift issues
    final nowUtc     = DateTime.now().toUtc();
    final updatedUtc = dt.toUtc();
    final diff = nowUtc.difference(updatedUtc);

    // If the timestamp is in the future (Pi clock is ahead),
    // just show "just now" — it's almost certainly fresh data.
    if (diff.isNegative) return 'just now';

    if (diff.inSeconds < 5)   return 'just now';
    if (diff.inSeconds < 60)  return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)    return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
import 'package:intl/intl.dart';

class Fmt {
  static final _time  = DateFormat('hh:mm:ss a'); 
  static final _clock = DateFormat('hh:mm a');
  static final _history = DateFormat('MMM dd, yyyy • hh:mm a'); 

  static String time(DateTime? dt)  => dt == null ? '--:--' : _time.format(dt.toLocal());
  static String clock(DateTime? dt) => dt == null ? '--:--' : _clock.format(dt.toLocal());
  static String historyTime(DateTime? dt) => dt == null ? '--:--' : _history.format(dt.toLocal());
  
  static String one(double v) => v.toStringAsFixed(1);
  static String two(double v) => v.toStringAsFixed(2);
  static String pct(double v) => '${(v * 100).toStringAsFixed(1)}%';

  static String ago(DateTime? dt) {
    if (dt == null) return 'never';
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.isNegative || diff.inSeconds < 10) return 'just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
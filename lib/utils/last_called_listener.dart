import 'package:shared_preferences/shared_preferences.dart';

class LastCalledListener {
  final String id;
  final String name;
  final String image;
  final DateTime time;

  LastCalledListener({
    required this.id,
    required this.name,
    required this.image,
    required this.time,
  });

  /// Human readable relative time e.g. "2 mins ago", "yesterday"
  String get timeLabel {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}

/// Call this every time a call is placed to any listener (video or audio,
/// real or fake), from any screen.
Future<void> saveLastCalledListener({
  required String id,
  required String name,
  required String image,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_listener_id', id);
  await prefs.setString('last_listener_name', name);
  await prefs.setString('last_listener_image', image);
  await prefs.setString('last_listener_time', DateTime.now().toIso8601String());
}

/// Reads back the last called listener, or null if none saved yet.
Future<LastCalledListener?> getLastCalledListener() async {
  final prefs = await SharedPreferences.getInstance();
  final id = prefs.getString('last_listener_id');
  final name = prefs.getString('last_listener_name');
  final image = prefs.getString('last_listener_image');
  final timeStr = prefs.getString('last_listener_time');

  if (id == null || name == null || timeStr == null) return null;

  return LastCalledListener(
    id: id,
    name: name,
    image: image ?? '',
    time: DateTime.tryParse(timeStr) ?? DateTime.now(),
  );
}
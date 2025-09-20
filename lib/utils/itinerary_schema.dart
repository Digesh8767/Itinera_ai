import 'package:google_generative_ai/google_generative_ai.dart';

// Strict response schema for Day 1 simple itinerary
final itineraryDayOneSchema = Schema.object(properties: {
  'id': Schema.string(),
  'title': Schema.string(),
  'destination': Schema.string(),
  'origin': Schema.string(),
  'duration': Schema.string(),
  'activities': Schema.array(
      items: Schema.object(properties: {
    'time': Schema.string(),
    'description': Schema.string(),
  })),
});

Map<String, dynamic> validateItinerary(Map<String, dynamic> json) {
  // Minimal runtime validation to guard UI
  void _debug(String message) {
    // Always print to the debug console
    // ignore: avoid_print
    print('[ItinerarySchema] ' + message);
  }

  void ensure(bool cond, String msg) {
    if (!cond) {
      _debug('Validation failed: ' + msg + ' | data=' + json.toString());
      throw FormatException('Invalid itinerary: ' + msg);
    }
  }

  _debug('Incoming itinerary json=' + json.toString());

  if (json['title'] is! String) {
    _debug('Title missing, defaulting to "Day 1: Plan"');
    json['title'] = 'Day 1: Plan';
  }
  ensure(json['destination'] is String, 'destination missing');
  // If origin missing or empty, fall back to destination (prevents crashes)
  if (json['origin'] is! String || (json['origin'] as String).trim().isEmpty) {
    _debug('Origin missing/empty, using destination as origin: ' +
        (json['destination']?.toString() ?? ''));
    json['origin'] = json['destination'];
  }
  ensure(json['activities'] is List, 'activities must be a list');
  final activities = List<Map<String, dynamic>>.from(
      (json['activities'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map)));
  ensure(activities.isNotEmpty, 'activities must not be empty');
  for (final a in activities) {
    ensure(a['time'] is String, 'activity.time missing');
    ensure(a['description'] is String, 'activity.description missing');
  }
  _debug('Validated itinerary=' + json.toString());
  return json;
}

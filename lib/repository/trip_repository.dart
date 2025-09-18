import 'package:hive/hive.dart';
import 'package:itinera_ai/models/trip_model.dart';

class TripRepository {
  static const String _tripBoxName = 'trips';
  late Box<TripModel> _tripBox;

  Future<void> init() async {
    _tripBox = await Hive.openBox<TripModel>(_tripBoxName);
  }

  Future<List<TripModel>> getAllTrips() async {
    await init();
    return _tripBox.values.toList();
  }

  Future<TripModel?> getTripById(String id) async {
    await init();
    return _tripBox.get(id);
  }

  Future<void> saveTrip(TripModel trip) async {
    await init();
    await _tripBox.put(trip.id, trip);
  }

  Future<void> deleteTrip(String id) async {
    await init();
    await _tripBox.delete(id);
  }

  Future<void> updateTrip(TripModel trip) async {
    await init();
    await _tripBox.put(trip.id, trip);
  }

  Future<List<TripModel>> getTripsByStatus(TripStatus status) async {
    await init();
    return _tripBox.values.where((trip) => trip.status == status).toList();
  }
}

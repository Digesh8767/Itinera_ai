abstract class ItineraryRepository {
  Future<void> save(Map<String, dynamic> itinerary);
  Future<List<Map<String, dynamic>>> listAll();
  Future<void> delete(String id);
}

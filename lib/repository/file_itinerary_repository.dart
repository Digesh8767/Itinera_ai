import 'package:itinera_ai/repository/itinerary_repository.dart';
import 'package:itinera_ai/services/offline_service_storage.dart';

class FileItineraryRepository implements ItineraryRepository {
  @override
  Future<void> save(Map<String, dynamic> itinerary) async {
    await OfflineStorageService.saveItineraryOffline(itinerary);
  }

  @override
  Future<List<Map<String, dynamic>>> listAll() async {
    return OfflineStorageService.getOfflineItineraries();
  }

  @override
  Future<void> delete(String id) async {
    await OfflineStorageService.deleteOfflineItinerary(id);
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class OfflineStorageService {
  static const String _itinerariesDir = 'itineraries';

  // Save itinerary offline
  static Future<bool> saveItineraryOffline(
      Map<String, dynamic> itinerary) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final itinerariesDir = Directory('${directory.path}/$_itinerariesDir');

      if (!await itinerariesDir.exists()) {
        await itinerariesDir.create(recursive: true);
      }

      final file =
          File('${itinerariesDir.path}/itinerary_${itinerary['id']}.json');
      await file.writeAsString(json.encode(itinerary));

      print('✅ Itinerary saved offline: ${itinerary['id']}');
      return true;
    } catch (e) {
      print('❌ Error saving offline: $e');
      return false;
    }
  }

  // Get all offline itineraries
  static Future<List<Map<String, dynamic>>> getOfflineItineraries() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final itinerariesDir = Directory('${directory.path}/$_itinerariesDir');

      if (!await itinerariesDir.exists()) {
        return [];
      }

      final files = await itinerariesDir.list().toList();
      final itineraries = <Map<String, dynamic>>[];

      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final content = await file.readAsString();
            final itinerary = json.decode(content);
            itineraries.add(itinerary);
            print('📱 Loaded offline itinerary: ${itinerary['id']}');
          } catch (e) {
            print('❌ Error reading file ${file.path}: $e');
          }
        }
      }

      return itineraries;
    } catch (e) {
      print('❌ Error getting offline itineraries: $e');
      return [];
    }
  }

  // Delete offline itinerary
  static Future<bool> deleteOfflineItinerary(String itineraryId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/$_itinerariesDir/itinerary_$itineraryId.json');

      if (await file.exists()) {
        await file.delete();
        print('🗑️ Deleted offline itinerary: $itineraryId');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error deleting offline itinerary: $e');
      return false;
    }
  }
}

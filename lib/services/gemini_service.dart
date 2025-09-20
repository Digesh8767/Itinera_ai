import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyC2eteUn1rcLwloiF1Out7Ih8eO56cyQU4';

  static Future<Map<String, dynamic>> generateItinerary(
      String tripDescription) async {
    try {
      print('🤖 GeminiService: Generating itinerary for: $tripDescription');

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final prompt = '''
Create a travel itinerary based on this description: "$tripDescription"

Generate a simple, clean itinerary in this EXACT format:
{
  "id": "unique_id",
  "title": "Day 1: [Brief Day Title]",
  "destination": "Destination City, Country",
  "origin": "Origin City, Country",
  "duration": "Xhrs Xmins",
  "activities": [
    {
      "time": "Morning/Afternoon/Evening/Transfer/Accommodation",
      "description": "Activity description"
    }
  ]
}

Requirements:
- Generate realistic travel times and activities
- Include specific locations and landmarks
- Make it practical and achievable
- Use proper city names
- Keep descriptions concise but informative
- Focus on the user's specific request

Example format:
{
  "id": "bali_trip_001",
  "title": "Day 1: Arrival in Bali & Settle in Ubud",
  "destination": "Bali, Indonesia",
  "origin": "Mumbai, India",
  "duration": "11hrs 5mins",
  "activities": [
    {
      "time": "Morning",
      "description": "Arrive in Bali, Denpasar Airport"
    },
    {
      "time": "Transfer", 
      "description": "Private driver to Ubud (around 1.5 hours)"
    },
    {
      "time": "Accommodation",
      "description": "Check-in at a peaceful boutique hotel or villa in Ubud"
    },
    {
      "time": "Afternoon",
      "description": "Explore Ubud's local area, walk around the tranquil rice terraces at Tegallalang"
    },
    {
      "time": "Evening",
      "description": "Dinner at Locavore (known for farm-to-table dishes in peaceful environment)"
    }
  ]
}

Generate ONLY the JSON response, no additional text.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final responseText = response.text ?? '';

      print('🤖 GeminiService: Raw response: $responseText');

      // Parse the JSON response
      try {
        // Clean the response text to extract JSON
        String cleanResponse = responseText.trim();

        // Try to find JSON in the response
        if (cleanResponse.contains('{') && cleanResponse.contains('}')) {
          final startIndex = cleanResponse.indexOf('{');
          final endIndex = cleanResponse.lastIndexOf('}') + 1;
          cleanResponse = cleanResponse.substring(startIndex, endIndex);
        }

        final jsonResponse = json.decode(cleanResponse);
        print('✅ GeminiService: Successfully parsed JSON: $jsonResponse');

        return jsonResponse;
      } catch (e) {
        print('❌ GeminiService: JSON parsing failed: $e');
        print('Raw response: $responseText');

        // If JSON parsing fails, create a fallback response
        return _createFallbackItinerary(tripDescription);
      }
    } catch (e) {
      final err = e.toString().toLowerCase();
      print('❌ GeminiService: Error: $e');
      print('Error type: ${e.runtimeType}');

      if (err.contains('quota') ||
          err.contains('rate') ||
          err.contains('429') ||
          err.contains('503')) {
        final fb = _defaultQuotaItinerary();
        fb['source'] = 'fallback_quota';
        return fb;
      }
      final fb = _createFallbackItinerary(tripDescription);
      fb['source'] = 'fallback_error';
      return fb;
    }
  }

  static Future<Map<String, dynamic>> generateFollowUpResponse(
    String originalPrompt,
    Map<String, dynamic> currentItinerary,
    String followUpMessage,
  ) async {
    try {
      print(
          '🤖 GeminiService: Generating follow-up response for: $followUpMessage');

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final prompt = '''
You are a travel planning AI. The user is making a NEW travel request, not asking for modifications to the previous itinerary.

IGNORE the previous itinerary completely. Focus ONLY on the user's new request.

User's NEW travel request: "$followUpMessage"

Create a completely new itinerary based on this request. If the user asks for a multi-day trip (like "5 days from MH to GJ"), create a detailed itinerary with multiple days for that specific route.

IMPORTANT: Use the exact cities/states mentioned in the user's request. If they say "MH to GJ", create an itinerary from Maharashtra to Gujarat.

Generate a simple, clean itinerary in this EXACT format:
{
  "id": "unique_id",
  "title": "Day 1: [Brief Day Title]",
  "destination": "Destination City, Country",
  "origin": "Origin City, Country", 
  "duration": "Xhrs Xmins",
  "activities": [
    {
      "time": "Morning/Afternoon/Evening/Transfer/Accommodation",
      "description": "Activity description"
    }
  ]
}

Requirements:
- Generate realistic travel times and activities
- Include specific locations and landmarks
- Make it practical and achievable
- Use proper city names and coordinates
- Keep descriptions concise but informative
- Focus on the user's specific request

Generate ONLY the JSON response, no additional text.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final responseText = response.text ?? '';

      print('🤖 GeminiService: Raw response: $responseText');

      // Parse the JSON response
      try {
        // Clean the response text to extract JSON
        String cleanResponse = responseText.trim();

        // Try to find JSON in the response
        if (cleanResponse.contains('{') && cleanResponse.contains('}')) {
          final startIndex = cleanResponse.indexOf('{');
          final endIndex = cleanResponse.lastIndexOf('}') + 1;
          cleanResponse = cleanResponse.substring(startIndex, endIndex);
        }

        final jsonResponse = json.decode(cleanResponse);
        print('✅ GeminiService: Successfully parsed JSON: $jsonResponse');

        return {
          'message': 'Here\'s your updated itinerary based on your request:',
          'itinerary': jsonResponse,
        };
      } catch (e) {
        print('❌ GeminiService: JSON parsing failed: $e');
        print('Raw response: $responseText');

        // If JSON parsing fails, create a fallback response
        return {
          'message':
              'I\'ve updated your itinerary based on your request. Here are the details:',
          'itinerary': _createFallbackItinerary(followUpMessage),
        };
      }
    } catch (e) {
      final err = e.toString().toLowerCase();
      print('❌ GeminiService: Error: $e');
      print('Error type: ${e.runtimeType}');

      final fbItinerary = (err.contains('quota') ||
              err.contains('rate') ||
              err.contains('429') ||
              err.contains('503'))
          ? _defaultQuotaItinerary()
          : _createFallbackItinerary(followUpMessage);
      fbItinerary['source'] = (err.contains('quota') ||
              err.contains('rate') ||
              err.contains('429') ||
              err.contains('503'))
          ? 'fallback_quota'
          : 'fallback_error';

      return {
        'message':
            'Showing default itinerary due to API limits. You can retry later for an AI version.',
        'itinerary': fbItinerary,
      };
    }
  }

  static Map<String, dynamic> _createFallbackItinerary(String request) {
    return {
      'id': 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      'title':
          'Day 1: ${request.substring(0, request.length > 30 ? 30 : request.length)}...',
      'destination': 'Destination',
      'origin': 'Origin',
      'duration': 'TBD',
      'activities': [
        {
          'time': 'Morning',
          'description': 'Start your journey based on your request',
        },
        {
          'time': 'Afternoon',
          'description': 'Explore and enjoy your trip',
        },
        {
          'time': 'Evening',
          'description': 'Relax and prepare for the next day',
        },
      ],
    };
  }

  static Map<String, dynamic> _defaultQuotaItinerary() {
    return {
      'id': 'default_bali_quota',
      'title': 'Day 1: Arrival in Bali & Settle in Ubud',
      'destination': 'Bali, Indonesia',
      'origin': 'Mumbai, India',
      'duration': '11hrs 5mins',
      'activities': [
        {'time': 'Morning', 'description': 'Arrive in Bali, Denpasar Airport.'},
        {
          'time': 'Transfer',
          'description': 'Private driver to Ubud (around 1.5 hours).'
        },
        {
          'time': 'Accommodation',
          'description':
              'Check-in at a peaceful boutique hotel or villa in Ubud (e.g., Ubud Aura Retreat or Komaneka at Bisma).'
        },
        {
          'time': 'Afternoon',
          'description':
              'Explore Ubud’s local area, walk around the tranquil rice terraces at Tegallalang.'
        },
        {
          'time': 'Evening',
          'description':
              'Dinner at Locavore (known for farm-to-table dishes in a peaceful setting).'
        },
      ],
    };
  }

  // Test method to verify API connection
  static Future<bool> testConnection() async {
    try {
      print('🧪 Testing Gemini AI connection...');

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final content = [Content.text('Hello, can you respond with just "OK"?')];
      final response = await model.generateContent(content);
      final responseText = response.text ?? '';

      print('🧪 Test response: $responseText');

      return responseText.isNotEmpty;
    } catch (e) {
      print('❌ Gemini AI connection test failed: $e');
      return false;
    }
  }
}

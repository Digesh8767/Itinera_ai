class LocalItineraryTemplates {
  static final List<_Template> _templates = [
    _Template(
      matchers: ['goa to junagadh'],
      data: {
        'id': 'goa_junagadh_default',
        'title': 'Day 1: Coastal Start & Heritage Drive',
        'destination': 'Junagadh, Gujarat',
        'origin': 'Goa, India',
        'duration': '14hrs (with breaks)',
        'activities': [
          {
            'time': 'Morning',
            'description': 'Depart Goa early, breakfast stop near Karwar.'
          },
          {
            'time': 'Afternoon',
            'description':
                'Lunch at Belgaum; continue drive through scenic Western Ghats.'
          },
          {
            'time': 'Evening',
            'description':
                'Arrive Junagadh; check-in and evening walk near Uparkot Fort.'
          },
        ],
      },
    ),
    _Template(
      matchers: ['goa to rajkot'],
      data: {
        'id': 'goa_rajkot_default',
        'title': 'Day 1: Arrival in Rajkot & Local Tastes',
        'destination': 'Rajkot, Gujarat',
        'origin': 'Goa, India',
        'duration': '12hrs 30mins (flight + transfer)',
        'activities': [
          {'time': 'Morning', 'description': 'Fly to Rajkot; hotel check-in.'},
          {
            'time': 'Afternoon',
            'description': 'Visit Jubilee Garden and Watson Museum.'
          },
          {
            'time': 'Evening',
            'description':
                'Dinner: Kathiyawadi thali at a popular local restaurant.'
          },
        ],
      },
    ),
    _Template(
      matchers: ['bali'],
      data: {
        'id': 'default_bali_quota',
        'title': 'Day 1: Arrival in Bali & Settle in Ubud',
        'destination': 'Bali, Indonesia',
        'origin': 'Mumbai, India',
        'duration': '11hrs 5mins',
        'activities': [
          {
            'time': 'Morning',
            'description': 'Arrive in Bali, Denpasar Airport.'
          },
          {
            'time': 'Transfer',
            'description': 'Private driver to Ubud (around 1.5 hours).'
          },
          {
            'time': 'Accommodation',
            'description':
                'Check-in at a boutique hotel/villa in Ubud (e.g., Ubud Aura Retreat or Komaneka at Bisma).'
          },
          {
            'time': 'Afternoon',
            'description': 'Explore Ubud and Tegallalang rice terraces.'
          },
          {
            'time': 'Evening',
            'description': 'Dinner at Locavore (farm-to-table).'
          },
        ],
      },
    ),
    _Template(
      matchers: ['kyoto'],
      data: {
        'id': 'kyoto_5_day_default',
        'title': 'Day 1: Fushimi Inari & Gion',
        'destination': 'Kyoto, Japan',
        'origin': 'Osaka/Kansai',
        'duration': '1hr transfer',
        'activities': [
          {'time': 'Morning', 'description': 'Climb Fushimi Inari Shrine.'},
          {'time': 'Afternoon', 'description': 'Lunch at Nishiki Market.'},
          {'time': 'Evening', 'description': 'Stroll Gion district.'},
        ],
      },
    ),
  ];

  static Map<String, dynamic>? findForPrompt(String prompt) {
    final p = prompt.toLowerCase();
    for (final t in _templates) {
      if (t.matchers.any((m) => p.contains(m))) {
        return Map<String, dynamic>.from(t.data);
      }
    }
    return null;
  }
}

class _Template {
  final List<String> matchers;
  final Map<String, dynamic> data;
  const _Template({required this.matchers, required this.data});
}

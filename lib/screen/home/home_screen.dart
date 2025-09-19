import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinera_ai/core/screen_utils.dart';
import 'package:itinera_ai/screen/home/bloc/home_bloc.dart';
import 'package:itinera_ai/screen/itinerary_process/itinerary_process_screen.dart';
import 'package:itinera_ai/screen/itinerary_process/bloc/itinerary_process_bloc.dart'
    as itinerary_process;
import 'package:itinera_ai/screen/creating_itinerary/creating_itinerary_screen.dart';
import 'package:itinera_ai/screen/profile/profile_screen.dart';
import 'package:itinera_ai/services/firebase_auth_service.dart';
import 'package:itinera_ai/services/offline_service_storage.dart';
import 'package:itinera_ai/services/speech_to_text_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String path = '/home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _tripController = TextEditingController();
  List<Map<String, dynamic>> _offlineItineraries = [];
  Map<String, dynamic>? _latestItinerary; // Add this line

  final List<String> _defaultPrompts = [
    '5 days Goa to Junagadh via road with sightseeing',
    '5 days Goa to Rajkot with heritage and food',
    '3 days in Goa for beaches and local food',
    'Weekend in Munnar focused on tea gardens',
    '4 days Delhi to Manali mountain escape',
    '2 days Ahmedabad to Udaipur couple getaway',
    '7 days Kerala backwaters and Ayurveda retreat',
    '5 days Jaipur, Agra, Delhi Golden Triangle',
    'Kyoto 5-Day Solo Trip with temples and markets',
    '7 days in Bali for peaceful, less crowded places',
  ];

  // Speech-to-text
  final SpeechToTextService _speechService = SpeechToTextService();
  bool _isListening = false;

  Future<void> _toggleMic() async {
    try {
      print('🎤 Home: Toggling microphone...');
      await _speechService.toggleListening(
        onResult: (text) {
          print('🎤 Home: Speech result received: "$text"');
          setState(() {
            _tripController.text = text;
            _tripController.selection = TextSelection.fromPosition(
              TextPosition(offset: _tripController.text.length),
            );
            _isListening = _speechService.isListening;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
      );
      setState(() {
        _isListening = _speechService.isListening;
      });
      print('🎤 Home: Microphone toggled, listening: $_isListening');
    } catch (e) {
      print('🎤 Home: Speech recognition error: $e');
      _speechService.showErrorSnackBar(
        context,
        'Microphone permission required for speech recognition. Please enable it in settings.',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadOfflineItineraries();
    _loadLatestItinerary();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app resumes
      _loadOfflineItineraries();
      _loadLatestItinerary();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when screen becomes visible again
    _loadOfflineItineraries();
    _loadLatestItinerary();
  }

  Future<void> _loadLatestItinerary() async {
    final itineraries = await OfflineStorageService.getOfflineItineraries();
    if (itineraries.isNotEmpty) {
      setState(() {
        _latestItinerary = itineraries.first; // Get the most recent one
      });
    }
  }

  // Add this widget to display the latest itinerary
  Widget _buildLatestItinerary() {
    if (_latestItinerary == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 27.0, vertical: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick default search button row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final p in _defaultPrompts)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: OutlinedButton(
                      onPressed: () {
                        context.go(
                            '${CreatingItineraryScreen.path}?description=${Uri.encodeComponent(p)}');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF3BAB8C)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        p,
                        style: const TextStyle(
                            color: Color(0xFF065F46), fontSize: 12),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Pick one at random
                    final p = _defaultPrompts.first;
                    context.go(
                        '${CreatingItineraryScreen.path}?description=${Uri.encodeComponent(p)}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF065F46),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Try a sample',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Header with title and AI badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3BAB8C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'AI Generated',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3BAB8C),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Latest Trip Plan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Trip title
          Text(
            _latestItinerary!['title'] ?? 'Your Trip',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          // Trip info
          Text(
            '${_latestItinerary!['origin'] ?? 'Origin'} to ${_latestItinerary!['destination'] ?? 'Destination'} | ${_latestItinerary!['duration'] ?? 'Duration'}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 16),

          // Day 1 Plan
          Text(
            'Day 1 Plan',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3BAB8C),
            ),
          ),

          const SizedBox(height: 12),

          // Activities with bullet points
          if (_latestItinerary!['activities'] != null)
            ..._latestItinerary!['activities'].map<Widget>((activity) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6, right: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3BAB8C),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${activity['time']}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: activity['description'],
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList()
          else if (_latestItinerary!['days'] != null &&
              _latestItinerary!['days'].isNotEmpty)
            ..._latestItinerary!['days'][0]['items'].map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6, right: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3BAB8C),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${item['time']}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: item['activity'],
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Reset the itinerary process BLoC before navigating
                    context.read<itinerary_process.ItineraryProcessBloc>().add(
                        const itinerary_process.ResetItineraryProcessEvent());
                    // Navigate to full itinerary view
                    context.go(
                        '${ItineraryProcessScreen.path}?description=${Uri.encodeComponent(_latestItinerary!['title'] ?? '')}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3BAB8C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'View Full Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Save offline functionality
                    _saveItineraryOffline(_latestItinerary!);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3BAB8C),
                    side: const BorderSide(color: Color(0xFF3BAB8C)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Offline',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Add this method to save itinerary offline
  Future<void> _saveItineraryOffline(Map<String, dynamic> itinerary) async {
    try {
      final success =
          await OfflineStorageService.saveItineraryOffline(itinerary);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Itinerary saved offline successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadOfflineItineraries();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save itinerary offline'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error saving offline: $e');
    }
  }

  Future<void> _loadOfflineItineraries() async {
    final itineraries = await OfflineStorageService.getOfflineItineraries();
    setState(() {
      _offlineItineraries = itineraries;
    });
  }

  // Add this widget to show offline itineraries
  Widget _buildOfflineItineraries() {
    if (_offlineItineraries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Offline Itineraries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _offlineItineraries.length,
            itemBuilder: (context, index) {
              final itinerary = _offlineItineraries[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itinerary['title'] ?? 'Trip',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${itinerary['origin']} to ${itinerary['destination']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.offline_bolt,
                          color: Colors.green,
                          size: 16,
                        ),
                        GestureDetector(
                          onTap: () => _deleteOfflineItinerary(itinerary['id']),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _deleteOfflineItinerary(String itineraryId) async {
    final success =
        await OfflineStorageService.deleteOfflineItinerary(itineraryId);
    if (success) {
      await _loadOfflineItineraries();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Itinerary deleted')),
      );
    }
  }

  String _getUserInitial() {
    final user = FirebaseAuthService.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName![0].toUpperCase();
    } else if (user?.email != null) {
      return user!.email![0].toUpperCase();
    }
    return 'U';
  }

  String _getUserName() {
    final user = FirebaseAuthService.currentUser;
    String name = 'User';

    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      name = user.displayName!;
    } else if (user?.email != null) {
      name = user!.email!.split('@')[0];
    }

    // Limit to 10 characters
    if (name.length > 10) {
      name = '${name.substring(0, 10)}...';
    }

    return name;
  }

  void _createItinerary() {
    if (_tripController.text.trim().isNotEmpty) {
      context.go(
          '${CreatingItineraryScreen.path}?description=${Uri.encodeComponent(_tripController.text.trim())}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFAF7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.only(
                  left: 26.0,
                  top: 17,
                  right: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Hey ${_getUserName()}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: GoogleFonts.inter().fontFamily,
                            color: const Color(0xFF065F46),
                          ),
                          overflow: TextOverflow.clip,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '👋',
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push(ProfileScreen.path);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF065F46),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getUserInitial(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Main Question
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 55.0, vertical: 34),
                child: Text(
                  "What's your vision\nfor this trip?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    fontFamily: GoogleFonts.inter().fontFamily,
                    color: Color(0xFF000000),
                  ),
                ),
              ),

              // Trip Description Input
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF3BAB8C),
                      Color(0xFF49A495),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 27.0),
                padding:
                    const EdgeInsets.all(2), // This creates the border effect
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _tripController,
                        maxLines: 4,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF081735),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Describe your dream trip...',
                          hintStyle: TextStyle(
                            color: Color(0xFF8F95B2),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.fromLTRB(
                              16, 16, 50, 16), // Add right padding for mic
                        ),
                      ),
                      // Clickable mic icon
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: GestureDetector(
                          onTap: _toggleMic,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: const Color(0xFF065F46),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: ScreenUtils.height * 0.03),

              // Create Itinerary Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 27.0),
                child: BlocConsumer<HomeBloc, HomeState>(
                  listener: (context, state) {
                    if (state is ItineraryCreated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Reload saved itineraries
                      context
                          .read<HomeBloc>()
                          .add(const LoadSavedItinerariesEvent());
                      // Reload latest itinerary
                      _loadLatestItinerary();
                    } else if (state is ItineraryCreationFailed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state is ItineraryCreating
                            ? null
                            : _createItinerary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF065F46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: state is ItineraryCreating
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Create My Itinerary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: GoogleFonts.inter().fontFamily,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: ScreenUtils.height * 0.037),

              // Latest Itinerary Section
              _buildLatestItinerary(),

              // Offline Saved Itineraries Section
              Text(
                'Offline Saved Itineraries',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0A0A0A),
                ),
              ),
              SizedBox(height: ScreenUtils.height * 0.02),

              _buildOfflineItineraries(),
            ],
          ),
        ),
      ),
    );
  }
}

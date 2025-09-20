import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinera_ai/screen/creating_itinerary/bloc/creating_itinerary_bloc.dart';
import 'package:itinera_ai/screen/home/home_screen.dart';
import 'package:itinera_ai/screen/follow_up_refinement/follow_up_refinement_screen.dart';
import 'package:itinera_ai/services/firebase_auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CreatingItineraryScreen extends StatefulWidget {
  static const String path = '/creating-itinerary';
  final String tripDescription;

  const CreatingItineraryScreen({
    super.key,
    required this.tripDescription,
  });

  @override
  State<CreatingItineraryScreen> createState() =>
      _CreatingItineraryScreenState();
}

class _CreatingItineraryScreenState extends State<CreatingItineraryScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();

    // Start creating itinerary
    context.read<CreatingItineraryBloc>().add(
          StartCreatingItineraryEvent(tripDescription: widget.tripDescription),
        );
  }

  void _startAnimations() {
    _progressController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF7),
      body: SafeArea(
        child: BlocConsumer<CreatingItineraryBloc, CreatingItineraryState>(
          listener: (context, state) {
            if (state is CreatingItineraryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Custom App Bar
                _buildAppBar(),
                // Main Content
                Expanded(
                  child: _buildMainContent(state),
                ),
                // Action Buttons
                _buildActionButtons(state),
                if (state is CreatingItineraryError &&
                    state.message.contains('503'))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      'The AI model is temporarily overloaded (503). Please tap the button again in a few seconds.',
                      style: GoogleFonts.inter(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFAF7),
        border: Border(
          bottom: BorderSide(color: Color(0xFFFFFAF7), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go(HomeScreen.path),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          Text(
            'Home',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF3BAB8C),
            child: Text(
              _getUserInitial(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(CreatingItineraryState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Text(
            state is CreatingItineraryCompleted
                ? 'Itinerary Created 🌴'
                : 'Creating Itinerary...',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Progress or Created top card
          _buildTopCard(state),
          const SizedBox(height: 16),
          if (state is CreatingItineraryStreaming)
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 260),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Text(
                  state.partialText,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ),

          if (state is CreatingItineraryCompleted)
            _buildItineraryPreview(state.itinerary),
        ],
      ),
    );
  }

  Widget _buildItineraryPreview(Map<String, dynamic> itinerary) {
    // Support both simple format (activities) and multi-day format (days[0].items)
    List<Map<String, dynamic>> activities = <Map<String, dynamic>>[];
    if (itinerary['activities'] is List) {
      activities =
          List<Map<String, dynamic>>.from(itinerary['activities'] as List);
    } else if (itinerary['days'] is List &&
        (itinerary['days'] as List).isNotEmpty) {
      final Map<String, dynamic> dayOne =
          Map<String, dynamic>.from((itinerary['days'] as List).first);
      final List itemsRaw =
          (dayOne['items'] ?? dayOne['activities'] ?? []) as List;
      activities = itemsRaw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map((e) => {
                'time': e['time'] ?? (e.containsKey('activity') ? '' : ''),
                'description': e['activity'] ?? e['description'] ?? '',
              })
          .toList();
      // Prefer the day's summary/title if present
      if ((dayOne['summary'] is String) &&
          (dayOne['summary'] as String).isNotEmpty) {
        itinerary = {
          ...itinerary,
          'title': 'Day 1: ${dayOne['summary']}',
        };
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            itinerary['title'] ?? 'Day 1: Plan',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          if (activities.isNotEmpty)
            ...activities.map((a) {
              final time = a['time'] ?? '';
              final desc = a['description'] ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        '$time: $desc',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 12),
          _buildOpenInMapsRow(
            itinerary['destination'] ?? '',
            itinerary['origin'] ?? '',
            itinerary['duration'] ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildOpenInMapsRow(
      String destination, String origin, String duration) {
    final routeText = [
      origin.isNotEmpty ? origin : null,
      destination.isNotEmpty ? destination : null,
    ].whereType<String>().join(' to ');
    final infoText = [
      routeText.isNotEmpty ? routeText : null,
      duration.isNotEmpty ? duration : null,
    ].whereType<String>().join(' | ');

    return InkWell(
      onTap: destination.isEmpty ? null : () => _openInMaps(destination),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.location_on, color: Colors.red, size: 16),
                SizedBox(width: 6),
                Text('Open in maps',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.w600)),
                SizedBox(width: 4),
                Icon(Icons.open_in_new, color: Colors.blue, size: 14),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              infoText,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  void _openInMaps(String destination) {
    final encodedDestination = Uri.encodeComponent(destination);
    final url =
        Uri.parse('https://www.google.com/maps/search/$encodedDestination');
    launchUrl(url);
  }

  Widget _buildTopCard(CreatingItineraryState state) {
    final isLoading = state is! CreatingItineraryCompleted;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 360),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF3BAB8C)),
                          backgroundColor: const Color(0xFFE5E5E5),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Curating a perfect plan for you...',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildActionButtons(CreatingItineraryState state) {
    final isCompleted = state is CreatingItineraryCompleted;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (isCompleted) _buildBottomTripInfo(state.itinerary),
          if (isCompleted) const SizedBox(height: 16),
          // Follow up to refine button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isCompleted
                  ? () {
                      // ignore: unnecessary_cast
                      final completedState =
                          state as CreatingItineraryCompleted;
                      _navigateToFollowUp(completedState.itinerary);
                    }
                  : () => _showNotReadyMessage(),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((s) {
                  if (isCompleted) return const Color(0xFF065F46);
                  return const Color(0xFFCFE3DA);
                }),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                elevation: MaterialStateProperty.all(0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: isCompleted ? Colors.white : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Follow up to refine',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Save offline button
          GestureDetector(
            onTap: isCompleted
                ? () {
                    // ignore: unnecessary_cast
                    final completedState = state as CreatingItineraryCompleted;
                    _saveOffline(completedState.itinerary);
                  }
                : () => _showNotReadyMessage(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download,
                  color:
                      isCompleted ? const Color(0xFF3BAB8C) : Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Save Offline',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isCompleted
                        ? const Color(0xFF3BAB8C)
                        : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTripInfo(Map<String, dynamic> itinerary) {
    final origin = (itinerary['origin'] ?? '').toString();
    final destination = (itinerary['destination'] ?? '').toString();
    final duration = (itinerary['duration'] ?? '').toString();

    final routeText = [
      origin.isNotEmpty ? origin : null,
      destination.isNotEmpty ? destination : null,
    ].whereType<String>().join(' to ');

    final infoText = [
      routeText.isNotEmpty ? routeText : null,
      duration.isNotEmpty ? duration : null,
    ].whereType<String>().join(' | ');

    return InkWell(
      onTap: destination.isEmpty ? null : () => _openInMaps(destination),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.location_on, color: Colors.red, size: 16),
                SizedBox(width: 6),
                Text('Open in maps',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.w600)),
                SizedBox(width: 4),
                Icon(Icons.open_in_new, color: Colors.blue, size: 14),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              infoText,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToFollowUp(Map<String, dynamic> itinerary) {
    // Only proceed if we have a valid itinerary
    if (itinerary.isNotEmpty) {
      final itineraryJson = Uri.encodeComponent(json.encode(itinerary));
      context.go(
        '${FollowUpRefinementScreen.path}?prompt=${Uri.encodeComponent(widget.tripDescription)}&itinerary=$itineraryJson',
      );
    } else {
      _showNotReadyMessage();
    }
  }

  void _saveOffline(Map<String, dynamic> itinerary) {
    // Only proceed if we have a valid itinerary
    if (itinerary.isNotEmpty) {
      context.read<CreatingItineraryBloc>().add(const SaveOfflineEvent());
    } else {
      _showNotReadyMessage();
    }
  }

  void _showNotReadyMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Please wait for the itinerary to be created first!',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFFFF6B35),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

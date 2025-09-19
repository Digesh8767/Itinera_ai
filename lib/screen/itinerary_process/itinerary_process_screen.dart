import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinera_ai/core/app_image.dart';
import 'package:itinera_ai/core/screen_utils.dart';
import 'package:itinera_ai/screen/follow_up_refinement/follow_up_refinement_screen.dart';
import 'package:itinera_ai/screen/itinerary_process/bloc/itinerary_process_bloc.dart';
import 'package:itinera_ai/screen/home/home_screen.dart';
import 'package:itinera_ai/screen/profile/profile_screen.dart';
import 'package:itinera_ai/services/firebase_auth_service.dart';

class ItineraryProcessScreen extends StatefulWidget {
  static const String path = '/itinerary-process';
  final String tripDescription;

  const ItineraryProcessScreen({
    super.key,
    required this.tripDescription,
  });

  @override
  State<ItineraryProcessScreen> createState() => _ItineraryProcessScreenState();
}

class _ItineraryProcessScreenState extends State<ItineraryProcessScreen> {
  @override
  void initState() {
    super.initState();
    // Reset the BLoC state first to ensure fresh start
    context
        .read<ItineraryProcessBloc>()
        .add(const ResetItineraryProcessEvent());
    // Then start creating the new itinerary
    context.read<ItineraryProcessBloc>().add(
          StartCreatingItineraryEvent(tripDescription: widget.tripDescription),
        );
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
      backgroundColor: Color(0xFFFFFAF7),
      body: BlocConsumer<ItineraryProcessBloc, ItineraryProcessState>(
        listener: (context, state) {
          if (state is FollowUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is SaveOfflineSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is SaveOfflineDuringCreationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          } else if (state is FollowUpDuringCreationMessage) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          } else if (state is ItineraryProcessError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ItineraryCreating) {
            return _buildCreatingContent(context, state);
          } else if (state is ItineraryCreated) {
            return _buildCreatedContent(context, state.itinerary);
          } else if (state is ItineraryProcessError) {
            return _buildErrorContent(context, state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCreatingContent(BuildContext context, ItineraryCreating state) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => context.push(HomeScreen.path),
                      ),
                    ),
                    Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: GestureDetector(
                    onTap: () => context.push(ProfileScreen.path),
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
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Main Title
            Text(
              'Creating Itinerary...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                fontFamily: GoogleFonts.inter().fontFamily,
                color: const Color(0xFF000000),
              ),
            ),
            SizedBox(height: ScreenUtils.height * 0.024),

            // Progress Card
            Container(
              height: ScreenUtils.height * 0.600,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.symmetric(horizontal: 27),
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Progress indicator
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      value: state.progress / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF3BAB8C)),
                    ),
                  ),
                  SizedBox(height: ScreenUtils.height * 0.027),

                  Text(
                    'Curating a perfect plan for you...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: GoogleFonts.inter().fontFamily,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: ScreenUtils.height * 0.022),
                ],
              ),
            ),

            SizedBox(height: ScreenUtils.height * 0.022),

            // Follow up to refine button
            SizedBox(
              width: ScreenUtils.width * 0.850,
              height: ScreenUtils.height * 0.065,
              child: ElevatedButton(
                onPressed: () => context.read<ItineraryProcessBloc>().add(
                      const FollowUpDuringCreationEvent(),
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF065F46).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppImage.message),
                    const SizedBox(width: 8),
                    Text(
                      'Follow up to refine',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: GoogleFonts.inter().fontFamily,
                        color: const Color(0xFFFFFAF7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: ScreenUtils.height * 0.022),

            // Save Offline option
            GestureDetector(
              onTap: () => context.read<ItineraryProcessBloc>().add(
                    const SaveOfflineDuringCreationEvent(),
                  ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppImage.saveLight),
                  const SizedBox(width: 8),
                  Text(
                    'Save Offline',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: GoogleFonts.inter().fontFamily,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatedContent(
      BuildContext context, Map<String, dynamic> itinerary) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => context.push(HomeScreen.path),
                      ),
                    ),
                    Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: GestureDetector(
                    onTap: () => context.push(ProfileScreen.path),
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
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: ScreenUtils.height * 0.030),
            // Title with emoji
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Itinerary Created ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const Text('🏝️', style: TextStyle(fontSize: 24)),
              ],
            ),
            SizedBox(height: ScreenUtils.height * 0.030),

            // Trip Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.symmetric(horizontal: 27),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day 1 Header in your exact format
                  Text(
                    '${itinerary['title'] ?? 'Arrival and Exploration'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // Activities - Handle both formats
                  if (itinerary['activities'] != null)
                    ...itinerary['activities'].map<Widget>((activity) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${activity['time']}: ${activity['description']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()
                  else if (itinerary['days'] != null &&
                      itinerary['days'].isNotEmpty)
                    // Show only first day from complex format
                    ...itinerary['days'][0]['items'].map<Widget>((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${item['time']}: ${item['activity']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  const SizedBox(height: 20),

                  // Open in Maps
                  Container(
                    color: Color(0xFFF5F5F7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                    ),
                    child: GestureDetector(
                      onTap: () => context.read<ItineraryProcessBloc>().add(
                            const OpenInMapsEvent(),
                          ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              '📍',
                              style: TextStyle(
                                color: Color(0xFF3D90F5),
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              ' Open in maps ',
                              style: TextStyle(
                                color: Color(0xFF3D90F5),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.open_in_new,
                              color: Color(0xFF3D90F5),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Follow up button - Dynamic color based on state
            Container(
              width: double.infinity,
              height: 56,
              margin: EdgeInsets.symmetric(horizontal: 27),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: BlocBuilder<ItineraryProcessBloc, ItineraryProcessState>(
                builder: (context, state) {
                  final isLoading = state is FollowUpLoading;
                  final isCreated = state is ItineraryCreated;

                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (state is ItineraryCreated) {
                              final itinerary = state.itinerary;
                              final originalPrompt = widget.tripDescription;

                              context.push(
                                  '${FollowUpRefinementScreen.path}?prompt=${Uri.encodeComponent(originalPrompt)}&itinerary=${Uri.encodeComponent(json.encode(itinerary))}');
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCreated
                          ? const Color(0xFF065F46)
                          : Color(0xFF065F46).withOpacity(0.4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(AppImage.message),
                              const SizedBox(width: 8),
                              Text(
                                'Follow up to refine',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isCreated
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Save offline button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: BlocBuilder<ItineraryProcessBloc, ItineraryProcessState>(
                builder: (context, state) {
                  final isLoading = state is SaveOfflineLoading;
                  final isCreated = state is ItineraryCreated;

                  return isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF3BAB8C)),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(isCreated
                                ? AppImage.saveDark
                                : AppImage.saveDark),
                            const SizedBox(width: 8),
                            Text(
                              'Save Offline',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isCreated
                                    ? const Color(0xFF3BAB8C)
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error creating itinerary',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<ItineraryProcessBloc>().add(
                  StartCreatingItineraryEvent(
                      tripDescription: widget.tripDescription),
                ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

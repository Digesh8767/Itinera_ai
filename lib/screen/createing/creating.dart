import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinera_ai/core/app_image.dart';
import 'package:itinera_ai/core/screen_utils.dart';
import 'package:itinera_ai/screen/createing/bloc/creating_bloc.dart';
import 'package:itinera_ai/screen/home/home_screen.dart';
import 'package:itinera_ai/screen/profile/profile_screen.dart';
import 'package:itinera_ai/services/firebase_auth_service.dart';

class CreatingScreen extends StatefulWidget {
  final String tripDescription;

  const CreatingScreen({
    super.key,
    required this.tripDescription,
  });

  static const String path = '/creating-screen';

  @override
  State<CreatingScreen> createState() => _CreatingScreenState();
}

class _CreatingScreenState extends State<CreatingScreen> {
  @override
  void initState() {
    super.initState();
    // Start creating itinerary when screen loads
    context.read<CreatingBloc>().add(
          StartCreatingEvent(tripDescription: widget.tripDescription),
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

  void _handleFollowUp() {
    context.read<CreatingBloc>().add(const FollowUpEvent());
  }

  void _handleSaveOffline() {
    context.read<CreatingBloc>().add(const SaveOfflineEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF7),
      body: BlocConsumer<CreatingBloc, CreatingState>(
        listener: (context, state) {
          if (state is CreatingCompleted) {
            // Navigate to results screen or show success
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Itinerary created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate back to home
            context.push(HomeScreen.path);
          } else if (state is CreatingFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is FollowUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.blue,
              ),
            );
          } else if (state is SaveOfflineSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
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
                              onPressed: () => context.push(HomeScreen.path),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Color(0xFF0A0A0A),
                              ),
                            ),
                          ),
                          Text(
                            'Home',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontFamily: GoogleFonts.inter().fontFamily,
                              color: const Color(0xFF0A0A0A),
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
                  SizedBox(height: ScreenUtils.height * 0.024),

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

                  // Loading Card
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
                        // Loading Indicator
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF065F46),
                            ),
                            backgroundColor: const Color(0xFFF5F5F7),
                          ),
                        ),
                        SizedBox(height: ScreenUtils.height * 0.027),

                        // Loading Message
                        Text(
                          state is CreatingInProgress
                              ? state.message
                              : 'Curating a perfect plan for you...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.inter().fontFamily,
                            color: const Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ScreenUtils.height * 0.022),

                  // Follow up to refine button
                  SizedBox(
                    width: ScreenUtils.width * 0.850,
                    height: ScreenUtils.height * 0.065,
                    child: ElevatedButton(
                      onPressed:
                          state is CreatingInProgress ? null : _handleFollowUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF065F46).withOpacity(0.4),
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
                    onTap:
                        state is CreatingInProgress ? null : _handleSaveOffline,
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
        },
      ),
    );
  }
}

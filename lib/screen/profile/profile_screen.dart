import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinera_ai/core/screen_utils.dart';
import 'package:itinera_ai/screen/profile/bloc/profile_bloc.dart';
import 'package:itinera_ai/screen/login/login_screen.dart';
import 'package:itinera_ai/services/firebase_auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String path = '/profile-screen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile data when screen initializes
    context.read<ProfileBloc>().add(const LoadProfileEvent());
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

  void _handleLogout() {
    context.read<ProfileBloc>().add(const LogoutEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFAF7),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFAF7),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF0A0A0A),
            ),
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: GoogleFonts.inter().fontFamily,
            color: const Color(0xFF0A0A0A),
          ),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfileUpdateFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is LogoutSuccess) {
            context.go(LoginScreen.path);
          } else if (state is LogoutFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF065F46),
              ),
            );
          }

          if (state is ProfileLoaded) {
            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 27.0, vertical: 22),
              child: Column(
                children: [
                  // Profile Card
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 21, vertical: 30),
                      child: Column(
                        children: [
                          // User Avatar and Info
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF065F46),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    _getUserInitial(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.displayName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        fontFamily:
                                            GoogleFonts.inter().fontFamily,
                                        color: const Color(0xFF000000),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      state.email,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            GoogleFonts.inter().fontFamily,
                                        color: const Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ScreenUtils.height * 0.019),
                          Divider(
                            color: Color(0xFFEBDDD0),
                            height: 1,
                          ),

                          SizedBox(height: ScreenUtils.height * 0.019),

                          // Request Tokens
                          _buildTokenRow(
                            'Request Tokens',
                            '${state.requestTokens}/${state.maxRequestTokens}',
                            state.requestTokens / state.maxRequestTokens,
                            const Color(0xFF35AF8D),
                          ),
                          const SizedBox(height: 16),

                          // Response Tokens
                          _buildTokenRow(
                            'Response Tokens',
                            '${state.responseTokens}/${state.maxResponseTokens}',
                            state.responseTokens / state.maxResponseTokens,
                            const Color(0xFFF47676),
                          ),
                          const SizedBox(height: 16),

                          // Total Cost
                          Card(
                            elevation: 0,
                            color: Color(0xFFF6F3F0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 18),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Cost',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          GoogleFonts.inter().fontFamily,
                                      color: const Color(0xFF09090B),
                                    ),
                                  ),
                                  Text(
                                    '\$${state.totalCost.toStringAsFixed(2)} USD',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily:
                                          GoogleFonts.inter().fontFamily,
                                      color: const Color(0xFF009419),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtils.height * 0.043),

                  // Log Out Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFFFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(36),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout,
                            color: Color(0xFFE74C3C),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: GoogleFonts.inter().fontFamily,
                              color: const Color(0xFFE03C3C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Something went wrong'),
          );
        },
      ),
    );
  }

  Widget _buildTokenRow(
      String label, String value, double progress, Color color) {
    return Card(
      elevation: 0,
      color: Color(0xFFF6F3F0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: GoogleFonts.inter().fontFamily,
                    color: const Color(0xFF09090B),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: GoogleFonts.inter().fontFamily,
                    color: const Color(0xFF09090B),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtils.height * 0.012),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(21),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinera_ai/core/app_image.dart';
import 'package:itinera_ai/core/screen_utils.dart';
import 'package:itinera_ai/screen/follow_up_refinement/bloc/follow_up_refinement_bloc.dart';
import 'package:itinera_ai/screen/home/home_screen.dart';
import 'package:itinera_ai/services/firebase_auth_service.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

class FollowUpRefinementScreen extends StatefulWidget {
  static const String path = '/follow-up-refinement';
  final String originalPrompt;
  final Map<String, dynamic> currentItinerary;

  const FollowUpRefinementScreen({
    super.key,
    required this.originalPrompt,
    required this.currentItinerary,
  });

  @override
  State<FollowUpRefinementScreen> createState() =>
      _FollowUpRefinementScreenState();
}

class _FollowUpRefinementScreenState extends State<FollowUpRefinementScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    // Add initial AI message with the itinerary
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FollowUpRefinementBloc>().add(
            LoadInitialDataEvent(
              originalPrompt: widget.originalPrompt,
              currentItinerary: widget.currentItinerary,
            ),
          );
    });
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speechToText.initialize();
    setState(() {
      _isInitialized = available;
    });
  }

  void _startListening() async {
    if (!_isInitialized) return;

    setState(() {
      _isListening = true;
    });

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _messageController.text = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
    );
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      // Trigger loading state immediately
      context.read<FollowUpRefinementBloc>().add(
            SendFollowUpEvent(followUpMessage: _messageController.text.trim()),
          );
      _messageController.clear();

      // Scroll to bottom to show the thinking message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _regenerateResponse() {
    context
        .read<FollowUpRefinementBloc>()
        .add(const RegenerateItineraryEvent());
  }

  void _openInMaps(String destination) {
    final encodedDestination = Uri.encodeComponent(destination);
    final url = 'https://www.google.com/maps/search/$encodedDestination';
    launchUrl(Uri.parse(url));
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
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _speechToText.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF7),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),
            // Chat Messages
            Expanded(
              child:
                  BlocConsumer<FollowUpRefinementBloc, FollowUpRefinementState>(
                listener: (context, state) {
                  if (state is FollowUpRefinementError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is FollowUpRefinementLoaded) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Itinerary updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return _buildChatMessages(state);
                },
              ),
            ),
            // Input Field
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go(HomeScreen.path),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          Expanded(
            child: Text(
              '7 days in Bali...',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
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

  Widget _buildChatMessages(FollowUpRefinementState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _getMessageCount(state),
      itemBuilder: (context, index) {
        return _buildMessageBubble(index, state);
      },
    );
  }

  int _getMessageCount(FollowUpRefinementState state) {
    // Always show 3 messages: AI travel info, User scuba message, AI thinking/response
    return 3;
  }

  Widget _buildMessageBubble(int index, FollowUpRefinementState state) {
    // Show the conversation in the exact order from the image
    if (index == 0) {
      // First: AI response with travel info card
      return _buildAITravelInfoCard();
    }

    if (index == 1) {
      // Second: User message about scuba diving
      return _buildUserScubaMessage();
    }

    if (index == 2) {
      // Third: AI thinking state (if loading) or error state
      if (state is FollowUpRefinementLoading) {
        return _buildThinkingMessage();
      }
      // If error, show error message
      if (state is FollowUpRefinementError) {
        return _buildErrorMessage(state.message);
      }
      // If loaded, show the AI response
      if (state is FollowUpRefinementLoaded &&
          state.conversationHistory.isNotEmpty) {
        final lastMessage = state.conversationHistory.last;
        if (lastMessage['type'] == 'ai') {
          return _buildAIMessage(
            lastMessage['message'],
            lastMessage['itinerary'],
            isInitial: false,
          );
        }
      }
      return _buildThinkingMessage();
    }

    return const SizedBox.shrink();
  }

  Widget _buildAITravelInfoCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFFF59E0B),
                              child: Image.asset(AppImage.message,
                                  height: 10, width: 10))),
                      SizedBox(width: ScreenUtils.width * 0.012),
                      Text(
                        'Itinera AI',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Here\'s your personalized itinerary based on your request:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildItineraryCard(widget.currentItinerary),
                  const SizedBox(height: 12),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserScubaMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFF065F46),
                        child: Text(
                          _getUserInitial(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenUtils.width * 0.012),
                      Text(
                        'You',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0A0A0A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Can you also include skuba-diving in the Itinerary i wanna try it!',
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _copyMessage(
                            'Can you also include skuba-diving in the Itinerary i wanna try it!'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(AppImage.copy, height: 12, width: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Copy',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Color(0xFF776F69),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMessage(String message, Map<String, dynamic>? itinerary,
      {required bool isInitial}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(AppImage.message)),
                SizedBox(width: ScreenUtils.width * 0.012),
                Text(
                  'Itinera AI',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF000000),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtils.height * 0.008),
            Text(
              message,
              style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500),
            ),
            if (itinerary != null) ...[
              SizedBox(height: ScreenUtils.height * 0.016),
              _buildItineraryCard(itinerary),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItineraryCard(Map<String, dynamic> itinerary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Day 1: Arrival in Bali & Settle in Ubud',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildActivityItem('Morning', 'Arrive in Bali, Denpasar Airport.'),
          _buildActivityItem(
              'Transfer', 'Private driver to Ubud (around 1.5 hours).'),
          _buildActivityItem('Accommodation',
              'Check-in at a peaceful boutique hotel or villa in Ubud (e.g., Ubud Aura Retreat or Komaneka at Bisma).'),
          _buildActivityItem('Afternoon',
              'Explore Ubud\'s local area, walk around the tranquil rice terraces at Tegallalang.'),
          _buildActivityItem('Evening',
              'Dinner at Locavore (known for farm-to-table dishes in a peaceful setting).'),
          const SizedBox(height: 12),
          _buildTravelInfoCard(),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String time, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              '$time: $description',
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
  }

  Widget _buildTravelInfoCard() {
    return GestureDetector(
      onTap: () => _openInMaps('Bali, Indonesia'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: Colors.red, size: 16),
                SizedBox(width: 8),
                Text(
                  'Open in maps',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.open_in_new, color: Colors.blue, size: 12),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Mumbai to Bali, Indonesia',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '11hrs 5mins',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionButton(
          asset: 'assets/images/copy.png',
          label: 'Copy',
          onTap: () => _copyMessage('Itinerary copied'),
        ),
        SizedBox(width: ScreenUtils.width * 0.024),
        _buildActionButton(
          asset: 'assets/images/send.png',
          label: 'Save Offline',
          onTap: () => _saveOffline(),
        ),
        SizedBox(width: ScreenUtils.width * 0.024),
        _buildActionButton(
          asset: 'assets/images/redo.png',
          label: 'Regenerate',
          onTap: _regenerateResponse,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String asset,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(asset),
          SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Color(0xFF776F69),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _saveOffline() {
    // Implement save offline functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Itinerary saved offline')),
    );
  }

  Widget _buildThinkingMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: const Color(0xFFF59E0B),
                        child: Image.asset(AppImage.message,
                            height: 10, width: 10),
                      ),
                      SizedBox(width: ScreenUtils.width * 0.012),
                      Text(
                        'Itinera AI',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Color(0xFF3BAB8C), width: 3)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Thinking...',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: const Color(0xFFF59E0B),
                        child: Image.asset(AppImage.message,
                            height: 10, width: 10),
                      ),
                      SizedBox(width: ScreenUtils.width * 0.012),
                      Text(
                        'Itinera AI',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF6B35),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Oops! The LLM failed to generate answer. Please regenerate.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.red,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _regenerateResponse,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Regenerate',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E5E5)),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Follow up to refine',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: _isListening ? _stopListening : _startListening,
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color:
                          _isListening ? Colors.red : const Color(0xFF3BAB8C),
                      size: 20,
                    ),
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF3BAB8C),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

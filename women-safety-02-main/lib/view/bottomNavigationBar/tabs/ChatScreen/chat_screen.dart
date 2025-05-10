import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:women_safety/utils/custom_color.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

/// Fetches the Gemini response from Google's API for a given prompt.
Future<String> fetchChatGPTResponse(String prompt) async {
  final apiKey = "AIzaSyBtJR-Rb1jvMkaz2cER5gyvGn8foSoNSKg";
  final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey');

  // Add women safety context to the prompt
  final enhancedPrompt =
      """You are Saheli, a women's safety assistant in an app designed specifically for women's protection and wellbeing.
Focus all your responses on women's safety, self-defense, mental health, and empowerment regardless of the question type.
If the question seems unrelated to safety, still provide information with a safety perspective.
Be empathetic, practical, and supportive.
Keep answers concise but helpful.

User question: $prompt""";

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": enhancedPrompt}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 1024,
        }
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['candidates'][0]['content']['parts'][0]['text'] ??
          "Sorry, I couldn't generate a response.";
    } else {
      throw Exception(
          'Failed to get response: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    throw Exception('Error connecting to Gemini API: $e');
  }
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;

  @override
  void initState() {
    super.initState();

    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _sendButtonAnimation = CurvedAnimation(
      parent: _sendButtonController,
      curve: Curves.easeIn,
    );

    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        _sendButtonController.reverse();
      } else if (!_sendButtonController.isCompleted) {
        _sendButtonController.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }

  /// Sends the user message to the API and updates the UI with the response.
  void sendMessage() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      messages.add({
        'role': 'user',
        'content': prompt,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _controller.clear();

    _scrollToBottom();

    try {
      final response = await fetchChatGPTResponse(prompt);
      setState(() {
        messages.add({
          'role': 'assistant',
          'content': response,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        messages.add({
          'role': 'assistant',
          'content': 'Sorry, I encountered an error. Please try again later.',
          'timestamp': DateTime.now(),
          'isError': true,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _scrollToBottom() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildChatArea(),
            ),
            if (_isLoading) _buildTypingIndicator(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CustomColor.buttonColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assistant_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Saheli',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3E5C),
            ),
          ),
          Spacer(),
          IconButton(
            onPressed: () {
              setState(() {
                messages.clear();
              });
            },
            tooltip: 'Clear chat',
            icon: Icon(
              Icons.refresh_rounded,
              color: Color(0xFF8F9BB3),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    if (messages.isEmpty) {
      return _buildEmptyChatState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final showTimestamp = index == 0 ||
            _shouldShowTimestamp(
                messages[index - 1]['timestamp'], message['timestamp']);

        return Column(
          children: [
            if (showTimestamp) _buildTimestampDivider(message['timestamp']),
            _buildMessageBubble(message),
          ],
        );
      },
    );
  }

  bool _shouldShowTimestamp(DateTime previous, DateTime current) {
    return current.difference(previous).inMinutes > 5;
  }

  Widget _buildTimestampDivider(DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        DateFormat('MMM d, h:mm a').format(timestamp),
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Color(0xFFA0A5BD),
        ),
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.question_answer_rounded,
            size: 80,
            color: CustomColor.buttonColor.withOpacity(0.2),
          ),
          SizedBox(height: 24),
          Text(
            "Ask Saheli Anything",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3E5C),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Your personal safety assistant is here to help",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Color(0xFF8F9BB3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    bool isUser = message['role'] == 'user';
    bool isError = message['isError'] == true;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          bottom: 10,
          left: isUser ? 40 : 0,
          right: isUser ? 0 : 40,
        ),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser
              ? CustomColor.buttonColor
              : (isError ? Color(0xFFFFF0F0) : Colors.white),
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isUser ? Radius.circular(4) : Radius.circular(18),
            bottomLeft: isUser ? Radius.circular(18) : Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message['content'],
          style: GoogleFonts.poppins(
            fontSize: 14,
            height: 1.4,
            color: isUser
                ? Colors.white
                : (isError ? Colors.red[800] : Color(0xFF2E3E5C)),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: 16, bottom: 8),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return _buildPulsingDot(index * 100);
          }),
        ),
      ),
    );
  }

  Widget _buildPulsingDot(int delay) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: 1500),
        curve: Curves.easeInOut,
        builder: (context, double value, child) {
          return Container(
            height: 6 + 3 * (sin(value * 3.14 * 2)).abs(),
            width: 6 + 3 * (sin(value * 3.14 * 2)).abs(),
            decoration: BoxDecoration(
              color: CustomColor.buttonColor.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF5F7FB),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Color(0xFFA0A5BD),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Color(0xFF2E3E5C),
                ),
                maxLines: 1,
              ),
            ),
          ),
          SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CustomColor.buttonColor,
                  CustomColor.buttonColor.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: CustomColor.buttonColor.withOpacity(0.25),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: Icon(Icons.arrow_upward_rounded),
              color: Colors.white,
              iconSize: 22,
              tooltip: 'Send',
              padding: EdgeInsets.all(10),
              constraints: BoxConstraints(minWidth: 0, minHeight: 0),
            ),
          ),
        ],
      ),
    );
  }
}

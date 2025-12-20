import 'package:flutter/material.dart';
import 'package:horus_cafee/features/auth/provider/auth_provider.dart';
import 'package:horus_cafee/features/orders/provider/orders_provider.dart';
import 'package:provider/provider.dart';

import '../logic/chat_state_machine.dart';

/// Model for individual chat messages
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final ChatStateMachine _stateMachine = ChatStateMachine();

  List<String> _options = [];
  bool _isProcessing = false;

  // Getters
  List<ChatMessage> get messages => _messages;
  List<String> get options => _options;
  bool get isProcessing => _isProcessing;

  /// Initializes the chat session. Called when the screen loads.
  void initChat(String name) {
    if (_messages.isNotEmpty) return; // Prevent duplicate welcome messages

    _stateMachine.reset();
    _messages.add(
      ChatMessage(
        text:
            "Hello $name! 👋 Welcome to Horus Cafe. What can I get you today?",
        isUser: false,
        time: DateTime.now(),
      ),
    );

    _options = _stateMachine.getCurrentOptions();
    notifyListeners();
  }

  /// Handles user selection from the chip/button options.
  Future<void> handleSelection(String choice, BuildContext context) async {
    // 1. Add User's message to the list
    _messages.add(
      ChatMessage(text: choice, isUser: true, time: DateTime.now()),
    );

    // 2. Lock UI and clear options while processing
    _options = [];
    _isProcessing = true;
    notifyListeners();

    // Small delay for natural feel
    await Future.delayed(const Duration(milliseconds: 600));

    // 3. Logic: Check if user is confirming the final order
    if (_stateMachine.currentState == ChatState.confirming &&
        choice.contains('Confirm')) {
      await _processOrderSubmission(context);
    }
    // Logic: Check if user cancelled
    else if (_stateMachine.currentState == ChatState.confirming &&
        choice.contains('Cancel')) {
      _stateMachine.reset();
      _messages.add(
        ChatMessage(
          text: "Order cancelled. No problem! What else would you like?",
          isUser: false,
          time: DateTime.now(),
        ),
      );
    }
    // Logic: Standard conversation flow
    else {
      final reply = _stateMachine.nextState(choice);
      _messages.add(
        ChatMessage(text: reply, isUser: false, time: DateTime.now()),
      );
    }

    // 4. Update available options and unlock UI
    _options = _stateMachine.getCurrentOptions();
    _isProcessing = false;
    notifyListeners();
  }

  /// Private helper to communicate with the Flask Backend
  Future<void> _processOrderSubmission(BuildContext context) async {
    try {
      // Access Auth and Orders providers
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final orders = Provider.of<OrdersProvider>(context, listen: false);

      // Generate the JSON payload using State Machine data
      final orderData = _stateMachine.toJson(
        auth.user?.name ?? "Staff Member",
        auth.user?.employeeCode ?? "0000",
      );

      // Send to Flask API via OrdersProvider
      final bool success = await orders.placeOrderFromChat(orderData);

      if (success) {
        _messages.add(
          ChatMessage(
            text: "Order placed successfully! 🚀 The office boy is on his way.",
            isUser: false,
            time: DateTime.now(),
          ),
        );
        _stateMachine.reset(); // Clear state machine for next order
      } else {
        _messages.add(
          ChatMessage(
            text:
                "⚠️ Backend Error: I couldn't reach the Flask server. Please check your network.",
            isUser: false,
            time: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      _messages.add(
        ChatMessage(
          text: "An error occurred while sending the order: $e",
          isUser: false,
          time: DateTime.now(),
        ),
      );
    }
  }

  /// Resets the chat history and the logic state
  void resetChat() {
    _messages.clear();
    _stateMachine.reset();
    initChat("User");
    notifyListeners();
  }
}

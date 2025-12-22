import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../provider/chat_provider.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;

    // Define the Dark Theme Colors manually for maximum stability
    const Color userBubbleColor = Color(0xFFBB86FC); // Electric Purple
    const Color assistantBubbleColor = Color(0xFF2C2C2C); // Dark Charcoal
    const Color userTextColor = Colors.black;
    const Color assistantTextColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser)
                _buildAvatar(Icons.smart_toy_outlined, const Color(0xFF03DAC6)),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? userBubbleColor : assistantBubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? userTextColor : assistantTextColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isUser) _buildAvatar(Icons.person, const Color(0xFFCF6679)),
            ],
          ),

          // Timestamp
          Padding(
            padding: EdgeInsets.only(
              left: isUser ? 0 : 48,
              right: isUser ? 48 : 0,
              top: 5,
            ),
            child: Text(
              DateFormat('hh:mm a').format(message.time),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(IconData icon, Color accentColor) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: accentColor.withOpacity(0.2),
      child: Icon(icon, size: 18, color: accentColor),
    );
  }
}

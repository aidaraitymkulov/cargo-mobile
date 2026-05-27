import 'package:flutter/material.dart';
import 'package:cargo_mobile/shared/widgets/app_header.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const AppHeader(label: 'Чат', title: 'Сообщения'),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text('Чат', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white38)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

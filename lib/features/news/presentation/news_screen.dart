import 'package:flutter/material.dart';
import 'package:cargo_mobile/shared/widgets/app_header.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const AppHeader(label: 'Инструкции', title: 'Что нового?'),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text('Инструкции', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white38)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

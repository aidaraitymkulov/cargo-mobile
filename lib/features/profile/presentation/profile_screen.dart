import 'package:flutter/material.dart';
import 'package:cargo_mobile/shared/widgets/app_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const AppHeader(label: 'Аккаунт', title: 'Профиль'),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text('Аккаунт', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white38)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBackButton;

  const AuthScaffold({
    super.key,
    required this.child,
    this.title,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: (title != null || showBackButton)
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.white,
              title: title != null
                  ? Text(title!, style: const TextStyle(color: Colors.white))
                  : null,
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF43A047),
            ],
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

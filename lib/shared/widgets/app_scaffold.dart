import 'package:flutter/material.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBackButton;

  const AppScaffold({
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
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          bottom: false,
          child: child,
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;

  const AppCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

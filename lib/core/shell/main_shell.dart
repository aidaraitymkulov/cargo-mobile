import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cargo_mobile/shared/widgets/app_background.dart';
import 'package:cargo_mobile/shared/widgets/bottom_nav_bar.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: AppBackground(child: navigationShell),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        chatBadge: 3,
      ),
    );
  }
}

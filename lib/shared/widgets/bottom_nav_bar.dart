import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cargo_mobile/shared/widgets/chat_island_button.dart';
import 'package:cargo_mobile/shared/widgets/nav_bar_item.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.chatBadge = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int chatBadge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xE00E120F) : const Color(0xEBFFFFFF);
    final navBorder = isDark ? const Color(0x14FFFFFF) : const Color(0x1F1A6B3F);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.6)
        : const Color(0xFF0E3826).withValues(alpha: 0.18);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
      child: SizedBox(
        height: 94, // 64 bar + 30 elevation room for ChatIslandButton
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // glass bar background (bottom 64px only — doesn't clip the island)
            Positioned(
              left: 0, right: 0, bottom: 0, height: 64,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: navBg,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: navBorder),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                          spreadRadius: -16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // items row — center button pops up into the 30px free space above
            Positioned(
              left: 0, right: 0, bottom: 0, height: 64,
              child: Row(
                children: [
                  NavBarItem(index: 0, currentIndex: currentIndex, icon: Icons.home_outlined,       label: 'Главная',    onTap: onTap),
                  NavBarItem(index: 1, currentIndex: currentIndex, icon: Icons.phone_outlined,       label: 'Связь',      onTap: onTap),
                  ChatIslandButton(index: 2, currentIndex: currentIndex, badge: chatBadge,           onTap: onTap),
                  NavBarItem(index: 3, currentIndex: currentIndex, icon: Icons.description_outlined, label: 'Инструкции', onTap: onTap),
                  NavBarItem(index: 4, currentIndex: currentIndex, icon: Icons.person_outline,       label: 'Аккаунт',    onTap: onTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

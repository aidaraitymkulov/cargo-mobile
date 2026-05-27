import 'package:flutter/material.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';

class ChatIslandButton extends StatefulWidget {
  const ChatIslandButton({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.badge = 0,
  });

  final int index, currentIndex, badge;
  final ValueChanged<int> onTap;

  @override
  State<ChatIslandButton> createState() => _ChatIslandButtonState();
}

class _ChatIslandButtonState extends State<ChatIslandButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ringColor = isDark ? const Color(0xFF090E0B) : const Color(0xFFEFF4EF);

    return SizedBox(
      width: 70,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap(widget.index);
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: Transform.translate(
          offset: const Offset(0, -30),
          child: AnimatedScale(
            scale: _pressed ? 0.93 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                // glow halo
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [ac.glow.withValues(alpha: 0.4), Colors.transparent],
                    ),
                  ),
                ),
                // circle button
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: const Alignment(-0.6, -0.8),
                      end: Alignment.bottomRight,
                      colors: [cs.primary, ac.deep],
                    ),
                    border: Border.all(color: ringColor, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: ac.deep.withValues(alpha: 0.6),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                        spreadRadius: -6,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
                ),
                // badge
                if (widget.badge > 0)
                  Positioned(
                    top: 0,
                    right: 2,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: ringColor, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x80EF4444),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Text(
                        '${widget.badge}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

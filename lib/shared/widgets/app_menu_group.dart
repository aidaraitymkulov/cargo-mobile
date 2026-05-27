import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';

class AppMenuItem {
  const AppMenuItem({
    required this.icon,
    required this.color,
    required this.label,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final bool danger;
  final VoidCallback? onTap;
}

class AppMenuGroup extends StatelessWidget {
  const AppMenuGroup({super.key, required this.items});

  final List<AppMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++)
                _AppMenuRow(
                  item: items[i],
                  isLast: i == items.length - 1,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppMenuRow extends StatefulWidget {
  const _AppMenuRow({required this.item, required this.isLast});

  final AppMenuItem item;
  final bool isLast;

  @override
  State<_AppMenuRow> createState() => _AppMenuRowState();
}

class _AppMenuRowState extends State<_AppMenuRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).extension<AppColors>()!;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: item.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _pressed
            ? (isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04))
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.73),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.15,
                      color: item.danger
                          ? const Color(0xFFEF4444)
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: item.danger
                      ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                      : colors.hint,
                ),
              ],
            ),
            if (!widget.isLast)
              Container(
                margin: const EdgeInsets.only(top: 12, left: 50),
                height: 0.5,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.07),
              ),
          ],
        ),
      ),
    );
  }
}

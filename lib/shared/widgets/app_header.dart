import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';
import 'package:cargo_mobile/core/theme/theme_provider.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({
    super.key,
    required this.label,
    required this.title,
    this.bottom,
  });

  /// Small uppercase tag above the title, e.g. "Главная"
  final String label;

  /// Large bold heading, e.g. "Добро пожаловать"
  final String title;

  /// Optional widget below the title row (e.g. search bar)
  final Widget? bottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // label + title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '· ${label.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                          letterSpacing: 0.18 * 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.03 * 28,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // theme toggle button
                _ThemeToggleButton(isDark: isDark, ac: ac, ref: ref),
              ],
            ),
            if (bottom != null) ...[
              const SizedBox(height: 12),
              bottom!,
            ],
          ],
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({
    required this.isDark,
    required this.ac,
    required this.ref,
  });

  final bool isDark;
  final AppColors ac;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ref.read(themeModeProvider.notifier).toggle(),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ac.card,
          border: Border.all(color: ac.border),
        ),
        child: Icon(
          isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ac = Theme.of(context).extension<AppColors>()!;

    return Stack(
      children: [
        // base gradient
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: const GradientRotation(170 * 3.14159 / 180),
                colors: ac.bgGradient,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // blob top-right
        Positioned(
          top: -180, right: -180,
          child: _Blob(size: 520, colors: ac.blob1),
        ),
        // blob bottom-left
        Positioned(
          bottom: -100, left: -100,
          child: _Blob(size: 400, colors: ac.blob2),
        ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

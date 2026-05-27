import 'package:flutter/material.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';

class AppPrimaryButton extends StatefulWidget {
  const AppPrimaryButton({
    super.key,
    required this.child,
    this.onTap,
    this.loading = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool loading;

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ac = Theme.of(context).extension<AppColors>()!;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          opacity: widget.onTap == null ? 0.65 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [ac.btnTop, ac.btnBot],
              ),
              boxShadow: [
                BoxShadow(
                  color: ac.deep.withValues(alpha: 0.53),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: const Alignment(0.5, 1),
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Center(
                  child: widget.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : widget.child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppSecondaryButton extends StatefulWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  State<AppSecondaryButton> createState() => _AppSecondaryButtonState();
}

class _AppSecondaryButtonState extends State<AppSecondaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ac = Theme.of(context).extension<AppColors>()!;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: ac.btnSec,
            border: Border.all(color: ac.btnSecBorder),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

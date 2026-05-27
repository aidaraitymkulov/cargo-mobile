import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';

class LogoutSheet extends StatelessWidget {
  const LogoutSheet({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  static Future<void> show(BuildContext context, {required VoidCallback onConfirm}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => LogoutSheet(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0E1A12).withValues(alpha: 0.92)
                : Colors.white.withValues(alpha: 0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: colors.border),
              left: BorderSide(color: colors.border),
              right: BorderSide(color: colors.border),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            24, 16, 24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Выйти из аккаунта?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Вы будете перенаправлены на экран входа.\nДанные приложения останутся сохранены.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.sub,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _SheetButton(
                      label: 'Отмена',
                      onTap: () => Navigator.of(context).pop(),
                      isDanger: false,
                      colors: colors,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SheetButton(
                      label: 'Выйти',
                      onTap: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                      isDanger: true,
                      colors: colors,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetButton extends StatefulWidget {
  const _SheetButton({
    required this.label,
    required this.onTap,
    required this.isDanger,
    required this.colors,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDanger;
  final AppColors colors;

  @override
  State<_SheetButton> createState() => _SheetButtonState();
}

class _SheetButtonState extends State<_SheetButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDanger
        ? const Color(0xFFEF4444)
        : widget.colors.btnSec;
    final border = widget.isDanger
        ? Colors.transparent
        : widget.colors.btnSecBorder;
    final fg = widget.isDanger
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}

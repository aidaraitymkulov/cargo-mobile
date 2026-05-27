import 'package:flutter/material.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.suffix,
    this.errorText,
  });

  final String label, hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final Widget? suffix;
  final String? errorText;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final ac       = Theme.of(context).extension<AppColors>()!;
    final cs       = Theme.of(context).colorScheme;
    final hasError = widget.errorText != null;

    // Приоритет цвета границы: ошибка > фокус > обычный
    final borderColor = hasError
        ? const Color(0xFFEF4444)
        : _focused
            ? cs.primary
            : ac.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ac.sub),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 52,
          decoration: BoxDecoration(
            color: ac.inputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              if (_focused && !hasError)
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.13),
                  blurRadius: 0,
                  spreadRadius: 4,
                ),
              if (hasError)
                BoxShadow(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  blurRadius: 0,
                  spreadRadius: 4,
                ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(
                widget.icon,
                size: 18,
                color: hasError
                    ? const Color(0xFFEF4444)
                    : _focused
                        ? cs.primary
                        : ac.hint,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Focus(
                  onFocusChange: (v) => setState(() => _focused = v),
                  child: TextField(
                    controller: widget.controller,
                    obscureText: widget.obscure,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: TextStyle(color: ac.hint, fontSize: 15),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              if (widget.suffix != null) ...[widget.suffix!, const SizedBox(width: 14)],
            ],
          ),
        ),
        // Текст ошибки
        if (hasError) ...[
          const SizedBox(height: 5),
          Text(
            widget.errorText!,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFFEF4444),
            ),
          ),
        ],
      ],
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserHeroCard extends StatefulWidget {
  const UserHeroCard({
    super.key,
    required this.name,
    required this.code,
    required this.branch,
  });

  final String name;
  final String code;
  final String branch;

  @override
  State<UserHeroCard> createState() => _UserHeroCardState();
}

class _UserHeroCardState extends State<UserHeroCard> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF0E3826), Color(0xFF134B33), Color(0xFF0A2A1B)]
              : const [Color(0xFF1A6B3F), Color(0xFF268A53), Color(0xFF0E3826)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E3826).withValues(alpha: isDark ? 0.7 : 0.5),
            blurRadius: 50,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Привет,',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.name} 👋',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.6,
              height: 1,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '· ЛИЧНЫЙ КОД',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.8,
              color: Color(0xFF7DD968),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _copy,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 10, 16, 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.code,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 1,
                        height: 18,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        _copied ? Icons.check_rounded : Icons.copy_rounded,
                        size: 18,
                        color: _copied
                            ? const Color(0xFF7DD968)
                            : Colors.white.withValues(alpha: 0.75),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF7DD968),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Color(0xFF7DD968), blurRadius: 8)],
                ),
              ),
              const SizedBox(width: 7),
              Text(
                widget.branch,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

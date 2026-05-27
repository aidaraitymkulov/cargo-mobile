import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';
import 'package:cargo_mobile/core/theme/theme_provider.dart';
import 'package:cargo_mobile/features/auth/presentation/welcome_screen.dart';
import 'package:cargo_mobile/features/auth/presentation/login_form_screen.dart';
import 'package:cargo_mobile/features/auth/presentation/register_screen.dart';
import 'package:cargo_mobile/features/auth/presentation/confirm_email_screen.dart';

enum _Screen { welcome, login, register, confirmEmail }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  _Screen _screen = _Screen.welcome;
  String  _pendingLogin = '';

  late final AnimationController _b1 =
      AnimationController(vsync: this, duration: const Duration(seconds: 12))
        ..repeat(reverse: true);
  late final AnimationController _b2 =
      AnimationController(vsync: this, duration: const Duration(seconds: 15))
        ..repeat(reverse: true);
  late final AnimationController _b3 =
      AnimationController(vsync: this, duration: const Duration(seconds: 10))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _b1.dispose();
    _b2.dispose();
    _b3.dispose();
    super.dispose();
  }

  void _toggleTheme() => ref.read(themeModeProvider.notifier).toggle();

  Widget _buildScreen() {
    switch (_screen) {
      case _Screen.welcome:
        return WelcomeScreen(
          key: const ValueKey('welcome'),
          onLogin: () => setState(() => _screen = _Screen.login),
          onRegister: () => setState(() => _screen = _Screen.register),
          onToggleTheme: _toggleTheme,
        );
      case _Screen.login:
        return LoginFormScreen(
          key: const ValueKey('login'),
          onBack: () => setState(() => _screen = _Screen.welcome),
          onToggleTheme: _toggleTheme,
        );
      case _Screen.register:
        return RegisterFormScreen(
          key: const ValueKey('register'),
          onBack: () => setState(() => _screen = _Screen.welcome),
          onToggleTheme: _toggleTheme,
          onSuccess: (login) {
            _pendingLogin = login;
            setState(() => _screen = _Screen.confirmEmail);
          },
        );
      case _Screen.confirmEmail:
        return ConfirmEmailScreen(
          key: const ValueKey('confirmEmail'),
          login: _pendingLogin,
          onBack: () => setState(() => _screen = _Screen.register),
          onSuccess: () => setState(() => _screen = _Screen.login),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _AnimBg(b1: _b1, b2: _b2, b3: _b3),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: child,
              ),
            ),
            child: _buildScreen(),
          ),
        ],
      ),
    );
  }
}

// ─── Animated background (локальный для auth flow) ────────────
class _AnimBg extends StatelessWidget {
  const _AnimBg({required this.b1, required this.b2, required this.b3});
  final Animation<double> b1, b2, b3;

  @override
  Widget build(BuildContext context) {
    final ac     = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: ac.bgGradient,
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: b1,
          builder: (_, __) => Positioned(
            top: -80 + b1.value * 30,
            left: -60 + b1.value * 20,
            child: _Blob(380, ac.blob1),
          ),
        ),
        AnimatedBuilder(
          animation: b2,
          builder: (_, __) => Positioned(
            bottom: -60 + b2.value * 25,
            right: -40 + b2.value * 15,
            child: _Blob(320, ac.blob2),
          ),
        ),
        AnimatedBuilder(
          animation: b3,
          builder: (_, __) {
            final sz = MediaQuery.sizeOf(context);
            return Positioned(
              top: sz.height * 0.38 + b3.value * 20,
              right: -30 + b3.value * 10,
              child: _Blob(240, ac.blob3),
            );
          },
        ),
        CustomPaint(
          painter: _RoutesPainter(isDark: isDark, glow: ac.glow),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob(this.size, this.colors);
  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      );
}

class _RoutesPainter extends CustomPainter {
  const _RoutesPainter({required this.isDark, required this.glow});
  final bool isDark;
  final Color glow;

  void _dash(Canvas canvas, Path path, Color color, double d, double g) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color;
    for (final m in path.computeMetrics()) {
      double dist = 0;
      while (dist < m.length) {
        canvas.drawPath(m.extractPath(dist, math.min(dist + d, m.length)), p);
        dist += d + g;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size sz) {
    final op = isDark ? 0.5 : 0.25;

    final p1 = Path()
      ..moveTo(sz.width * -0.05, sz.height * 0.82)
      ..quadraticBezierTo(
          sz.width * 0.31, sz.height * 0.46,
          sz.width * 0.82, sz.height * 0.21);
    _dash(canvas, p1, glow.withValues(alpha: op), 4, 8);

    final p2 = Path()
      ..moveTo(sz.width * 1.05, sz.height * 0.86)
      ..quadraticBezierTo(
          sz.width * 0.67, sz.height * 0.60,
          sz.width * 0.15, sz.height * 0.31);
    _dash(canvas, p2, glow.withValues(alpha: op * 0.5), 2, 10);

    void pin(Offset c) {
      canvas.drawCircle(
          c, 14, Paint()..color = glow.withValues(alpha: isDark ? 0.12 : 0.10));
      canvas.drawCircle(
          c, 6, Paint()..color = glow.withValues(alpha: isDark ? 0.35 : 0.28));
      canvas.drawCircle(
          c, 3, Paint()..color = Colors.white.withValues(alpha: 0.9));
    }

    pin(Offset(sz.width * 0.82, sz.height * 0.21));
    pin(Offset(sz.width * 0.07, sz.height * 0.98));
  }

  @override
  bool shouldRepaint(_RoutesPainter old) => old.isDark != isDark;
}

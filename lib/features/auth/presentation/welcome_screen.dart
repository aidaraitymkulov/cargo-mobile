import 'package:flutter/material.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';
import 'package:cargo_mobile/shared/widgets/app_button.dart';
import 'package:cargo_mobile/shared/widgets/nav_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
    required this.onToggleTheme,
  });

  final VoidCallback onLogin, onRegister, onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final ac  = Theme.of(context).extension<AppColors>()!;
    final cs  = Theme.of(context).colorScheme;
    final top = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(28, top + 8, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: NavButton(
              onTap: onToggleTheme,
              child: Icon(
                isDark ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
                size: 18,
                color: cs.onSurface,
              ),
            ),
          ),
          const Spacer(),
          // Logo box
          Container(
            width: 128,
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [ac.deep, const Color(0xFF0A2A1B)],
              ),
              boxShadow: [
                BoxShadow(
                  color: ac.deep.withValues(alpha: 0.53),
                  blurRadius: 60,
                  offset: const Offset(0, 20),
                  spreadRadius: -12,
                ),
              ],
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: const Alignment(0, 0),
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Image.asset(
                    'assets/logo.png',
                    height: 34,
                    color: Colors.white,
                    errorBuilder: (_, __, ___) => const Text(
                      'ADES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ADES · EXPRESS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Доставка',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              height: 1.08,
              color: cs.onSurface,
            ),
          ),
          ShaderMask(
            shaderCallback: (b) =>
                LinearGradient(colors: [ac.glow, cs.primary]).createShader(b),
            blendMode: BlendMode.srcIn,
            child: const Text(
              'из Китая',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                height: 1.08,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Отслеживайте посылки, управляйте заказами\nи связывайтесь с менеджером',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.55, color: ac.sub),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary,
                  boxShadow: [
                    BoxShadow(
                      color: ac.glow.withValues(alpha: 0.7),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Guangzhou → Бишкек',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: ac.sub,
                ),
              ),
            ],
          ),
          const Spacer(),
          AppPrimaryButton(
            onTap: onLogin,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Войти в аккаунт',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppSecondaryButton(label: 'Зарегистрироваться', onTap: onRegister),
        ],
      ),
    );
  }
}

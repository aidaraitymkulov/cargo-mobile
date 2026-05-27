import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';
import 'package:cargo_mobile/shared/widgets/app_button.dart';
import 'package:cargo_mobile/shared/widgets/app_text_field.dart';
import 'package:cargo_mobile/shared/widgets/nav_button.dart';

class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({
    super.key,
    required this.onBack,
    required this.onToggleTheme,
  });

  final VoidCallback onBack, onToggleTheme;

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final _loginCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _showPass = false;
  bool _loading  = false;
  bool _success  = false;

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_loginCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() { _loading = false; _success = true; });
  }

  @override
  Widget build(BuildContext context) {
    final ac  = Theme.of(context).extension<AppColors>()!;
    final cs  = Theme.of(context).colorScheme;
    final top = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ── Скроллируемый контент ──────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(28, top + 8, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NavButton(
                      onTap: widget.onBack,
                      child: Icon(Icons.arrow_back, size: 20, color: cs.onSurface),
                    ),
                    NavButton(
                      onTap: widget.onToggleTheme,
                      child: Icon(
                        isDark ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
                        size: 18,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '· Вход',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'С возвращением!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    height: 1.1,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Введите логин и пароль для доступа к личному кабинету',
                  style: TextStyle(fontSize: 13.5, color: ac.sub, height: 1.5),
                ),
                const SizedBox(height: 26),
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ac.card,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: ac.border),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          AppTextField(
                            label: 'Логин или телефон',
                            icon: Icons.person_outline,
                            hint: 'ivan_petrov',
                            controller: _loginCtrl,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            label: 'Пароль',
                            icon: Icons.lock_outline,
                            hint: '••••••••',
                            controller: _passCtrl,
                            obscure: !_showPass,
                            suffix: GestureDetector(
                              onTap: () => setState(() => _showPass = !_showPass),
                              child: Icon(
                                _showPass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: ac.hint,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Забыли пароль?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_success) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.check, size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Вход выполнен успешно!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // ── Кнопка прибита к низу ──────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, MediaQuery.of(context).padding.bottom + 24),
          child: AppPrimaryButton(
            onTap: _loading ? null : _submit,
            loading: _loading,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Войти',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

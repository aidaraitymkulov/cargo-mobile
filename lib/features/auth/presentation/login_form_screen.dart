import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';
import 'package:cargo_mobile/features/auth/domain/auth_provider.dart';
import 'package:cargo_mobile/shared/widgets/app_button.dart';
import 'package:cargo_mobile/shared/widgets/app_text_field.dart';
import 'package:cargo_mobile/shared/widgets/nav_button.dart';

class LoginFormScreen extends ConsumerStatefulWidget {
  const LoginFormScreen({
    super.key,
    required this.onBack,
    required this.onToggleTheme,
  });

  final VoidCallback onBack, onToggleTheme;

  @override
  ConsumerState<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends ConsumerState<LoginFormScreen> {
  final _loginCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _showPass = false;
  bool _loading  = false;

  String? _loginError;
  String? _passError;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _loginCtrl.addListener(() {
      if (_loginError != null || _serverError != null) {
        setState(() { _loginError = null; _serverError = null; });
      }
    });
    _passCtrl.addListener(() {
      if (_passError != null || _serverError != null) {
        setState(() { _passError = null; _serverError = null; });
      }
    });
  }

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _loginError = _loginCtrl.text.trim().isEmpty ? 'Заполните поле' : null;
      _passError  = _passCtrl.text.isEmpty ? 'Заполните поле' : null;
    });
    return _loginError == null && _passError == null;
  }

  void _submit() async {
    if (!_validate()) return;
    setState(() { _loading = true; _serverError = null; });
    try {
      await ref.read(authProvider.notifier).login(
        _loginCtrl.text.trim(),
        _passCtrl.text,
      );
      // GoRouter сам редиректнет на '/' после смены authProvider
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String?;
      setState(() => _serverError = message ?? 'Ошибка входа. Попробуйте снова.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                            errorText: _loginError,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            label: 'Пароль',
                            icon: Icons.lock_outline,
                            hint: '••••••••',
                            controller: _passCtrl,
                            obscure: !_showPass,
                            errorText: _passError,
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
                if (_serverError != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _serverError!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEF4444),
                            ),
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

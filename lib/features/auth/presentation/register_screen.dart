import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';
import 'package:cargo_mobile/features/auth/domain/auth_provider.dart';
import 'package:cargo_mobile/models/branch.dart';
import 'package:cargo_mobile/shared/utils/date_formatter.dart';
import 'package:cargo_mobile/shared/utils/phone_formatter.dart';
import 'package:cargo_mobile/shared/widgets/app_button.dart';
import 'package:cargo_mobile/shared/widgets/app_text_field.dart';
import 'package:cargo_mobile/shared/widgets/error_banner.dart';
import 'package:cargo_mobile/shared/widgets/nav_button.dart';

class RegisterFormScreen extends ConsumerStatefulWidget {
  const RegisterFormScreen({
    super.key,
    required this.onBack,
    required this.onToggleTheme,
    required this.onSuccess,
  });

  final VoidCallback onBack, onToggleTheme;
  final void Function(String login) onSuccess;

  @override
  ConsumerState<RegisterFormScreen> createState() => _RegisterFormScreenState();
}

class _RegisterFormScreenState extends ConsumerState<RegisterFormScreen> {
  int _step = 0;

  // Step 0
  final _loginCtrl     = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _loginFocus     = FocusNode();
  final _firstNameFocus = FocusNode();
  final _lastNameFocus  = FocusNode();

  // Step 1
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dateCtrl  = TextEditingController();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _dateFocus  = FocusNode();

  // Step 2
  final _passwordCtrl  = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _showPass = false;
  Branch? _selectedBranch;
  bool _agree = false;

  bool _loading = false;

  String? _loginError, _firstNameError, _lastNameError;
  String? _emailError, _phoneError, _dateError;
  String? _passwordError, _branchError;
  String? _serverError;

  static const _stepTitles = ['Личные данные', 'Контакты', 'Пароль и филиал'];

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = '+996 ';
    _phoneCtrl.selection = TextSelection.collapsed(offset: _phoneCtrl.text.length);

    _loginCtrl.addListener(() {
      if (_loginError != null || _serverError != null) {
        setState(() { _loginError = null; _serverError = null; });
      }
    });
    _firstNameCtrl.addListener(() {
      if (_firstNameError != null) setState(() => _firstNameError = null);
    });
    _lastNameCtrl.addListener(() {
      if (_lastNameError != null) setState(() => _lastNameError = null);
    });
    _emailCtrl.addListener(() {
      if (_emailError != null || _serverError != null) {
        setState(() { _emailError = null; _serverError = null; });
      }
    });
    _phoneCtrl.addListener(() {
      if (_phoneError != null) setState(() => _phoneError = null);
    });
    _dateCtrl.addListener(() {
      if (_dateError != null) setState(() => _dateError = null);
    });
    _passwordCtrl.addListener(() {
      if (_passwordError != null || _serverError != null) {
        setState(() { _passwordError = null; _serverError = null; });
      }
    });
  }

  @override
  void dispose() {
    for (final c in [_loginCtrl, _firstNameCtrl, _lastNameCtrl,
                     _emailCtrl, _phoneCtrl, _dateCtrl, _passwordCtrl]) { c.dispose(); }
    for (final f in [_loginFocus, _firstNameFocus, _lastNameFocus,
                     _emailFocus, _phoneFocus, _dateFocus, _passwordFocus]) { f.dispose(); }
    super.dispose();
  }

  void _goBack() {
    if (_step > 0) {
      setState(() { _step--; _serverError = null; });
    } else {
      widget.onBack();
    }
  }

  bool _validateStep() {
    final emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    switch (_step) {
      case 0:
        final login = _loginCtrl.text.trim();
        setState(() {
          _loginError = login.isEmpty
              ? 'Заполните поле'
              : login.length < 3
                  ? 'Минимум 3 символа'
                  : null;
          _firstNameError = _firstNameCtrl.text.trim().isEmpty ? 'Заполните поле' : null;
          _lastNameError  = _lastNameCtrl.text.trim().isEmpty  ? 'Заполните поле' : null;
        });
        return _loginError == null && _firstNameError == null && _lastNameError == null;

      case 1:
        final email = _emailCtrl.text.trim();
        final phoneDigits = _phoneCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
        setState(() {
          _emailError = email.isEmpty
              ? 'Заполните поле'
              : !emailRe.hasMatch(email)
                  ? 'Некорректный email'
                  : null;
          _phoneError = phoneDigits.length < 12
              ? phoneDigits.length <= 3
                  ? 'Заполните поле'
                  : 'Введите корректный номер'
              : null;
          _dateError = DateInputFormatter.validate(_dateCtrl.text);
        });
        return _emailError == null && _phoneError == null && _dateError == null;

      case 2:
        final pass = _passwordCtrl.text;
        setState(() {
          _passwordError = pass.isEmpty
              ? 'Заполните поле'
              : pass.length < 6
                  ? 'Минимум 6 символов'
                  : null;
          _branchError = _selectedBranch == null ? 'Выберите филиал' : null;
        });
        return _passwordError == null && _branchError == null;

      default:
        return true;
    }
  }

  Future<void> _goNext() async {
    if (!_validateStep()) return;
    if (_step < 2) {
      setState(() { _step++; _serverError = null; });
      return;
    }
    setState(() { _loading = true; _serverError = null; });
    try {
      await ref.read(authRepositoryProvider).register(
        login:       _loginCtrl.text.trim(),
        firstName:   _firstNameCtrl.text.trim(),
        lastName:    _lastNameCtrl.text.trim(),
        email:       _emailCtrl.text.trim(),
        phone:       KgPhoneFormatter.toApiValue(_phoneCtrl.text),
        dateOfBirth: DateInputFormatter.toApiValue(_dateCtrl.text),
        password:    _passwordCtrl.text,
        branchId:    _selectedBranch!.id,
      );
      widget.onSuccess(_loginCtrl.text.trim());
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? data['message'] as String? : null;
      setState(() => _serverError = message ?? 'Ошибка регистрации. Попробуйте снова.');
    } catch (_) {
      setState(() => _serverError = 'Произошла непредвиденная ошибка. Попробуйте позже.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ac     = Theme.of(context).extension<AppColors>()!;
    final cs     = Theme.of(context).colorScheme;
    final top    = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final branchesAsync = ref.watch(branchesProvider);

    return Column(
      children: [
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
                      onTap: _goBack,
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
                const SizedBox(height: 18),
                Text(
                  '· Регистрация — шаг ${_step + 1} из 3',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Align(
                    key: ValueKey(_step),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _stepTitles[_step],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        height: 1.1,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Progress bar
                LayoutBuilder(builder: (_, constraints) {
                  return Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                    child: Stack(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        width: constraints.maxWidth * (_step + 1) / 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          gradient: LinearGradient(colors: [cs.primary, ac.glow]),
                        ),
                      ),
                    ]),
                  );
                }),
                const SizedBox(height: 18),
                // Card
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
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(_step),
                          child: _buildStepFields(branchesAsync),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_serverError != null) ...[
                  const SizedBox(height: 14),
                  AppErrorBanner(message: _serverError!),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, MediaQuery.of(context).padding.bottom + 24),
          child: AppPrimaryButton(
            onTap: (_loading || (_step == 2 && !_agree)) ? null : _goNext,
            loading: _loading,
            child: _step < 2
                ? Row(mainAxisSize: MainAxisSize.min, children: const [
                    Text('Далее', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                  ])
                : Row(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Создать аккаунт', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStepFields(AsyncValue<List<Branch>> branchesAsync) {
    final ac = Theme.of(context).extension<AppColors>()!;
    final cs = Theme.of(context).colorScheme;

    switch (_step) {
      case 0:
        return Column(children: [
          AppTextField(
            label: 'Логин',
            icon: Icons.alternate_email,
            hint: 'ivan_petrov',
            controller: _loginCtrl,
            errorText: _loginError,
            focusNode: _loginFocus,
            textInputAction: TextInputAction.next,
            onSubmitted: () => _firstNameFocus.requestFocus(),
          ),
          const SizedBox(height: 13),
          AppTextField(
            label: 'Имя',
            icon: Icons.person_outline,
            hint: 'Иван',
            controller: _firstNameCtrl,
            errorText: _firstNameError,
            focusNode: _firstNameFocus,
            textInputAction: TextInputAction.next,
            onSubmitted: () => _lastNameFocus.requestFocus(),
          ),
          const SizedBox(height: 13),
          AppTextField(
            label: 'Фамилия',
            icon: Icons.person_outline,
            hint: 'Петров',
            controller: _lastNameCtrl,
            errorText: _lastNameError,
            focusNode: _lastNameFocus,
            textInputAction: TextInputAction.done,
          ),
        ]);

      case 1:
        return Column(children: [
          AppTextField(
            label: 'Email',
            icon: Icons.mail_outline,
            hint: 'ivan@example.com',
            controller: _emailCtrl,
            errorText: _emailError,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onSubmitted: () => _phoneFocus.requestFocus(),
          ),
          const SizedBox(height: 13),
          AppTextField(
            label: 'Телефон',
            icon: Icons.phone_outlined,
            hint: '+996 700 000 000',
            controller: _phoneCtrl,
            errorText: _phoneError,
            focusNode: _phoneFocus,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onSubmitted: () => _dateFocus.requestFocus(),
            inputFormatters: [KgPhoneFormatter()],
          ),
          const SizedBox(height: 13),
          AppTextField(
            label: 'Дата рождения',
            icon: Icons.calendar_today_outlined,
            hint: 'ДД-ММ-ГГГГ',
            controller: _dateCtrl,
            errorText: _dateError,
            focusNode: _dateFocus,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [DateInputFormatter()],
          ),
        ]);

      case 2:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Пароль',
              icon: Icons.lock_outline,
              hint: 'Минимум 6 символов',
              controller: _passwordCtrl,
              obscure: !_showPass,
              errorText: _passwordError,
              focusNode: _passwordFocus,
              textInputAction: TextInputAction.done,
              suffix: GestureDetector(
                onTap: () => setState(() => _showPass = !_showPass),
                child: Icon(
                  _showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: ac.hint,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Выберите филиалы',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ac.sub),
            ),
            const SizedBox(height: 8),
            branchesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) => GestureDetector(
                onTap: () => ref.invalidate(branchesProvider),
                child: const Text(
                  'Не удалось загрузить. Нажмите, чтобы повторить.',
                  style: TextStyle(fontSize: 13, color: Color(0xFFEF4444)),
                ),
              ),
              data: (branches) => Column(
                children: branches.map((b) {
                  final isSelected = _selectedBranch?.id == b.id;
                  return GestureDetector(
                    onTap: () => setState(() { _selectedBranch = b; _branchError = null; }),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 7),
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected ? cs.primary.withValues(alpha: 0.13) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? cs.primary : ac.border,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 17,
                            height: 17,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: isSelected ? cs.primary : ac.border,
                                width: 2,
                              ),
                              color: isSelected ? cs.primary : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 11, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              b.displayName,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_branchError != null) ...[
              const SizedBox(height: 4),
              Text(
                _branchError!,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: Color(0xFFEF4444)),
              ),
            ],
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => setState(() => _agree = !_agree),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _agree ? cs.primary : ac.border, width: 2),
                      color: _agree ? cs.primary : Colors.transparent,
                    ),
                    child: _agree ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 12, color: ac.sub, height: 1.5),
                        children: [
                          const TextSpan(text: 'Нажимая кнопку, вы соглашаетесь с '),
                          TextSpan(
                            text: 'условиями использования ADES',
                            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }
}

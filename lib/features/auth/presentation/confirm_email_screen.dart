import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';
import 'package:cargo_mobile/features/auth/domain/auth_provider.dart';
import 'package:cargo_mobile/shared/widgets/app_button.dart';
import 'package:cargo_mobile/shared/widgets/error_banner.dart';
import 'package:cargo_mobile/shared/widgets/nav_button.dart';

class ConfirmEmailScreen extends ConsumerStatefulWidget {
  const ConfirmEmailScreen({
    super.key,
    required this.login,
    required this.onBack,
    required this.onSuccess,
  });

  final String login;
  final VoidCallback onBack, onSuccess;

  @override
  ConsumerState<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends ConsumerState<ConfirmEmailScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _foci = List.generate(4, (_) => FocusNode());

  bool    _loading       = false;
  bool    _resendLoading = false;
  bool    _confirmed     = false;
  int     _secondsLeft   = 60;
  Timer?  _timer;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        if (mounted) setState(() => _secondsLeft = 0);
      } else {
        if (mounted) setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) { c.dispose(); }
    for (final f in _foci)  { f.dispose(); }
    super.dispose();
  }

  String get _code => _ctrls.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      _ctrls[index].text = value[value.length - 1];
      _ctrls[index].selection = const TextSelection.collapsed(offset: 1);
    }
    setState(() => _serverError = null);
    if (value.isNotEmpty && index < 3) {
      _foci[index + 1].requestFocus();
    }
    if (_code.length == 4) {
      Future.delayed(const Duration(milliseconds: 300), _submit);
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrls[index].text.isEmpty &&
        index > 0) {
      _foci[index - 1].requestFocus();
      _ctrls[index - 1].clear();
    }
  }

  Future<void> _submit() async {
    if (_code.length < 4 || _loading || _confirmed) return;
    setState(() { _loading = true; _serverError = null; });
    try {
      await ref.read(authRepositoryProvider).confirmEmail(widget.login, _code);
      if (!mounted) return;
      setState(() { _confirmed = true; _loading = false; });
      await Future.delayed(const Duration(milliseconds: 1600));
      widget.onSuccess();
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? data['message'] as String? : null;
      if (mounted) {
        setState(() {
          _serverError = message ?? 'Неверный код. Попробуйте снова.';
          _loading = false;
        });
        for (final c in _ctrls) { c.clear(); }
        _foci[0].requestFocus();
      }
    } catch (_) {
      if (mounted) setState(() { _serverError = 'Произошла непредвиденная ошибка.'; _loading = false; });
    }
  }

  Future<void> _resend() async {
    setState(() { _resendLoading = true; _serverError = null; });
    try {
      await ref.read(authRepositoryProvider).resendCode(widget.login);
      _startTimer();
      for (final c in _ctrls) { c.clear(); }
      _foci[0].requestFocus();
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? data['message'] as String? : null;
      setState(() => _serverError = message ?? 'Не удалось отправить код.');
    } catch (_) {
      setState(() => _serverError = 'Произошла непредвиденная ошибка.');
    } finally {
      if (mounted) setState(() => _resendLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ac     = Theme.of(context).extension<AppColors>()!;
    final cs     = Theme.of(context).colorScheme;
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Back button only (no theme toggle per design)
        Padding(
          padding: EdgeInsets.fromLTRB(28, top + 8, 28, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: NavButton(
              onTap: widget.onBack,
              child: Icon(Icons.arrow_back, size: 20, color: cs.onSurface),
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Mail icon box
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isDark
                        ? cs.primary.withValues(alpha: 0.15)
                        : cs.primary.withValues(alpha: 0.10),
                    border: Border.all(
                      color: isDark
                          ? cs.primary.withValues(alpha: 0.30)
                          : cs.primary.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Icon(Icons.mail_outline, size: 28, color: cs.primary),
                ),
                const SizedBox(height: 20),
                Text(
                  '· Подтверждение',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Проверьте почту',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    height: 1.1,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Мы отправили 4-значный код на email, указанный при регистрации',
                  style: TextStyle(fontSize: 13.5, color: ac.sub, height: 1.55),
                ),
                const SizedBox(height: 28),

                if (!_confirmed) ...[
                  // OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => Padding(
                      padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
                      child: _OtpBox(
                        controller: _ctrls[i],
                        focusNode: _foci[i],
                        onChanged: (v) => _onDigitChanged(i, v),
                        onKeyEvent: (e) => _onKeyEvent(i, e),
                        hasError: _serverError != null,
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                  // Resend
                  Center(
                    child: _secondsLeft > 0
                        ? RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 13, color: ac.sub),
                              children: [
                                const TextSpan(text: 'Повторная отправка через '),
                                TextSpan(
                                  text: '${_secondsLeft}с',
                                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )
                        : GestureDetector(
                            onTap: _resendLoading ? null : _resend,
                            child: _resendLoading
                                ? SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                                  )
                                : Text(
                                    'Отправить повторно',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.primary),
                                  ),
                          ),
                  ),
                  // Error
                  if (_serverError != null) ...[
                    const SizedBox(height: 16),
                    AppErrorBanner(message: _serverError!),
                  ],
                ] else ...[
                  // Success card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isDark
                          ? cs.primary.withValues(alpha: 0.12)
                          : cs.primary.withValues(alpha: 0.08),
                      border: Border.all(
                        color: isDark
                            ? cs.primary.withValues(alpha: 0.30)
                            : cs.primary.withValues(alpha: 0.20),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [cs.primary, ac.deep],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ac.deep.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.check, size: 22, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Email подтверждён!',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Аккаунт ${widget.login} готов к использованию',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: ac.sub),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        if (!_confirmed)
          Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 28, bottom + 24),
            child: AppPrimaryButton(
              onTap: (_loading || _code.length < 4) ? null : _submit,
              loading: _loading,
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text('Подтвердить', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
            ),
          ),
      ],
    );
  }
}

// ─── Single OTP digit box ─────────────────────────────────────
class _OtpBox extends StatefulWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
    required this.hasError,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final void Function(KeyEvent) onKeyEvent;
  final bool hasError;

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) setState(() => _focused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ac = Theme.of(context).extension<AppColors>()!;
    final cs = Theme.of(context).colorScheme;

    final borderColor = widget.hasError
        ? const Color(0xFFEF4444)
        : widget.controller.text.isNotEmpty
            ? cs.primary
            : _focused
                ? cs.primary
                : ac.border;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 64,
      height: 70,
      decoration: BoxDecoration(
        color: ac.inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          if ((widget.controller.text.isNotEmpty || _focused) && !widget.hasError)
            BoxShadow(color: cs.primary.withValues(alpha: 0.22), blurRadius: 0, spreadRadius: 4),
          if (widget.hasError)
            BoxShadow(color: const Color(0xFFEF4444).withValues(alpha: 0.12), blurRadius: 0, spreadRadius: 4),
        ],
      ),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: widget.onKeyEvent,
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: widget.onChanged,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

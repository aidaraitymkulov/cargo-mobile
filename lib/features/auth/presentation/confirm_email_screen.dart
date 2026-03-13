import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cargo_mobile/features/auth/domain/auth_provider.dart';
import 'package:cargo_mobile/shared/utils/error_utils.dart';
import 'package:cargo_mobile/shared/utils/validators.dart';
import 'package:cargo_mobile/shared/widgets/api_error_box.dart';
import 'package:cargo_mobile/shared/widgets/app_button.dart';
import 'package:cargo_mobile/shared/widgets/app_scaffold.dart';
import 'package:cargo_mobile/shared/widgets/app_text_field.dart';

class ConfirmEmailScreen extends ConsumerStatefulWidget {
  /// login передаётся через GoRouter extra — не зависит от in-memory state провайдера.
  /// Это важно: если пользователь убьёт приложение и откроет снова,
  /// pending_login читается из SecureStorage в auth_repository.
  final String login;

  const ConfirmEmailScreen({super.key, required this.login});

  @override
  ConsumerState<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends ConsumerState<ConfirmEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  bool _submitted = false;
  bool _isLoading = false;
  bool _resendLoading = false;
  String? _error;
  int _resendCooldown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendCooldown == 0) {
        t.cancel();
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _error = null;
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // confirmEmail делает подтверждение + авто-логин через pending credentials из storage
      await ref.read(authProvider.notifier).confirmEmail(
            code: _codeController.text.trim(),
          );
      // GoRouter автоматически редиректит на / когда authProvider → authenticated
    } catch (e) {
      if (mounted) {
        setState(() => _error = parseAuthError(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    // _resendLoading отдельный от _isLoading — не блокирует кнопку подтверждения
    setState(() {
      _resendLoading = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).resendCode(login: widget.login);
      if (mounted) {
        _startCooldown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Код отправлен повторно')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = parseAuthError(e));
      }
    } finally {
      if (mounted) setState(() => _resendLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Подтверждение email',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Введите код из письма',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Показываем логин пользователю чтобы он знал куда смотреть письмо
            Text(
              'Код отправлен на ${widget.login}',
              style: const TextStyle(fontSize: 15, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            AppCard(
              child: Form(
                key: _formKey,
                autovalidateMode: _submitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _codeController,
                      enabled: !_isLoading,
                      labelText: 'Код подтверждения',
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      counterText: '',
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: Validators.confirmCode,
                    ),
                    const SizedBox(height: 24),
                    ApiErrorBox(error: _error),
                    if (_error != null) const SizedBox(height: 12),
                    AppButton(
                      label: 'Подтвердить',
                      onPressed: _submit,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: _resendCooldown > 0
                          ? Text(
                              'Отправить повторно через $_resendCooldownс',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            )
                          : SizedBox(
                              height: 44,
                              child: TextButton(
                                onPressed: _resendLoading ? null : _resend,
                                child: _resendLoading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator.adaptive(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Отправить код повторно'),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

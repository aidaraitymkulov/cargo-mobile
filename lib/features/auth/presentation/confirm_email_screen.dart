import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';
import 'package:cargo_mobile/features/auth/domain/auth_provider.dart';
import 'package:cargo_mobile/shared/widgets/auth_scaffold.dart';

class ConfirmEmailScreen extends ConsumerStatefulWidget {
  const ConfirmEmailScreen({super.key});

  @override
  ConsumerState<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends ConsumerState<ConfirmEmailScreen> {
  final _codeController = TextEditingController();

  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCooldown == 0) {
        t.cancel();
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _submit() async {
    await ref.read(authProvider.notifier).confirmEmailAndLogin(
          code: _codeController.text.trim(),
        );
  }

  Future<void> _resend() async {
    await ref.read(authRepositoryProvider).resendConfirmEmail();
    _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppTheme.error),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return AuthScaffold(
      title: 'Подтверждение email',
      showBackButton: true,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Введите код из письма',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Мы отправили код подтверждения на вашу почту',
              style: TextStyle(fontSize: 15, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            AuthCard(
              child: Column(
                children: [
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: 'Код подтверждения',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state.isLoading ? null : _submit,
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Подтвердить'),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: _resendCooldown > 0
                        ? Text(
                            'Отправить повторно через ${_resendCooldown}с',
                            style: const TextStyle(color: AppTheme.textSecondary),
                          )
                        : TextButton(
                            onPressed: _resend,
                            child: const Text('Отправить код повторно'),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

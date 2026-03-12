import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';
import 'package:cargo_mobile/features/auth/domain/auth_provider.dart';
import 'package:cargo_mobile/shared/widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _loginController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _codeSent = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _loginController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).forgotPasswordRequest(
            login: _loginController.text.trim(),
          );
      if (mounted && ref.read(authProvider).error == null) {
        setState(() => _codeSent = true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirm() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).forgotPasswordConfirm(
            code: _codeController.text.trim(),
            newPassword: _newPasswordController.text,
          );
      if (mounted && ref.read(authProvider).error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пароль успешно изменён')),
        );
        context.go('/auth/login');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppTheme.error),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return AuthScaffold(
      title: 'Восстановление пароля',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              _codeSent ? 'Введите код и новый пароль' : 'Введите ваш логин',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _codeSent
                  ? 'Мы отправили код на вашу почту'
                  : 'Мы отправим код для сброса пароля',
              style: const TextStyle(fontSize: 15, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            AuthCard(
              child: Column(
                children: [
                  if (!_codeSent) ...[
                    TextField(
                      controller: _loginController,
                      decoration: const InputDecoration(labelText: 'Логин'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _requestCode,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Отправить код'),
                    ),
                  ] else ...[
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'Код подтверждения',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Новый пароль',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppTheme.textSecondary,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _confirm,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Сменить пароль'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

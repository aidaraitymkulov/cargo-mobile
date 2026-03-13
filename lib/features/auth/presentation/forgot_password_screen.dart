import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';
import 'package:cargo_mobile/features/auth/domain/auth_provider.dart';
import 'package:cargo_mobile/shared/utils/error_utils.dart';
import 'package:cargo_mobile/shared/utils/validators.dart';
import 'package:cargo_mobile/shared/widgets/api_error_box.dart';
import 'package:cargo_mobile/shared/widgets/app_button.dart';
import 'package:cargo_mobile/shared/widgets/app_scaffold.dart';
import 'package:cargo_mobile/shared/widgets/app_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Весь стейт локальный — AuthState не содержит isLoading/error
  bool _codeSent = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _loginController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    setState(() {
      _submitted = true;
      _error = null;
    });
    if (!_step1FormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).forgotPasswordRequest(
            login: _loginController.text.trim(),
          );
      if (mounted) {
        setState(() {
          _codeSent = true;
          _submitted = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = parseAuthError(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirm() async {
    setState(() {
      _submitted = true;
      _error = null;
    });
    if (!_step2FormKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Пароли не совпадают');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).forgotPasswordConfirm(
            code: _codeController.text.trim(),
            newPassword: _newPasswordController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пароль успешно изменён')),
        );
        context.go('/auth/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = parseAuthError(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Восстановление пароля',
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

            // Визуальный индикатор шагов
            _StepIndicator(currentStep: _codeSent ? 2 : 1),
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
                  ? 'Код отправлен на вашу почту'
                  : 'Мы отправим код для сброса пароля',
              style: const TextStyle(fontSize: 15, color: Colors.white70),
            ),
            const SizedBox(height: 32),

            AppCard(
              child: !_codeSent ? _buildStep1() : _buildStep2(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _step1FormKey,
      autovalidateMode:
          _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      child: Column(
        children: [
          AppTextField(
            controller: _loginController,
            enabled: !_isLoading,
            labelText: 'Логин или Email',
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _requestCode(),
            validator: (v) => Validators.required(v, label: 'Логин'),
          ),
          const SizedBox(height: 24),
          ApiErrorBox(error: _error),
          if (_error != null) const SizedBox(height: 12),
          AppButton(
            label: 'Отправить код',
            onPressed: _requestCode,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _step2FormKey,
      autovalidateMode:
          _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      child: Column(
        children: [
          AppTextField(
            controller: _codeController,
            enabled: !_isLoading,
            labelText: 'Код подтверждения',
            keyboardType: TextInputType.number,
            maxLength: 6,
            counterText: '',
            textInputAction: TextInputAction.next,
            validator: Validators.confirmCode,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _newPasswordController,
            enabled: !_isLoading,
            labelText: 'Новый пароль',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            validator: Validators.password,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textSecondary,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _confirmPasswordController,
            enabled: !_isLoading,
            labelText: 'Повторите пароль',
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _confirm(),
            validator: (v) => Validators.required(v, label: 'Повтор пароля'),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppTheme.textSecondary,
              ),
              onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
          const SizedBox(height: 24),
          ApiErrorBox(error: _error),
          if (_error != null) const SizedBox(height: 12),
          AppButton(
            label: 'Сменить пароль',
            onPressed: _confirm,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 8),
          // Возможность вернуться на шаг 1 и поправить логин
          TextButton(
            onPressed: _isLoading
                ? null
                : () => setState(() {
                      _codeSent = false;
                      _submitted = false;
                      _error = null;
                    }),
            child: const Text('Изменить логин'),
          ),
        ],
      ),
    );
  }
}

/// Визуальный индикатор шагов: шаг 1 → линия → шаг 2
class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepDot(number: 1, isActive: currentStep >= 1),
        _StepLine(isActive: currentStep >= 2),
        _StepDot(number: 2, isActive: currentStep >= 2),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final int number;
  final bool isActive;

  const _StepDot({required this.number, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : Colors.white24,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isActive;

  const _StepLine({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 48,
      height: 2,
      color: isActive ? AppTheme.primary : Colors.white24,
    );
  }
}

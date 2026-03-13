import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cargo_mobile/core/api/branch_api.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';
import 'package:cargo_mobile/features/auth/domain/auth_provider.dart';
import 'package:cargo_mobile/models/branch/branch.dart';
import 'package:cargo_mobile/shared/utils/error_utils.dart';
import 'package:cargo_mobile/shared/utils/validators.dart';
import 'package:cargo_mobile/shared/widgets/api_error_box.dart';
import 'package:cargo_mobile/shared/widgets/app_button.dart';
import 'package:cargo_mobile/shared/widgets/app_scaffold.dart';
import 'package:cargo_mobile/shared/widgets/app_text_field.dart';
import 'package:cargo_mobile/shared/widgets/branch_dropdown_field.dart';
import 'package:cargo_mobile/shared/widgets/date_text_field.dart';
import 'package:cargo_mobile/shared/widgets/phone_text_field.dart';

final _branchesProvider = FutureProvider<List<Branch>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final api = BranchApi(dio);
  final items = await api.getBranches();
  return items.map((e) => Branch.fromJson(e)).toList();
});

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _loginController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _submitted = false;
  bool _isLoading = false;
  String? _error;
  Branch? _selectedBranch;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _loginController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _error = null;
    });

    // validate() первым — все поля подсвечиваются
    final formValid = _formKey.currentState!.validate();

    final branchesAsync = ref.read(_branchesProvider);
    if (branchesAsync.isLoading) {
      setState(() => _error = 'Подождите загрузки филиалов');
      return;
    }

    if (!formValid || _selectedBranch == null) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Пароли не совпадают');
      return;
    }

    final dateOfBirth = DateTextField.toIsoDate(_dateController.text);
    if (dateOfBirth == null) return;

    setState(() => _isLoading = true);
    final loginValue = _loginController.text.trim();
    try {
      await ref.read(authProvider.notifier).register(
            login: loginValue,
            email: _emailController.text.trim(),
            password: _passwordController.text,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phone: _phoneController.text.trim(),
            dateOfBirth: dateOfBirth,
            branchId: _selectedBranch!.id,
          );
      if (mounted) {
        context.push('/auth/confirm-email', extra: {'login': loginValue});
      }
    } catch (e) {
      if (mounted) setState(() => _error = parseAuthError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final branchesAsync = ref.watch(_branchesProvider);

    return AppScaffold(
      title: 'Регистрация',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _firstNameController,
                  enabled: !_isLoading,
                  labelText: 'Имя',
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, label: 'Имя'),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _lastNameController,
                  enabled: !_isLoading,
                  labelText: 'Фамилия',
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, label: 'Фамилия'),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _loginController,
                  enabled: !_isLoading,
                  labelText: 'Логин',
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, label: 'Логин'),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _emailController,
                  enabled: !_isLoading,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),

                PhoneTextField(
                  controller: _phoneController,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.next,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 16),

                DateTextField(
                  controller: _dateController,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.next,
                  minAge: 16,
                ),
                const SizedBox(height: 16),

                BranchDropdownField(
                  branchesAsync: branchesAsync,
                  value: _selectedBranch,
                  enabled: !_isLoading,
                  onChanged: (b) => setState(() => _selectedBranch = b),
                  onRetry: () => ref.refresh(_branchesProvider),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _passwordController,
                  enabled: !_isLoading,
                  labelText: 'Пароль',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _confirmPasswordController,
                  enabled: !_isLoading,
                  labelText: 'Повторите пароль',
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
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
                  label: 'Зарегистрироваться',
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Уже есть аккаунт? ',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : () => context.pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                      ),
                      child: const Text('Войти'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

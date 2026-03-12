import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';
import 'package:cargo_mobile/core/api/branch_api.dart';
import 'package:cargo_mobile/features/auth/domain/auth_provider.dart';
import 'package:cargo_mobile/models/branch/branch.dart';
import 'package:cargo_mobile/shared/widgets/auth_scaffold.dart';

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
  final _loginController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  DateTime? _dateOfBirth;
  Branch? _selectedBranch;

  @override
  void dispose() {
    _loginController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _submit() async {
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите дату рождения')));
      return;
    }
    if (_selectedBranch == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите филиал')));
      return;
    }

    await ref
        .read(authProvider.notifier)
        .register(
          login: _loginController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: _phoneController.text.trim(),
          dateOfBirth: DateFormat('yyyy-MM-dd').format(_dateOfBirth!),
          branchId: _selectedBranch!.id,
        );

    if (mounted && ref.read(authProvider).error == null) {
      context.push('/auth/confirm-email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final branchesAsync = ref.watch(_branchesProvider);

    ref.listen(authProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppTheme.error),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return AuthScaffold(
      title: 'Регистрация',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: AuthCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _loginController,
                decoration: const InputDecoration(labelText: 'Логин'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Имя'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Фамилия'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Телефон'),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Дата рождения'),
                  child: Text(
                    _dateOfBirth != null
                        ? DateFormat('dd.MM.yyyy').format(_dateOfBirth!)
                        : 'Выберите дату',
                    style: TextStyle(
                      color: _dateOfBirth != null
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              branchesAsync.when(
                data: (branches) => DropdownButtonFormField<Branch>(
                  value: _selectedBranch,
                  decoration: const InputDecoration(labelText: 'Филиал'),
                  items: branches
                      .map(
                        (b) =>
                            DropdownMenuItem(value: b, child: Text(b.address)),
                      )
                      .toList(),
                  onChanged: (b) => setState(() => _selectedBranch = b),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text(
                  'Не удалось загрузить филиалы',
                  style: TextStyle(color: AppTheme.error),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: state.isLoading ? null : _submit,
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Зарегистрироваться'),
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
                    onPressed: () => context.pop(),
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
    );
  }
}

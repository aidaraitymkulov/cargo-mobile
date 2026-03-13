import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:cargo_mobile/core/api/auth_api.dart';
import 'package:cargo_mobile/core/api/dio_client.dart';
import 'package:cargo_mobile/core/storage/token_storage.dart';
import 'package:cargo_mobile/features/auth/data/auth_repository.dart';
import 'package:cargo_mobile/models/user/user.dart';

// --- Providers ---

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(const FlutterSecureStorage());
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref.watch(tokenStorageProvider));
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(dioClientProvider).dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authApiProvider),
    ref.watch(tokenStorageProvider),
  );
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// --- AuthStatus enum ---

enum AuthStatus {
  /// Приложение только запустилось, проверяем сохранённый токен
  initializing,

  /// Пользователь авторизован
  authenticated,

  /// Пользователь не авторизован
  unauthenticated,
}

// --- State ---
// Хранит ТОЛЬКО статус сессии. isLoading и error — в каждом экране локально.
// Аналогия из React: это как AuthContext — только user + статус, не форм-стейт.

class AuthState {
  final User? user;
  final AuthStatus status;

  const AuthState({
    this.user,
    this.status = AuthStatus.unauthenticated,
  });

  bool get isLoggedIn => status == AuthStatus.authenticated;
  bool get isInitializing => status == AuthStatus.initializing;

  AuthState copyWith({User? user, AuthStatus? status}) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
    );
  }
}

// --- Notifier ---
// Методы бросают исключения — экраны ловят их сами и управляют своим isLoading/error.
// Это как useReducer: notifier меняет только глобальный auth-стейт, а
// форм-логика остаётся внутри каждого StatefulWidget.

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository)
      : super(const AuthState(status: AuthStatus.initializing));

  /// Вызывается при старте приложения. Проверяет сохранённый токен.
  /// При успехе → authenticated, при неудаче → unauthenticated.
  Future<void> tryRestoreSession() async {
    try {
      final user = await _repository.tryRestoreSession();
      if (user != null) {
        state = AuthState(user: user, status: AuthStatus.authenticated);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    } finally {
      // Убираем нативный сплэш — GoRouter уже знает куда вести
      FlutterNativeSplash.remove();
    }
  }

  /// Логин. Бросает исключение при ошибке — экран сам ловит и показывает error.
  Future<void> login({
    required String login,
    required String password,
  }) async {
    final user = await _repository.login(login: login, password: password);
    state = AuthState(user: user, status: AuthStatus.authenticated);
  }

  /// Регистрация. Бросает исключение при ошибке.
  /// Стейт не меняем — пользователь ещё не авторизован, ждёт confirm email.
  Future<void> register({
    required String login,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String dateOfBirth,
    required String branchId,
  }) async {
    await _repository.register(
      login: login,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      dateOfBirth: dateOfBirth,
      branchId: branchId,
    );
  }

  /// Подтверждение email + авто-логин. Бросает исключение при ошибке.
  Future<void> confirmEmail({required String code}) async {
    final user = await _repository.confirmEmailAndLogin(code: code);
    state = AuthState(user: user, status: AuthStatus.authenticated);
  }

  /// Повторная отправка кода. Бросает исключение при ошибке.
  Future<void> resendCode({required String login}) async {
    await _repository.resendConfirmEmail(login: login);
  }

  /// Запрос кода сброса пароля. Бросает исключение при ошибке.
  Future<void> forgotPasswordRequest({required String login}) async {
    await _repository.forgotPasswordRequest(login: login);
  }

  /// Подтверждение нового пароля. Бросает исключение при ошибке.
  Future<void> forgotPasswordConfirm({
    required String code,
    required String newPassword,
  }) async {
    await _repository.forgotPasswordConfirm(code: code, newPassword: newPassword);
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } finally {
      // Разлогиниваем локально даже если сервер не ответил
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Обновить данные пользователя в стейте (после редактирования профиля)
  void updateUser(User user) {
    state = state.copyWith(user: user, status: AuthStatus.authenticated);
  }
}

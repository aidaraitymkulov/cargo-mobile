import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
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

// --- State ---

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// --- Notifier ---

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

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
    state = state.copyWith(isLoading: true, clearError: true);
    try {
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
      state = state.copyWith(isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
    }
  }

  Future<void> confirmEmailAndLogin({required String code}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.confirmEmailAndLogin(code: code);
      state = state.copyWith(isLoading: false, user: user);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
    }
  }

  Future<void> login({
    required String login,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.login(login: login, password: password);
      state = state.copyWith(isLoading: false, user: user);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.logout();
      state = const AuthState();
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
    }
  }

  Future<void> forgotPasswordRequest({required String login}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.forgotPasswordRequest(login: login);
      state = state.copyWith(isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
    }
  }

  Future<void> forgotPasswordConfirm({
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.forgotPasswordConfirm(code: code, newPassword: newPassword);
      state = state.copyWith(isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'];
    }
    return 'Произошла ошибка. Попробуйте снова.';
  }
}

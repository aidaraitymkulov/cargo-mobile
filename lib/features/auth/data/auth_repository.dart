import 'package:cargo_mobile/core/api/auth_api.dart';
import 'package:cargo_mobile/core/storage/token_storage.dart';
import 'package:cargo_mobile/models/user/user.dart';

class AuthRepository {
  final AuthApi _api;
  final TokenStorage _tokenStorage;

  AuthRepository(this._api, this._tokenStorage);

  /// Регистрация: сохраняем login+password в storage для авто-логина после confirm
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
    await _api.register(
      login: login,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      dateOfBirth: dateOfBirth,
      branchId: branchId,
    );
    // Сохраняем в secure storage — переживёт hot-restart и background kill
    await _tokenStorage.savePendingCredentials(
      login: login,
      password: password,
    );
  }

  /// Подтверждение email + авто-логин.
  /// Читает pending credentials из storage, подтверждает, логинится, чистит.
  Future<User> confirmEmailAndLogin({required String code}) async {
    final login = await _tokenStorage.getPendingLogin();
    final password = await _tokenStorage.getPendingPassword();

    if (login == null || password == null) {
      throw Exception('Credentials not found. Please register again.');
    }

    await _api.confirmEmail(login: login, code: code);

    final user = await _login(login: login, password: password);

    // Чистим pending после успешного подтверждения
    await _tokenStorage.clearPendingCredentials();

    return user;
  }

  /// Повторная отправка кода — login берётся из storage
  Future<void> resendConfirmEmail({required String login}) async {
    await _api.resendConfirmEmail(login: login);
  }

  Future<User> login({
    required String login,
    required String password,
  }) async {
    return _login(login: login, password: password);
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _api.logout(refreshToken: refreshToken);
      } catch (_) {
        // Если сервер недоступен — всё равно чистим локальные токены
      }
    }
    await _tokenStorage.clear();
  }

  Future<void> forgotPasswordRequest({required String login}) async {
    await _api.forgotPasswordRequest(login: login);
  }

  Future<void> forgotPasswordConfirm({
    required String code,
    required String newPassword,
  }) async {
    await _api.forgotPasswordConfirm(code: code, newPassword: newPassword);
  }

  /// Восстановление сессии при запуске — проверяем токен через GET /users/me
  Future<User?> tryRestoreSession() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null) return null;

    try {
      final data = await _api.getMe();
      return User.fromJson(data);
    } catch (_) {
      // Токен невалидный или истёк, DioClient сам попытался refresh
      // Если всё равно упало — сессия мертва
      await _tokenStorage.clear();
      return null;
    }
  }

  Future<User> _login({
    required String login,
    required String password,
  }) async {
    final data = await _api.login(login: login, password: password);
    await _tokenStorage.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }
}

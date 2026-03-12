import 'package:cargo_mobile/core/api/auth_api.dart';
import 'package:cargo_mobile/core/storage/token_storage.dart';
import 'package:cargo_mobile/models/user/user.dart';

class AuthRepository {
  final AuthApi _api;
  final TokenStorage _tokenStorage;

  // Временно храним логин+пароль для авто-логина после confirm email
  String? _pendingLogin;
  String? _pendingPassword;

  AuthRepository(this._api, this._tokenStorage);

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
    _pendingLogin = login;
    _pendingPassword = password;
  }

  Future<User> confirmEmailAndLogin({required String code}) async {
    final login = _pendingLogin;
    final password = _pendingPassword;

    if (login == null || password == null) {
      throw Exception('No pending credentials for auto-login');
    }

    await _api.confirmEmail(login: login, code: code);

    final result = await _login(login: login, password: password);
    _pendingLogin = null;
    _pendingPassword = null;
    return result;
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
      await _api.logout(refreshToken: refreshToken);
    }
    await _tokenStorage.clear();
  }

  Future<void> resendConfirmEmail() async {
    await _api.resendConfirmEmail(login: _pendingLogin ?? '');
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

  Future<User> _login({
    required String login,
    required String password,
  }) async {
    final data = await _api.login(login: login, password: password);
    await _tokenStorage.saveTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
    return User.fromJson(data['user']);
  }
}

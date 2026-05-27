import 'package:cargo_mobile/core/api/auth_api.dart';
import 'package:cargo_mobile/core/storage/token_storage.dart';

class AuthRepository {
  final AuthApi _api;
  final TokenStorage _storage;

  AuthRepository(this._api, this._storage);

  Future<void> login(String login, String password) async {
    final data = await _api.login(login, password);
    await _storage.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }

  Future<bool> hasValidSession() async {
    return await _storage.getAccessToken() != null;
  }
}

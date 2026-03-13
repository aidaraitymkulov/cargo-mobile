import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _pendingLoginKey = 'pending_login';
  static const _pendingPasswordKey = 'pending_password';

  final FlutterSecureStorage _storage;

  TokenStorage(this._storage);

  // --- Токены авторизации ---

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    // Чистим pending при явном logout
    await clearPendingCredentials();
  }

  // --- Временные credentials для авто-логина после подтверждения email ---
  // Храним в Keychain/Keystore — безопаснее чем in-memory (переживает hot-restart)

  Future<void> savePendingCredentials({
    required String login,
    required String password,
  }) async {
    await _storage.write(key: _pendingLoginKey, value: login);
    await _storage.write(key: _pendingPasswordKey, value: password);
  }

  Future<String?> getPendingLogin() => _storage.read(key: _pendingLoginKey);
  Future<String?> getPendingPassword() => _storage.read(key: _pendingPasswordKey);

  Future<void> clearPendingCredentials() async {
    await _storage.delete(key: _pendingLoginKey);
    await _storage.delete(key: _pendingPasswordKey);
  }
}

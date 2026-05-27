import 'package:flutter/foundation.dart';
import 'package:cargo_mobile/core/api/auth_api.dart';
import 'package:cargo_mobile/core/storage/token_storage.dart';

class AuthRepository {
  final AuthApi _api;
  final TokenStorage _storage;

  AuthRepository(this._api, this._storage);

  Future<void> login(String login, String password) async {
    final data = await _api.login(login, password);
    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;
    if (accessToken == null || refreshToken == null) {
      throw const FormatException('Invalid login response: missing token fields');
    }
    await _storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _api.logout(refreshToken);
      } catch (_) {
        // Сервер недоступен — всё равно чистим локально
      }
    }
    await _storage.clear();
  }

  Future<bool> hasValidSession() async {
    try {
      return await _storage.getAccessToken() != null;
    } catch (e) {
      debugPrint('[AuthRepository] Failed to read session token: $e');
      return false;
    }
  }
}

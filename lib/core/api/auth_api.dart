import 'package:dio/dio.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'login': login,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

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
    await _dio.post('/auth/register', data: {
      'login': login,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'branchId': branchId,
    });
  }

  Future<void> logout({required String refreshToken}) async {
    await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
  }

  /// POST /auth/confirm — подтверждение email кодом
  Future<void> confirmEmail({required String login, required String code}) async {
    await _dio.post('/auth/confirm', data: {'login': login, 'code': code});
  }

  /// POST /auth/resend?login={login} — повторная отправка кода (без авторизации)
  Future<void> resendConfirmEmail({required String login}) async {
    await _dio.post('/auth/resend', queryParameters: {'login': login});
  }

  Future<Map<String, dynamic>> refreshTokens({required String refreshToken}) async {
    final response = await _dio.post('/auth/refresh', data: {
      'refreshToken': refreshToken,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<void> forgotPasswordRequest({required String login}) async {
    await _dio.post('/auth/forgot-password/request', data: {'login': login});
  }

  Future<void> forgotPasswordConfirm({
    required String code,
    required String newPassword,
  }) async {
    await _dio.post('/auth/forgot-password/confirm', data: {
      'code': code,
      'newPassword': newPassword,
    });
  }

  /// GET /users/me — используется для восстановления сессии при запуске
  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get('/users/me');
    return response.data as Map<String, dynamic>;
  }
}

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
    return response.data;
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

  Future<void> confirmEmail({required String login, required String code}) async {
    await _dio.post('/auth/confirm', data: {'login': login, 'code': code});
  }

  Future<void> resendConfirmEmail({required String login}) async {
    await _dio.get('/auth/resend', queryParameters: {'login': login});
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
}

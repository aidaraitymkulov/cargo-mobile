import 'package:dio/dio.dart';
import 'package:cargo_mobile/core/api/dio_client.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(DioClient client) : _dio = client.dio;

  Future<Map<String, dynamic>> login(String login, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'login': login, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout(String refreshToken) async {
    await _dio.post(
      '/auth/logout',
      data: {'refreshToken': refreshToken},
    );
  }

  Future<void> register({
    required String login,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
    required String branchId,
  }) async {
    await _dio.post('/auth/register', data: {
      'login': login,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'password': password,
      'branchId': branchId,
    });
  }

  Future<void> confirmEmail(String login, String code) async {
    await _dio.post('/auth/confirm', data: {'login': login, 'code': code});
  }

  Future<void> resendCode(String login) async {
    await _dio.post('/auth/resend', queryParameters: {'login': login});
  }
}

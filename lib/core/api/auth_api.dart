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
}

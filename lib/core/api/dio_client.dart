import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:cargo_mobile/core/constants/app_constants.dart';
import 'package:cargo_mobile/core/storage/token_storage.dart';

class DioClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  DioClient(this._tokenStorage)
      : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'X-Client-Type': 'mobile',
          },
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  Dio get dio => _dio;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();
    debugPrint('[DioClient] >>> ${options.method} ${options.path}');
    debugPrint('[DioClient] accessToken:  $accessToken');
    debugPrint('[DioClient] refreshToken: $refreshToken');
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final path = error.requestOptions.path;
    final isAuthEndpoint = path.startsWith('/auth/');

    if (error.response?.statusCode == 401 && !isAuthEndpoint) {
      debugPrint('[DioClient] 401 on $path — trying token refresh...');
      final refreshed = await _tryRefresh();
      if (refreshed) {
        debugPrint('[DioClient] Refresh SUCCESS — retrying $path');
        final token = await _tokenStorage.getAccessToken();
        error.requestOptions.headers['Authorization'] = 'Bearer $token';
        final response = await _dio.fetch(error.requestOptions);
        return handler.resolve(response);
      } else {
        debugPrint('[DioClient] Refresh FAILED — clearing tokens, redirecting to login');
        await _tokenStorage.clear();
      }
    }
    handler.next(error);
  }

  Future<bool> _tryRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      debugPrint('[DioClient] Refresh FAILED — no refreshToken in storage');
      return false;
    }

    try {
      debugPrint('[DioClient] Sending refresh request...');
      final response = await Dio().post(
        '${AppConstants.baseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'X-Client-Type': 'mobile'}),
      );
      await _tokenStorage.saveTokens(
        accessToken: response.data['accessToken'],
        refreshToken: response.data['refreshToken'],
      );
      debugPrint('[DioClient] New tokens saved');
      return true;
    } catch (e) {
      debugPrint('[DioClient] Refresh request error: $e');
      return false;
    }
  }
}

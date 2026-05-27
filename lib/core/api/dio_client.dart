import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:cargo_mobile/core/constants/app_constants.dart';
import 'package:cargo_mobile/core/storage/token_storage.dart';

class DioClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  Future<bool>? _pendingRefresh;

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
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      try {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          final token = await _tokenStorage.getAccessToken();
          error.requestOptions.headers['Authorization'] = 'Bearer $token';
          final response = await _dio.fetch(error.requestOptions);
          return handler.resolve(response);
        } else {
          debugPrint('[DioClient] Refresh token rejected — clearing session');
          await _tokenStorage.clear();
        }
      } catch (e, stack) {
        // Network/storage error during refresh — don't clear tokens
        debugPrint('[DioClient] Unexpected error during token refresh: $e\n$stack');
      }
    }
    handler.next(error);
  }

  // Все параллельные 401 ждут одного и того же запроса рефреша
  Future<bool> _tryRefresh() {
    return _pendingRefresh ??= _performRefresh()
        .whenComplete(() => _pendingRefresh = null);
  }

  Future<bool> _performRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await Dio().post(
        '${AppConstants.baseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'X-Client-Type': 'mobile'}),
      );
      final accessToken = response.data['accessToken'] as String?;
      final newRefreshToken = response.data['refreshToken'] as String?;
      if (accessToken == null || newRefreshToken == null) {
        throw const FormatException('Invalid refresh response: missing token fields');
      }
      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('[DioClient] Refresh token rejected: ${e.response?.statusCode}');
        return false;
      }
      rethrow;
    }
  }
}

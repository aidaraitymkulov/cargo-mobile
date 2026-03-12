import 'package:dio/dio.dart';
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
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final token = await _tokenStorage.getAccessToken();
        error.requestOptions.headers['Authorization'] = 'Bearer $token';
        final response = await _dio.fetch(error.requestOptions);
        return handler.resolve(response);
      } else {
        await _tokenStorage.clear();
      }
    }
    handler.next(error);
  }

  Future<bool> _tryRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await Dio().post(
        '${AppConstants.baseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'X-Client-Type': 'mobile'}),
      );
      await _tokenStorage.saveTokens(
        accessToken: response.data['accessToken'],
        refreshToken: response.data['refreshToken'],
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

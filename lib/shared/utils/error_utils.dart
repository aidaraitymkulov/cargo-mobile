import 'package:dio/dio.dart';

/// Парсит ошибку в человекочитаемую строку для показа пользователю.
/// Бэкенд сам возвращает нормальные сообщения в поле message — берём их напрямую.
/// Для сетевых проблем — фолбэк на русский текст.
String parseAuthError(Object e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Нет соединения с сервером';
    }
  }
  return 'Произошла ошибка. Попробуйте ещё раз';
}

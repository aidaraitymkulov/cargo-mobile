import 'package:flutter/services.dart';

/// Форматирует ввод цифр в DD-MM-YYYY по мере набора.
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    final digits = next.text.replaceAll(RegExp(r'[^\d]'), '');
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;
    final result = _format(limited);
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  static String _format(String d) {
    if (d.length <= 2) return d;
    if (d.length <= 4) return '${d.substring(0, 2)}-${d.substring(2)}';
    return '${d.substring(0, 2)}-${d.substring(2, 4)}-${d.substring(4)}';
  }

  /// Возвращает true, если строка содержит полную дату (8 цифр).
  static bool isComplete(String value) =>
      value.replaceAll('-', '').length == 8;

  /// Конвертирует DD-MM-YYYY → YYYY-MM-DD для отправки на сервер.
  static String toApiValue(String value) {
    final d = value.replaceAll('-', '');
    if (d.length < 8) return value;
    return '${d.substring(4)}-${d.substring(2, 4)}-${d.substring(0, 2)}';
  }

  /// Базовая проверка корректности даты.
  static String? validate(String value) {
    final d = value.replaceAll('-', '');
    if (d.isEmpty) return 'Заполните поле';
    if (d.length < 8) return 'Введите полную дату';
    final day   = int.tryParse(d.substring(0, 2));
    final month = int.tryParse(d.substring(2, 4));
    final year  = int.tryParse(d.substring(4));
    if (day == null || month == null || year == null) return 'Некорректная дата';
    if (month < 1 || month > 12) return 'Некорректная дата';
    if (day < 1 || day > 31) return 'Некорректная дата';
    final now = DateTime.now();
    if (year < 1940 || year > now.year - 14) return 'Некорректная дата';
    return null;
  }
}

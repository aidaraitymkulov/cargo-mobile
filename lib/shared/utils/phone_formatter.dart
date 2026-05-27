import 'package:flutter/services.dart';

/// Форматирует ввод в +996 XXX XXX XXX.
/// При отправке на сервер убирай + и пробелы: text.replaceAll(RegExp(r'[+\s]'), '')
class KgPhoneFormatter extends TextInputFormatter {
  static const _prefix = '+996 ';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    final all = next.text.replaceAll(RegExp(r'[^\d]'), '');
    final userDigits = all.startsWith('996') ? all.substring(3) : all;
    final limited =
        userDigits.length > 9 ? userDigits.substring(0, 9) : userDigits;
    final result = _prefix + _formatDigits(limited);
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  static String _formatDigits(String d) {
    if (d.length <= 3) return d;
    if (d.length <= 6) return '${d.substring(0, 3)} ${d.substring(3)}';
    return '${d.substring(0, 3)} ${d.substring(3, 6)} ${d.substring(6)}';
  }

  /// Возвращает только цифры без кода страны: 700123456
  static String digitsOnly(String formatted) {
    return formatted.replaceAll(RegExp(r'[+\s]'), '').substring(3);
  }

  /// Форматирует для отправки на сервер: 996700123456
  static String toApiValue(String formatted) {
    return formatted.replaceAll(RegExp(r'[+\s]'), '');
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Поле ввода даты с маской дд/мм/гггг.
/// Слэши вставляются автоматически. Валидирует корректность даты и минимальный возраст.
class DateTextField extends StatelessWidget {
  const DateTextField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.minAge = 0,
  });

  final TextEditingController controller;
  final bool enabled;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  /// Минимальный возраст в годах. 0 — без ограничения.
  final int minAge;

  String? _validate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите дату рождения';
    if (value.length < 10) return 'Введите полную дату (ДД/ММ/ГГГГ)';

    final parts = value.split('/');
    if (parts.length != 3) return 'Некорректная дата';

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return 'Некорректная дата';
    if (year < 1900) return 'Некорректная дата';

    final date = DateTime.tryParse(
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
    );
    if (date == null || date.day != day || date.month != month || date.year != year) {
      return 'Некорректная дата';
    }

    if (minAge > 0) {
      final minBirthDate = DateTime.now().subtract(Duration(days: 365 * minAge));
      if (date.isAfter(minBirthDate)) {
        return 'Возраст должен быть не менее $minAge лет';
      }
    }

    return null;
  }

  /// Возвращает дату из контроллера в формате yyyy-MM-dd, или null если некорректная.
  static String? toIsoDate(String text) {
    final parts = text.split('/');
    if (parts.length != 3 || parts[2].length != 4) return null;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      inputFormatters: [_DateInputFormatter()],
      validator: _validate,
      onFieldSubmitted: onFieldSubmitted,
      decoration: const InputDecoration(
        labelText: 'Дата рождения',
        hintText: 'ДД/ММ/ГГГГ',
      ),
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    if (digits.length > 8) return oldValue;

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

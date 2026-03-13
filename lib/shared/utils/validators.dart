class Validators {
  static String? required(String? value, {String label = 'Поле'}) {
    if (value == null || value.trim().isEmpty) return '$label не может быть пустым';
    return null;
  }

  static String? email(String? value) {
    final err = required(value, label: 'Email');
    if (err != null) return err;
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value!.trim())) {
      return 'Некорректный формат email';
    }
    return null;
  }

  static String? phone(String? value) {
    final err = required(value, label: 'Телефон');
    if (err != null) return err;
    if (!RegExp(r'^\+996\d{9}$').hasMatch(value!.trim())) {
      return 'Формат: +996XXXXXXXXX';
    }
    return null;
  }

  static String? password(String? value) {
    final err = required(value, label: 'Пароль');
    if (err != null) return err;
    if (value!.length < 6) return 'Минимум 6 символов';
    if (!RegExp(r'\d').hasMatch(value)) return 'Должен содержать хотя бы одну цифру';
    return null;
  }

  static String? confirmCode(String? value) {
    final err = required(value, label: 'Код');
    if (err != null) return err;
    final trimmed = value!.trim();
    if (!RegExp(r'^\d{4,6}$').hasMatch(trimmed)) return 'Код — от 4 до 6 цифр';
    return null;
  }
}

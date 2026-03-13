import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Поле ввода телефона с автоматическим префиксом +996.
/// Пользователь вводит только 9 цифр после префикса.
/// Итоговое значение контроллера всегда в формате +996XXXXXXXXX.
class PhoneTextField extends StatefulWidget {
  const PhoneTextField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  @override
  State<PhoneTextField> createState() => _PhoneTextFieldState();
}

class _PhoneTextFieldState extends State<PhoneTextField> {
  static const _prefix = '+996';
  // Максимум: +996 (4) + 9 цифр = 13 символов
  static const _maxLength = 13;

  @override
  void initState() {
    super.initState();
    // Инициализируем префикс если контроллер пустой
    if (widget.controller.text.isEmpty) {
      widget.controller.text = _prefix;
      widget.controller.selection =
          TextSelection.collapsed(offset: _prefix.length);
    }
    widget.controller.addListener(_enforcePrefix);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_enforcePrefix);
    super.dispose();
  }

  void _enforcePrefix() {
    final text = widget.controller.text;
    if (text.startsWith(_prefix)) return;

    // Пользователь удалил часть префикса — восстанавливаем
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    // Оставляем только 9 цифр (без кода страны)
    final tail = digits.length > 9 ? digits.substring(digits.length - 9) : digits;
    final restored = '$_prefix$tail';
    widget.controller.value = TextEditingValue(
      text: restored,
      selection: TextSelection.collapsed(offset: restored.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      keyboardType: TextInputType.phone,
      textInputAction: widget.textInputAction,
      maxLength: _maxLength,
      inputFormatters: [
        // Разрешаем только цифры и знак +
        FilteringTextInputFormatter.allow(RegExp(r'[+\d]')),
      ],
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: const InputDecoration(
        labelText: 'Телефон',
        hintText: '+996 XXX XXX XXX',
        counterText: '',
      ),
    );
  }
}

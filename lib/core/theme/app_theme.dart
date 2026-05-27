import 'package:flutter/material.dart';

// ─── Custom colors (ThemeExtension) ───────────────────────────
// Цвета которых нет в стандартном ColorScheme — glow, card, blobs и т.д.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.sub,
    required this.hint,
    required this.glow,
    required this.deep,
    required this.card,
    required this.inputBg,
    required this.border,
    required this.btnTop,
    required this.btnBot,
    required this.btnSec,
    required this.btnSecBorder,
    required this.bgGradient,
    required this.blob1,
    required this.blob2,
    required this.blob3,
  });

  final Color sub, hint, glow, deep, card, inputBg, border;
  final Color btnTop, btnBot, btnSec, btnSecBorder;
  final List<Color> bgGradient, blob1, blob2, blob3;

  @override
  AppColors copyWith({
    Color? sub, Color? hint, Color? glow, Color? deep,
    Color? card, Color? inputBg, Color? border,
    Color? btnTop, Color? btnBot, Color? btnSec, Color? btnSecBorder,
    List<Color>? bgGradient, List<Color>? blob1, List<Color>? blob2, List<Color>? blob3,
  }) => AppColors(
    sub:          sub          ?? this.sub,
    hint:         hint         ?? this.hint,
    glow:         glow         ?? this.glow,
    deep:         deep         ?? this.deep,
    card:         card         ?? this.card,
    inputBg:      inputBg      ?? this.inputBg,
    border:       border       ?? this.border,
    btnTop:       btnTop       ?? this.btnTop,
    btnBot:       btnBot       ?? this.btnBot,
    btnSec:       btnSec       ?? this.btnSec,
    btnSecBorder: btnSecBorder ?? this.btnSecBorder,
    bgGradient:   bgGradient   ?? this.bgGradient,
    blob1:        blob1        ?? this.blob1,
    blob2:        blob2        ?? this.blob2,
    blob3:        blob3        ?? this.blob3,
  );

  // lerp нужен чтобы MaterialApp плавно анимировал между темами
  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    List<Color> lc(List<Color> a, List<Color> b) =>
        [for (int i = 0; i < a.length; i++) Color.lerp(a[i], b[i], t)!];
    return AppColors(
      sub:          c(sub,          other.sub),
      hint:         c(hint,         other.hint),
      glow:         c(glow,         other.glow),
      deep:         c(deep,         other.deep),
      card:         c(card,         other.card),
      inputBg:      c(inputBg,      other.inputBg),
      border:       c(border,       other.border),
      btnTop:       c(btnTop,       other.btnTop),
      btnBot:       c(btnBot,       other.btnBot),
      btnSec:       c(btnSec,       other.btnSec),
      btnSecBorder: c(btnSecBorder, other.btnSecBorder),
      bgGradient:   lc(bgGradient,  other.bgGradient),
      blob1:        lc(blob1,       other.blob1),
      blob2:        lc(blob2,       other.blob2),
      blob3:        lc(blob3,       other.blob3),
    );
  }
}

// ─── Palettes (из дизайна mobile-login-app.jsx) ────────────────
const _darkColors = AppColors(
  sub:          Color(0x8CF0F7EC),
  hint:         Color(0x59F0F7EC),
  glow:         Color(0xFF7DD968),
  deep:         Color(0xFF1A6B3F),
  card:         Color(0x0FFFFFFF),
  inputBg:      Color(0x14FFFFFF),
  border:       Color(0x1FFFFFFF),
  btnTop:       Color(0xFF268A53),
  btnBot:       Color(0xFF0E3826),
  btnSec:       Color(0x12FFFFFF),
  btnSecBorder: Color(0x24FFFFFF),
  bgGradient:   [Color(0xFF090E0B), Color(0xFF0A2A1B), Color(0xFF090C14)],
  blob1:        [Color(0x384FA63A), Colors.transparent],
  blob2:        [Color(0x297DD968), Colors.transparent],
  blob3:        [Color(0x990E3826), Colors.transparent],
);

const _lightColors = AppColors(
  sub:          Color(0x8C0E1A10),
  hint:         Color(0x610E1A10),
  glow:         Color(0xFF4FA63A),
  deep:         Color(0xFF0E3826),
  card:         Color(0xD0FFFFFF),
  inputBg:      Color(0xFFFFFFFF),
  border:       Color(0x2E1A6B3F),
  btnTop:       Color(0xFF268A53),
  btnBot:       Color(0xFF134B33),
  btnSec:       Color(0x0D0E1A10),
  btnSecBorder: Color(0x381A6B3F),
  bgGradient:   [Color(0xFFEFF4EF), Color(0xFFD6EDD9), Color(0xFFE8F0F8)],
  blob1:        [Color(0x2E268A53), Colors.transparent],
  blob2:        [Color(0x1E4FA63A), Colors.transparent],
  blob3:        [Color(0x59A5E58A), Colors.transparent],
);

// ─── AppTheme ──────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary:          Color(0xFF4FA63A),
      onPrimary:        Colors.white,
      surface:          Color(0xFF090E0B),
      onSurface:        Color(0xFFF0F7EC),
      surfaceContainer: Color(0x0FFFFFFF),
      outline:          Color(0x1FFFFFFF),
    ),
    scaffoldBackgroundColor: const Color(0xFF090E0B),
    extensions: const [_darkColors],
  );

  static ThemeData light() => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary:          Color(0xFF268A53),
      onPrimary:        Colors.white,
      surface:          Color(0xFFEFF4EF),
      onSurface:        Color(0xFF0E1A10),
      surfaceContainer: Color(0xD0FFFFFF),
      outline:          Color(0x2E1A6B3F),
    ),
    scaffoldBackgroundColor: const Color(0xFFEFF4EF),
    extensions: const [_lightColors],
  );
}

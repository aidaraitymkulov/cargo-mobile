import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:cargo_mobile/app.dart';

void main() async {
  // Держим нативный сплэш пока не завершится проверка токена
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  // await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

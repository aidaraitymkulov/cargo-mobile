import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cargo_mobile/core/router/app_router.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AdesExpress',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
    );
  }
}

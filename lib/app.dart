import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cargo_mobile/core/router/app_router.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';
import 'package:cargo_mobile/features/auth/domain/auth_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // Запускаем восстановление сессии после первого frame.
    // Аналог useEffect(() => { checkAuth() }, []) в React.
    // addPostFrameCallback нужен потому что initState вызывается ДО того
    // как виджет встроен в дерево — ref ещё не готов к side-effects.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).tryRestoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AdesExpress',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      color: const Color(0xFF004B3B),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';
import 'package:cargo_mobile/features/auth/domain/auth_provider.dart';
import 'package:cargo_mobile/features/auth/presentation/login_screen.dart';
import 'package:cargo_mobile/features/auth/presentation/register_screen.dart';
import 'package:cargo_mobile/features/auth/presentation/confirm_email_screen.dart';
import 'package:cargo_mobile/features/auth/presentation/forgot_password_screen.dart';

Page<void> _fadePage(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );

Page<void> _slidePage(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, animation, _, child) => SlideTransition(
        position: Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = ref.watch(_authListenableProvider);

  return GoRouter(
    refreshListenable: authListenable,
    redirect: (context, state) {
      final status = authListenable.authStatus;
      final location = state.matchedLocation;

      // Пока идёт проверка токена — не редиректим никуда (нативный сплэш держит экран)
      if (status == AuthStatus.initializing) return null;

      final isAuthRoute = location.startsWith('/auth');

      // Не авторизован и пытается зайти не на auth-роут → на логин
      if (status == AuthStatus.unauthenticated && !isAuthRoute) {
        return '/auth/login';
      }

      // Авторизован и пытается зайти на auth-роут → на главную
      if (status == AuthStatus.authenticated && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/login',
        pageBuilder: (_, state) => _fadePage(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/auth/register',
        pageBuilder: (_, state) => _slidePage(state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/auth/confirm-email',
        pageBuilder: (context, state) {
          // login передаётся через extra как Map<String, dynamic>
          final extra = state.extra as Map<String, dynamic>?;
          final login = extra?['login'] as String? ?? '';
          return _slidePage(state, ConfirmEmailScreen(login: login));
        },
      ),
      GoRoute(
        path: '/auth/forgot-password',
        pageBuilder: (_, state) =>
            _slidePage(state, const ForgotPasswordScreen()),
      ),
      ShellRoute(
        builder: (_, _, child) => Container(
          decoration: AppTheme.backgroundDecoration,
          child: child,
        ),
        routes: [
              GoRoute(
            path: '/',
            pageBuilder: (_, state) => _fadePage(state, const _StubScreen()),
          ),
          GoRoute(
            path: '/products',
            pageBuilder: (_, state) => _fadePage(state, const _StubScreen()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (_, state) => _slidePage(state, const _StubScreen()),
              ),
            ],
          ),
          GoRoute(
            path: '/orders',
            pageBuilder: (_, state) => _fadePage(state, const _StubScreen()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (_, state) => _slidePage(state, const _StubScreen()),
              ),
            ],
          ),
          GoRoute(
            path: '/news',
            pageBuilder: (_, state) => _fadePage(state, const _StubScreen()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (_, state) => _slidePage(state, const _StubScreen()),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, state) => _fadePage(state, const _StubScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/chat',
        pageBuilder: (_, state) => _slidePage(state, const _StubScreen()),
      ),
    ],
  );
});

/// Заглушка для ещё не реализованных экранов
class _StubScreen extends StatelessWidget {
  const _StubScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF004B3B),
      body: SizedBox.shrink(),
    );
  }
}

// --- Auth Listenable ---
// Мост между Riverpod (authProvider) и GoRouter (refreshListenable).
// GoRouter не умеет напрямую слушать Riverpod провайдеры —
// поэтому делаем ChangeNotifier-обёртку.
// Аналогия: это как EventEmitter который GoRouter подписывает через ChangeNotifier.

final _authListenableProvider = Provider<_AuthListenable>((ref) {
  final notifier = _AuthListenable();
  ref.listen(authProvider, (_, next) {
    notifier.updateStatus(next.status);
  });
  return notifier;
});

class _AuthListenable extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initializing;

  AuthStatus get authStatus => _status;

  void updateStatus(AuthStatus status) {
    if (_status == status) return;
    _status = status;
    notifyListeners();
  }
}

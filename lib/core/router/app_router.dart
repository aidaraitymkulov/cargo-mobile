import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cargo_mobile/features/auth/domain/auth_provider.dart';
import 'package:cargo_mobile/features/auth/presentation/login_screen.dart';
import 'package:cargo_mobile/features/auth/presentation/register_screen.dart';
import 'package:cargo_mobile/features/auth/presentation/confirm_email_screen.dart';
import 'package:cargo_mobile/features/auth/presentation/forgot_password_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = ref.watch(_authListenableProvider);

  return GoRouter(
    refreshListenable: authListenable,
    redirect: (context, state) {
      final isLoggedIn = authListenable.isLoggedIn;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/confirm-email',
        builder: (_, __) => const ConfirmEmailScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (_, _, child) => Scaffold(body: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Placeholder(),
          ),
          GoRoute(
            path: '/products',
            builder: (_, _) => const Placeholder(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => Placeholder(
                  key: ValueKey(state.pathParameters['id']),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/orders',
            builder: (_, _) => const Placeholder(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => Placeholder(
                  key: ValueKey(state.pathParameters['id']),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/news',
            builder: (_, _) => const Placeholder(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => Placeholder(
                  key: ValueKey(state.pathParameters['id']),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (_, _) => const Placeholder(),
          ),
        ],
      ),
      GoRoute(
        path: '/chat',
        builder: (_, _) => const Placeholder(),
      ),
    ],
  );
});

final _authListenableProvider = Provider<_AuthListenable>((ref) {
  final notifier = _AuthListenable();
  ref.listen(authProvider, (_, next) {
    notifier.setLoggedIn(next.isLoggedIn);
  });
  return notifier;
});

class _AuthListenable extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void setLoggedIn(bool value) {
    if (_isLoggedIn == value) return;
    _isLoggedIn = value;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(_authListenableProvider);

  return GoRouter(
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isLoggedIn = authNotifier.isLoggedIn;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/login',
        builder: (_, _) => const Placeholder(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (_, _) => const Placeholder(),
      ),
      GoRoute(
        path: '/auth/confirm-email',
        builder: (_, _) => const Placeholder(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (_, _) => const Placeholder(),
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
  return _AuthListenable();
});

class _AuthListenable extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }
}

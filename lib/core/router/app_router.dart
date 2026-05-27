import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cargo_mobile/features/auth/domain/auth_provider.dart';
import 'package:cargo_mobile/features/auth/presentation/auth_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    redirect: (context, state) {
      final isLoggedIn  = notifier.isLoggedIn;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/login',
        builder: (_, __) => const AuthScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (_, __) => const Placeholder(),
      ),
      GoRoute(
        path: '/auth/confirm-email',
        builder: (_, __) => const Placeholder(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (_, __) => const Placeholder(),
      ),
      ShellRoute(
        builder: (_, __, child) => Scaffold(body: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Placeholder(),
          ),
          GoRoute(
            path: '/products',
            builder: (_, __) => const Placeholder(),
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
            builder: (_, __) => const Placeholder(),
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
            builder: (_, __) => const Placeholder(),
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
            builder: (_, __) => const Placeholder(),
          ),
        ],
      ),
      GoRoute(
        path: '/chat',
        builder: (_, __) => const Placeholder(),
      ),
    ],
  );
});

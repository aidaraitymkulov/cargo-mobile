import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cargo_mobile/core/shell/main_shell.dart';
import 'package:cargo_mobile/features/auth/domain/auth_provider.dart';
import 'package:cargo_mobile/features/auth/presentation/auth_screen.dart';
import 'package:cargo_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:cargo_mobile/features/calls/presentation/calls_screen.dart';
import 'package:cargo_mobile/features/chat/presentation/chat_screen.dart';
import 'package:cargo_mobile/features/news/presentation/news_screen.dart';
import 'package:cargo_mobile/features/profile/presentation/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    redirect: (context, state) {
      if (notifier.isLoading) return null;

      final isLoggedIn = notifier.isLoggedIn;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/auth/login',          builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/auth/register',        builder: (_, __) => const Placeholder()),
      GoRoute(path: '/auth/confirm-email',   builder: (_, __) => const Placeholder()),
      GoRoute(path: '/auth/forgot-password', builder: (_, __) => const Placeholder()),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/calls', builder: (_, __) => const CallsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/news',
              builder: (_, __) => const NewsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => Placeholder(
                    key: ValueKey(state.pathParameters['id']),
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
});

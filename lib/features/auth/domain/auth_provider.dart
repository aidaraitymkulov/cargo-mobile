import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cargo_mobile/core/api/auth_api.dart';
import 'package:cargo_mobile/core/api/branch_api.dart';
import 'package:cargo_mobile/core/api/dio_client.dart';
import 'package:cargo_mobile/core/storage/token_storage.dart';
import 'package:cargo_mobile/features/auth/data/auth_repository.dart';
import 'package:cargo_mobile/models/branch.dart';

// ─── Infrastructure providers ─────────────────────────────────
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(const FlutterSecureStorage());
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref.read(tokenStorageProvider));
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.read(dioClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(authApiProvider),
    ref.read(tokenStorageProvider),
  );
});

final branchApiProvider = Provider<BranchApi>((ref) {
  return BranchApi(ref.read(dioClientProvider));
});

final branchesProvider = FutureProvider<List<Branch>>((ref) {
  return ref.read(branchApiProvider).getBranches();
});

// ─── Auth state ────────────────────────────────────────────────
class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return ref.read(authRepositoryProvider).hasValidSession();
  }

  Future<void> login(String login, String password) async {
    await ref.read(authRepositoryProvider).login(login, password);
    state = const AsyncData(true);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(false);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

// ─── GoRouter refresh listenable ──────────────────────────────
// Слушает authProvider и уведомляет GoRouter при изменении
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<bool>>(authProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  bool get isLoading => _ref.read(authProvider).isLoading;

  bool get isLoggedIn => _ref.read(authProvider).maybeWhen(
        data: (v) => v,
        orElse: () => false,
      );
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

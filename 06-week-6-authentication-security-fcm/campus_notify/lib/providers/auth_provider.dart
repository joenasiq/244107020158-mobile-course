import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/token_store.dart';

/// Provider untuk TokenStore (penyimpanan aman token via flutter_secure_storage).
final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

/// Provider untuk AuthRepository (mock auth, siap diganti Firebase Auth).
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

/// Provider status autentikasi pengguna.
///
/// `retry: null` mematikan auto-retry bawaan Riverpod 3 agar error
/// langsung ditampilkan ke UI (tidak spinner 38 detik).
final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
  retry: (retryCount, error) => null,
);

/// Notifier autentikasi: login, logout, dan pengecekan sesi.
class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null;
  }

  /// Login dengan email + password.
  /// Simpan token ke secure storage bila berhasil.
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .save(access: session.access, refresh: session.refresh);
      return true;
    });
  }

  /// Logout: hapus semua token, kembalikan state ke false.
  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    ref.invalidateSelf();
  }
}

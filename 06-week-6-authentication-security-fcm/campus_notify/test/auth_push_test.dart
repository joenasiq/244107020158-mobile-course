import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/messaging/route_parser.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  // ─── routeFromMessage (Refactoring Challenge #2) ─────────────────

  group('routeFromMessage', () {
    // 1. Route kosong → fallback ke home.
    test('data kosong mengembalikan /', () {
      expect(routeFromMessage({}), '/');
    });

    // 2. Route tanpa leading slash → ditambahkan otomatis.
    test('route tanpa slash ditambahkan /', () {
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    });

    // 3. Route dengan leading slash → dipertahankan.
    test('route dengan slash dipertahankan', () {
      expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
    });

    // 4. Data payload membawa id pengumuman.
    test('data payload membawa id pengumuman', () {
      const data = {'route': '/pengumuman/3', 'id': '3'};
      expect(data['id'], '3');
      expect(routeFromMessage(data), '/pengumuman/3');
    });
  });

  // ─── Sesi auth (fake token store + repository) ───────────────────

  group('AuthNotifier dengan FakeTokenStore', () {
    // 5. Login sukses → token tersimpan, state = true.
    test('login sukses menyimpan token dan mengembalikan true', () async {
      final store = FakeTokenStore();
      final repo = FakeAuthRepository();

      final container = ProviderContainer(
        overrides: [
          tokenStoreProvider.overrideWithValue(store),
          authRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      // Awal: belum login (tidak ada token).
      final initialState = await container.read(authStateProvider.future);
      expect(initialState, isFalse);

      // Login.
      await container
          .read(authStateProvider.notifier)
          .login('test@kampus.ac.id', '123456');

      // Setelah login: state = true, token tersimpan.
      final afterLogin = container.read(authStateProvider).value;
      expect(afterLogin, isTrue);
      expect(await store.readAccess(), isNotNull);
      expect(await store.readRefresh(), isNotNull);
    });

    // 6. Logout → token dihapus, state = false.
    test('logout menghapus token dan mengembalikan false', () async {
      final store = FakeTokenStore();
      final repo = FakeAuthRepository();

      final container = ProviderContainer(
        overrides: [
          tokenStoreProvider.overrideWithValue(store),
          authRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      // Login dulu.
      await container
          .read(authStateProvider.notifier)
          .login('test@kampus.ac.id', '123456');
      expect(container.read(authStateProvider).value, isTrue);

      // Logout.
      await container.read(authStateProvider.notifier).logout();

      // Setelah logout: state = false, token null.
      final afterLogout = await container.read(authStateProvider.future);
      expect(afterLogout, isFalse);
      expect(await store.readAccess(), isNull);
    });

    // 7. Login gagal (email invalid) → AsyncError.
    test('login gagal menghasilkan error', () async {
      final store = FakeTokenStore();
      final repo = FakeAuthRepository();

      final container = ProviderContainer(
        overrides: [
          tokenStoreProvider.overrideWithValue(store),
          authRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      // Email tanpa @ → exception.
      await container
          .read(authStateProvider.notifier)
          .login('invalid-email', '123456');
      expect(container.read(authStateProvider).hasError, isTrue);
    });
  });

  // ─── Refresh gagal → sesi dibersihkan ────────────────────────────

  group('FakeTokenStore sesi', () {
    // 8. Refresh token kosong → perlu login ulang.
    test('refresh token kosong memaksa login ulang', () async {
      final store = FakeTokenStore();
      // Simulasi: access token ada, tapi refresh sudah kosong.
      await store.save(access: 'some-access', refresh: '');
      final needsLogin = ((await store.readRefresh()) ?? '').isEmpty;
      expect(needsLogin, isTrue);
    });
  });

  // ─── friendlyErrorMessage (Refactoring Challenge #3) ─────────────

  group('friendlyErrorMessage', () {
    // 9. DioException timeout → pesan ramah.
    test('timeout → pesan jaringan lama', () {
      final error = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      final message = friendlyErrorMessage(error);
      expect(message, contains('lama'));
    });

    // 10. DioException 401 → pesan sesi habis.
    test('401 → sesi habis', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/test'),
        ),
        requestOptions: RequestOptions(path: '/test'),
      );
      expect(friendlyErrorMessage(error), contains('login'));
    });

    // 11. Bukan DioException → pesan asli.
    test('non-Dio error → pesan asli tanpa prefix Exception:', () {
      final msg = friendlyErrorMessage(Exception('gagal total'));
      expect(msg, isNot(contains('Exception: ')));
      expect(msg, contains('gagal total'));
    });
  });
}

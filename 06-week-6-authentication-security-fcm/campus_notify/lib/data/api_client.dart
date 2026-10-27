// HTTP client dengan interceptor auto-refresh token.
//
// Alur: setiap request dipasangi header `Authorization: Bearer ...`.
// Bila server menjawab 401 (token kedaluwarsa), interceptor mencoba
// refresh **satu kali**. Bila refresh juga gagal, semua token dihapus
// → user dipaksa login ulang.
import 'package:dio/dio.dart';

import 'auth_repository.dart';
import 'token_store.dart';

/// Bangun Dio instance dengan interceptor auth.
Dio buildApiClient(TokenStore store, AuthRepository auth) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example-campus-api.test'));

  dio.interceptors.add(
    InterceptorsWrapper(
      // Pasang Bearer token di setiap request.
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      // 401 → coba refresh sekali, lalu ulangi request.
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final refresh = await store.readRefresh();
          if (refresh == null) return handler.next(e);
          try {
            final renewed = await auth.refresh(refresh);
            await store.save(access: renewed, refresh: refresh);
            final retry = await dio.fetch(
              e.requestOptions..headers['Authorization'] = 'Bearer $renewed',
            );
            return handler.resolve(retry);
          } catch (_) {
            // Refresh ikut mati → paksa login ulang.
            await store.clear();
          }
        }
        handler.next(e);
      },
    ),
  );

  return dio;
}

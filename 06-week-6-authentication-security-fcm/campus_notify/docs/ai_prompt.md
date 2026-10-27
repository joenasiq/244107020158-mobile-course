# Prompt AI — Week 6: Authentication, Security & FCM

## Konteks
Saya mahasiswa D4 Teknik Informatika (244107020158 - TI-3D) mengerjakan
portofolio Pemrograman Mobile minggu ke-6. Topik: authentication, keamanan
token, dan Firebase Cloud Messaging (push notification).

## Prompt Utama
> Lengkapi project Flutter **campus_notify** sesuai codelab minggu 6.
> Deliverables:
> - Mock auth (login/logout) dengan guard route GoRouter
> - Token di `flutter_secure_storage` (TIDAK SharedPreferences)
> - Dio interceptor auto-refresh 401 + logout jika refresh gagal
> - Firebase FCM: permission, register/onRegistered (v17), subscribe topic
> - Notifikasi + data payload pada 3 app state (foreground/background/terminated)
> - Deep link ke `/pengumuman/:id`
> - `routeFromMessage` pure function (Refactoring #2)
> - Route constants file (Refactoring #1)
> - `api_errors.dart` DioException→friendly message (Refactoring #3)
> - Minimal 2 passing tests
> - `docs/`, `README.md`, `screenshots/`
>
> Gaya: komentar Indonesia, Riverpod Notifier/AsyncNotifier saja (bukan
> StateProvider/StateNotifier), GoRouter, repository pattern, `const`
> constructors, `colorSchemeSeed: Colors.indigo` + `useMaterial3`,
> `retry: (retryCount, error) => null` pada semua async provider.

## Prompt Tambahan
- Gunakan `register()` + `onRegistered` (firebase_messaging 17 mengganti
  `getToken`/`onTokenRefresh` yang sudah deprecated).
- `flutter_local_notifications 22.3.2`: `initialize()` pakai named
  `settings:`, `show()` semua parameter named.
- Screenshot widget test tanpa Firebase (fake repository, pure UI test).
- Kode FCM production-ready (bukan mock) karena akan dicoba di HP Android.

# Output AI — Week 6: Authentication, Security & FCM

> **Catatan**: File ini berisi rangkuman output AI.
> Paste screenshot percakapan AI Anda sendiri di bawah bagian "Bukti Chat".

## Rangkuman Output

### File yang Dibuat / Diedit

| File | Keterangan |
| --- | --- |
| `lib/routes.dart` | Konstanta rute (Refactoring #1) |
| `lib/data/api_errors.dart` | `friendlyErrorMessage()` (Refactoring #3) |
| `lib/messaging/route_parser.dart` | `routeFromMessage()` pure function (Refactoring #2) |
| `lib/messaging/push_service.dart` | FCM + local notification service |
| `lib/router.dart` | GoRouter + redirect guard auth |
| `lib/main.dart` | Entry point dengan Firebase init + FCM |
| `lib/providers/auth_provider.dart` | AuthNotifier + `retry: null` |
| `lib/data/auth_repository.dart` | Mock auth (login + refresh) |
| `lib/data/token_store.dart` | Secure storage wrapper |
| `lib/data/api_client.dart` | Dio + interceptor 401 auto-refresh |
| `lib/pages/home_page.dart` | Home dengan daftar pengumuman |
| `lib/pages/announcement_page.dart` | Detail pengumuman (deep link target) |
| `lib/pages/login_page.dart` | Form login (tidak berubah) |
| `test/fakes.dart` | FakeTokenStore + FakeAuthRepository |
| `test/auth_push_test.dart` | 11 unit tests |
| `test/screenshot_test.dart` | 4 widget screenshot tests |

### Keputusan Arsitektur
1. **`UncontrolledProviderScope`** + `ProviderContainer` di `main()` — agar
   status auth bisa dibaca _sebelum_ GoRouter dibuat (redirect berjalan di
   luar widget tree).
2. **`register()` + `onRegistered`** menggantikan `getToken()` + `onTokenRefresh`
   yang deprecated di firebase_messaging 17.0.0.
3. **`flutter_local_notifications 22.3.2`** mengubah `initialize()` dan `show()`
   ke named parameters (`settings:`, `id:`, `title:`, `body:`,
   `notificationDetails:`, `payload:`).

## Bukti Chat

> _Paste screenshot percakapan AI (ChatGPT / Claude / Gemini) di sini._

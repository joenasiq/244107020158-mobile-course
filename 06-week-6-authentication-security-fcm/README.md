# WEEK 6: Authentication, Security & Firebase Cloud Messaging

---

## Praktikum

![Login](../screenshots/login_page.png)
![Home](../screenshots/home_page.png)
![Detail](../screenshots/announcement_detail.png)
![Deep Link](../screenshots/announcement_deeplink.png)

---

## AI Challenge

- Apakah background handler berupa fungsi top-level dengan `@pragma('vm:entry-point')`?

  `firebaseMessagingBackgroundHandler` dideklarasikan sebagai fungsi top-level di `lib/messaging/push_service.dart` dengan anotasi `@pragma('vm:entry-point')`.

- Apakah `onTokenRefresh` benar-benar mengirim token baru ke backend, bukan hanya dicetak ke log?

  Pada `firebase_messaging 17.0.0`, API `onTokenRefresh` diganti oleh `onRegistered`. Di `push_service.dart` `initFcmToken()` menerima callback `onToken` yang dipanggil setiap kali token baru diterima dari stream `onRegistered`

- Apakah foreground memakai local notification manual? (tanpa ini banner tidak muncul saat aplikasi terbuka).

  `listenForeground()` di `push_service.dart` mendengarkan `FirebaseMessaging.onMessage`, lalu menampilkan banner manual via `FlutterLocalNotificationsPlugin.show()` dengan channel `pengumuman`

- Apakah klik dari ketiga state (foreground/background/terminated) masuk ke rute yang benar? Buktikan dengan tabel pengujian

  `push_service.dart` menangani 3 state:
  - **Foreground**: `listenForeground()` → `_local.show(payload: route)`
  - **Background**: `onMessageOpenedApp` → `go(routeFromMessage(data))`
  - **Terminated**: `handleTerminated()` + `getInitialMessage()` → `go(routeFromMessage(data))`

- Apakah token/secret tidak di-hardcode dan tidak di-log penuh? Perbaiki bila AI melanggarnya
  - Token hanya di `flutter_secure_storage` — `token_store.dart` membungkus
    `FlutterSecureStorage` (Android Keystore / iOS Keychain). Tidak ada token di
    SharedPreferences, hardcode di Dart, atau query URL.
  - Log token dipotong — `main.dart` hanya mencetak 12 karakter
    pertama: `token.substring(0, 12)` + `...`. Token penuh tidak pernah muncul
    di console.
  - Mock auth token (`mock-access-for-...`) hanya untuk simulasi —
    `auth_repository.dart` menandai jelas bahwa ini titik ganti ke Firebase Auth.

---

## Testing

![Test](../screenshots/test.png)

---

## Refleksi

- Mengapa token harus disimpan di flutter_secure_storage, bukan SharedPreferences?

  SharedPreferences menyimpan data dalam file XML plain text yang bisa dibaca siapa saja dengan akses root atau backup. flutter_secure_storage menggunakan Android Keystore untuk mengenkripsi data.

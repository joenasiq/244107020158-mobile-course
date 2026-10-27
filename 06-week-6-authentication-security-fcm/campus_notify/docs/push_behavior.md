# Perilaku Push Notification pada 3 App State

## Ringkasan

| App State | Penampilan Notifikasi | Navigasi Saat Klik | Handler |
| --- | --- | --- | --- |
| **Foreground** | Manual via `flutter_local_notifications` | `pendingDeepLink` → router | `FirebaseMessaging.onMessage` |
| **Background** | Otomatis oleh sistem | `routeFromMessage(data)` | `FirebaseMessaging.onMessageOpenedApp` |
| **Terminated** | Otomatis oleh sistem | `routeFromMessage(data)` | `FirebaseMessaging.instance.getInitialMessage()` |

## Detail

### 1. Foreground
- Saat aplikasi terbuka, Android **tidak** menampilkan banner otomatis.
- `onMessage` stream menerima `RemoteMessage`, lalu:
  - Tampilkan banner manual via `FlutterLocalNotificationsPlugin.show()`.
  - Payload berisi rute deep link (misal `/pengumuman/3`).
  - Klik banner → `onDidReceiveNotificationResponse` → simpan ke `pendingDeepLink`.

### 2. Background
- Aplikasi diminimalkan tapi proses masih hidup.
- Sistem menampilkan banner otomatis dari field `notification` payload.
- Klik banner → `onMessageOpenedApp` stream.
- App memanggil `routeFromMessage(message.data)` → `router.go(route)`.

### 3. Terminated (Cold Start)
- Aplikasi benar-benar mati (tidak ada proses).
- Klik banner → sistem me-launch ulang app.
- Setelah `Firebase.initializeApp()`, panggil `getInitialMessage()`.
- Bila non-null → `routeFromMessage(data)` → navigasi ke rute deep link.
- `getInitialMessage()` hanya bisa dikonsumsi **satu kali** — panggilan
  berikutnya mengembalikan `null`.

## Background Handler (Isolate Terpisah)
- `firebaseMessagingBackgroundHandler` berjalan di isolate baru.
- **WAJIB** top-level function, bukan method kelas.
- Tidak bisa akses `BuildContext`, `WidgetRef`, atau state Riverpod.
- Hanya untuk pekerjaan ringan (logging, simpan ke DB).

## Token Lifecycle (firebase_messaging 17)
```
register()  →  onRegistered (Stream<String>)  →  kirim ke backend
```
- `getToken()` dan `onTokenRefresh` sudah **deprecated** di v17.
- `register()` memulai proses registrasi.
- `onRegistered` mengemisi token setiap kali registrasi berhasil atau token dirotasi.
- Listener `onRegistered` HARUS dipasang **sebelum** `register()` agar token pertama tidak terlewat.

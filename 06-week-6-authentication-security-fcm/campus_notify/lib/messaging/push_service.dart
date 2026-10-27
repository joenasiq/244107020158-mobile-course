import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'route_parser.dart';

/// ===================================================================
/// Push notification service — Firebase Cloud Messaging + local
/// notifications untuk foreground.
///
/// Lifecycle:
///  1. requestPermission    → izin notifikasi (wajib Android 13+ / iOS)
///  2. initLocalNotif       → kanal local notification (foreground banner)
///  3. initFcmToken         → register + onRegistered, kirim ke backend
///  4. listenForeground     → onMessage: tampilkan manual via local notif
///  5. handleClickFromBg    → onMessageOpenedApp: navigasi deep link
///  6. handleTerminated     → getInitialMessage: buka rute saat cold start
///  7. subscribeToTopic     → langganan broadcast "pengumuman-kampus"
/// ===================================================================

final _local = FlutterLocalNotificationsPlugin();

/// Deep link tertunda dari klik banner local notification (foreground).
String? pendingDeepLink;

// ─── 1. Izin notifikasi ────────────────────────────────────────────

/// Minta izin notifikasi. Kembalikan `true` bila diizinkan.
Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

// ─── 2. Local notification (foreground) ────────────────────────────

/// Inisialisasi kanal dan plugin local notification.
Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      // Klik banner foreground → simpan rute, akan diproses router.
      pendingDeepLink = response.payload;
    },
  );

  // Kanal wajib untuk Android 8+ (notification channel).
  const channel = AndroidNotificationChannel(
    'pengumuman',
    'Pengumuman Kampus',
    description: 'Notifikasi pengumuman akademik dan kegiatan kampus',
    importance: Importance.high,
  );
  await _local
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

// ─── 3. Token lifecycle ────────────────────────────────────────────

/// Daftarkan device ke FCM dan pantau perubahan token.
///
/// firebase_messaging 17 mengganti `getToken` + `onTokenRefresh` (deprecated)
/// dengan `register()` + `onRegistered`. Stream `onRegistered` mengemisi
/// token setiap kali registrasi berhasil atau token dirotasi.
///
/// [onToken] dipanggil setiap kali token baru diterima.
/// Pada production, callback ini mengirim POST /devices ke backend.
Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  // Pasang listener SEBELUM register() agar token pertama tidak terlewat.
  FirebaseMessaging.instance.onRegistered.listen(onToken);

  // Mulai proses registrasi (async, token dikirim lewat onRegistered).
  await FirebaseMessaging.instance.register();
}

// ─── 4. Foreground handler ─────────────────────────────────────────

/// Dengarkan pesan saat aplikasi terbuka (foreground).
///
/// Sistem Android **tidak** menampilkan banner otomatis saat foreground,
/// jadi kita tampilkan manual via local notification.
void listenForeground(void Function(String route) go) {
  FirebaseMessaging.onMessage.listen((message) async {
    final route = routeFromMessage(message.data);

    const androidDetails = AndroidNotificationDetails(
      'pengumuman',
      'Pengumuman Kampus',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: route,
    );
  });

  // Klik banner saat aplikasi sudah berjalan (background → foreground).
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    go(routeFromMessage(message.data));
  });
}

// ─── 5–6. Terminated / cold start ─────────────────────────────────

/// Periksa apakah aplikasi dibuka dari klik notifikasi saat terminated.
Future<void> handleTerminated(void Function(String route) go) async {
  // getInitialMessage hanya non-null bila user klik notifikasi saat
  // aplikasi benar-benar mati (terminated / cold start).
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) go(routeFromMessage(initial.data));

  // Deep link dari klik banner local notification (foreground).
  if (pendingDeepLink != null) {
    go(pendingDeepLink!);
    pendingDeepLink = null;
  }
}

// ─── 7. Topic messaging ───────────────────────────────────────────

/// Langganan topik broadcast kampus.
Future<void> subscribeToTopic(String topic) =>
    FirebaseMessaging.instance.subscribeToTopic(topic);

/// Berhenti langganan topik.
Future<void> unsubscribeFromTopic(String topic) =>
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);

// ─── Background handler (top-level, bukan method kelas) ───────────

/// Handler background WAJIB top-level karena berjalan di isolate terpisah.
/// Jangan akses BuildContext / Riverpod di sini.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Tugas: catat / simpan ringan saja.
  // Navigasi dilakukan saat user klik banner (onMessageOpenedApp).
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'providers/auth_provider.dart';
import 'router.dart';

/// Background handler WAJIB didaftarkan di top-level (sebelum runApp).
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Firebase (wajib sebelum pakai FCM).
  await Firebase.initializeApp();

  // 2. Daftarkan background handler (top-level, bukan method kelas).
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 3. Inisialisasi local notification (kanal + plugin).
  await initLocalNotifications();

  // 4. Buat container Riverpod.
  final container = ProviderContainer();

  // 5. Tunggu state auth pertama kali selesai (baca token dari storage lokal).
  await container.read(authStateProvider.future);

  // 6. Buat router + navigator key untuk deep link dari notifikasi.
  final navigatorKey = GlobalKey<NavigatorState>();
  final router = createAppRouter(container, navigatorKey: navigatorKey);

  // 7. Render UI SEGERA agar layar tidak membeku / lemot saat startup
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: CampusNotifyApp(router: router),
    ),
  );

  // 8. Inisialisasi FCM & network calls di background setelah UI tampil
  _initPushNotifications(router);
}

/// Inisialisasi background untuk FCM agar tidak memblokir render UI awal.
Future<void> _initPushNotifications(GoRouter router) async {
  try {
    // Minta izin notifikasi (Android 13+ / iOS).
    await requestNotificationPermission();

    // FCM token lifecycle: ambil, kirim ke backend, pantau refresh.
    await initFcmToken(
      onToken: (token) async {
        debugPrint('FCM token: ${token.substring(0, 12)}...');
      },
    );

    // Langganan topik broadcast kampus.
    await subscribeToTopic('pengumuman-kampus');

    // Foreground listener + handler klik notifikasi.
    listenForeground((route) => router.go(route));

    // Cek apakah dibuka dari klik notifikasi saat terminated.
    await handleTerminated((route) => router.go(route));
  } catch (e) {
    debugPrint('Inisialisasi push notification ditunda/gagal: $e');
  }
}

/// Aplikasi utama Campus Notify.
class CampusNotifyApp extends ConsumerWidget {
  final GoRouter router;

  const CampusNotifyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pantau perubahan auth untuk memicu redirect GoRouter.
    ref.watch(authStateProvider);

    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

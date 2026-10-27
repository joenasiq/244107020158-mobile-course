import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

/// Buat GoRouter dengan redirect guard berbasis status autentikasi.
///
/// [container] dipakai untuk membaca state auth di luar widget tree
/// (redirect berjalan sebelum build). [navigatorKey] opsional untuk
/// navigasi dari push notification (di luar BuildContext).
GoRouter createAppRouter(
  ProviderContainer container, {
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    redirect: (context, state) {
      final loggedIn = container.read(authStateProvider).value ?? false;
      final goingLogin = state.matchedLocation == AppRoutes.login;

      // Belum login dan bukan ke halaman login → paksa ke login.
      if (!loggedIn && !goingLogin) return AppRoutes.login;
      // Sudah login tapi ke halaman login → arahkan ke home.
      if (loggedIn && goingLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, _) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.announcement,
        builder: (_, state) => AnnouncementPage(
          id: state.pathParameters['id'] ?? '',
        ),
      ),
    ],
  );
}

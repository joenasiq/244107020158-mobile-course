import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import 'package:campus_notify/pages/announcement_page.dart';
import 'package:campus_notify/pages/home_page.dart';
import 'package:campus_notify/pages/login_page.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:campus_notify/routes.dart';

import 'fakes.dart';

/// Pembungkus frame yang ingin di-capture.
class ScreenshotBoundary extends SingleChildRenderObjectWidget {
  const ScreenshotBoundary({super.key, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderRepaintBoundary();
  }
}

/// Bangun aplikasi test tanpa Firebase (widget test murni).
Widget buildScreenshotApp({
  bool loggedIn = false,
  String initialLocation = AppRoutes.login,
}) {
  final store = FakeTokenStore();
  final repo = FakeAuthRepository();

  // Simulasi sudah login: isi token di fake store.
  if (loggedIn) {
    store.save(access: 'fake-access', refresh: 'fake-refresh');
  }

  final router = GoRouter(
    initialLocation: initialLocation,
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

  return ProviderScope(
    overrides: [
      tokenStoreProvider.overrideWithValue(store),
      authRepositoryProvider.overrideWithValue(repo),
    ],
    child: ScreenshotBoundary(
      child: MaterialApp.router(
        title: 'Campus Notify',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    ),
  );
}

/// Capture frame → PNG di folder screenshots/ mingguan.
Future<void> captureApp(
  WidgetTester tester,
  String filename,
  Widget app, {
  Duration? initialPump,
}) async {
  tester.view.physicalSize = const Size(786, 1704);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(app);
  if (initialPump != null) {
    await tester.pump(initialPump);
  } else {
    await tester.pumpAndSettle();
  }

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byWidgetPredicate((widget) => widget is ScreenshotBoundary),
  );
  final image = boundary.toImageSync(pixelRatio: 2.0);
  final rawBytes = await tester.runAsync(
    () async => image.toByteData(format: ui.ImageByteFormat.png),
  );
  if (rawBytes == null) {
    throw StateError('toByteData tidak menghasilkan data PNG');
  }

  final file = File('../screenshots/$filename');
  file.createSync(recursive: true);
  file.writeAsBytesSync(rawBytes.buffer.asUint8List());

  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

/// Muat font Roboto asli dari cache Flutter SDK agar teks terbaca.
Future<void> loadRealFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) return;

  final fontDir =
      p.join(flutterRoot, 'bin', 'cache', 'artifacts', 'material_fonts');

  const weights = [
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
    'roboto-italic.ttf',
    'roboto-mediumitalic.ttf',
    'roboto-bolditalic.ttf',
  ];

  final loader = FontLoader('Roboto');
  for (final file in weights) {
    final path = p.join(fontDir, file);
    if (!File(path).existsSync()) continue;
    final bytes = Uint8List.fromList(File(path).readAsBytesSync());
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();

  final iconsPath = p.join(fontDir, 'materialicons-regular.otf');
  if (File(iconsPath).existsSync()) {
    final icons = FontLoader('MaterialIcons');
    final bytes = Uint8List.fromList(File(iconsPath).readAsBytesSync());
    icons.addFont(Future.value(ByteData.view(bytes.buffer)));
    await icons.load();
  }
}

void main() {
  setUpAll(loadRealFonts);

  testWidgets('screenshot: halaman login', (tester) async {
    await captureApp(
      tester,
      'login_page.png',
      buildScreenshotApp(),
    );
  });

  testWidgets('screenshot: halaman home setelah login', (tester) async {
    await captureApp(
      tester,
      'home_page.png',
      buildScreenshotApp(loggedIn: true, initialLocation: AppRoutes.home),
    );
  });

  testWidgets('screenshot: detail pengumuman', (tester) async {
    await captureApp(
      tester,
      'announcement_detail.png',
      buildScreenshotApp(
        loggedIn: true,
        initialLocation: AppRoutes.announcementById('3'),
      ),
    );
  });

  testWidgets('screenshot: detail pengumuman deep link', (tester) async {
    await captureApp(
      tester,
      'announcement_deeplink.png',
      buildScreenshotApp(
        loggedIn: true,
        initialLocation: AppRoutes.announcementById('5'),
      ),
    );
  });
}

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/local/post.dart';
import 'package:week5_offline_notes/data/providers.dart';
import 'package:week5_offline_notes/main.dart';
import 'package:week5_offline_notes/router.dart';

import 'fakes.dart';

/// Pembungkus frame yang ingin di-capture.
/// Diganti widget khusus agar RepaintBoundary milik framework
/// (Scaffold, dsb.) tidak ikut terdeteksi saat pencarian.
class ScreenshotBoundary extends SingleChildRenderObjectWidget {
  const ScreenshotBoundary({super.key, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderRepaintBoundary();
  }
}

/// Seed demo: 5 catatan, 2 di antaranya dirty (mengambang di antrean sync).
List<Note> seedDirtyNotes() => [
      Note(
        id: 1,
        title: 'Belanja mingguan',
        body: 'Susu, telur, roti, kopi',
        updatedAt: DateTime(2026, 10, 23, 8, 12),
        dirty: true,
      ),
      Note(
        id: 2,
        title: 'Ide praktikum week 5',
        body: 'Offline notes dengan dirty flag & sync queue',
        updatedAt: DateTime(2026, 10, 23, 8, 45),
        dirty: true,
      ),
      Note(
        id: 3,
        title: 'Rencana belajar',
        body: 'Riverpod: AsyncNotifier & provider family',
        updatedAt: DateTime(2026, 10, 22, 19, 30),
      ),
      Note(
        id: 4,
        title: 'Tontonan akhir pekan',
        updatedAt: DateTime(2026, 10, 22, 10, 5),
      ),
      Note(
        id: 5,
        title: 'Catatan rapat TI-3D',
        body: 'Diskusi portofolio minggu depan',
        updatedAt: DateTime(2026, 10, 21, 13, 0),
      ),
    ];

/// Seed demo: semua catatan sudah tersinkron (dirty = false).
List<Note> seedSyncedNotes() => [
      for (final note in seedDirtyNotes())
        Note(
          id: note.id,
          title: note.title,
          body: note.body,
          updatedAt: note.updatedAt,
        ),
    ];

/// Seed cache posts (simulasi hasil fetch yang sudah tersimpan di cache).
List<Post> seedPosts() => List.generate(
      100,
      (index) => Post(
        id: index + 1,
        title: 'Post #${index + 1}',
        body: 'Tersimpan di tabel cached_posts',
      ),
    );

/// Fake forceOffline dengan nilai awal tetap (agar test deterministik).
class _FixedForceOfflineNotifier extends ForceOfflineNotifier {
  _FixedForceOfflineNotifier(this._initial);
  final bool _initial;

  @override
  bool build() => _initial;
}

/// Fake cache posts: langsung mengembalikan seed tanpa sentuh
/// jaringan atau database.
class _StaticPostsCacheNotifier extends PostsCacheNotifier {
  _StaticPostsCacheNotifier(this._posts);
  final List<Post> _posts;

  @override
  Future<List<Post>> build() async => _posts;

  @override
  Future<void> refresh() async {}
}

/// Membangun aplikasi utuh dengan fake repository (deterministik:
/// tanpa database sungguhan & tanpa jaringan).
Widget buildScreenshotApp({
  required List<Note> notes,
  bool darkMode = false,
  bool forceOffline = false,
  Duration? fetchDelay,
  bool throwError = false,
  String initialLocation = '/',
}) {
  final prefs = FakePrefsRepository()
    ..darkMode = darkMode
    ..lastOpened = '2026-10-22T20:15:00.000';

  return ProviderScope(
    overrides: [
      prefsRepositoryProvider.overrideWithValue(prefs),
      noteRepositoryProvider.overrideWithValue(
        FakeNoteRepository(
          items: notes,
          fetchDelay: fetchDelay,
          throwError: throwError,
        ),
      ),
      forceOfflineProvider.overrideWith(
        () => _FixedForceOfflineNotifier(forceOffline),
      ),
      postsCacheProvider.overrideWith(
        () => _StaticPostsCacheNotifier(seedPosts()),
      ),
    ],
    child: ScreenshotBoundary(
      child: MyApp(router: createAppRouter(initialLocation: initialLocation)),
    ),
  );
}

/// Mencapture frame aplikasi ke file PNG di folder screenshots/ mingguan
/// (satu level di atas folder project).
Future<void> captureApp(
  WidgetTester tester,
  String filename,
  Widget app, {
  Duration? initialPump,
}) async {
  // Viewport ukuran HP portrait: logis 393x852, skala 2x agar tajam.
  tester.view.physicalSize = const Size(786, 1704);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(app);
  if (initialPump != null) {
    // Berhenti di state loading (belum settle) untuk menangkap spinner.
    await tester.pump(initialPump);
  } else {
    await tester.pumpAndSettle();
  }

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byWidgetPredicate((widget) => widget is ScreenshotBoundary),
  );
  final image = boundary.toImageSync(pixelRatio: 2.0);
  // toByteData adalah panggilan async asli ke engine (raster thread).
  // Di lingkungan test (FakeAsync), respons engine hanya tersampaikan
  // bila dijalankan di dalam tester.runAsync — pola resmi untuk operasi
  // async asli dalam widget test.
  final rawBytes = await tester.runAsync(
    () async => image.toByteData(format: ui.ImageByteFormat.png),
  );
  if (rawBytes == null) {
    throw StateError('toByteData tidak menghasilkan data PNG');
  }

  final file = File('../screenshots/$filename');
  file.createSync(recursive: true);
  file.writeAsBytesSync(rawBytes.buffer.asUint8List());

  // Drain sisa future/timer (mis. fetchDelay) agar testWidgets tidak gagal
  // karena "A Timer is still active".
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

/// Muat font Roboto asli dari cache Flutter SDK agar teks terbaca
/// pada screenshot.
///
/// Test Flutter memakai font "Ahem" secara default (semua glyph
/// berbentuk kotak) yang tidak informatif untuk dokumentasi.
/// Font dimuat sekali per isolate test melalui [setUpAll].
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

  // Font ikon Material (ikon AppBar, FAB, NavigationBar, dsb.).
  // Tanpa ini, ikon ter-render sebagai kotak kosong pada screenshot.
  final iconsPath = p.join(fontDir, 'materialicons-regular.otf');
  if (File(iconsPath).existsSync()) {
    final icons = FontLoader('MaterialIcons');
    final bytes = Uint8List.fromList(File(iconsPath).readAsBytesSync());
    icons.addFont(Future.value(ByteData.view(bytes.buffer)));
    await icons.load();
  }
}

void main() {
  // Muat font asli sebelum seluruh test screenshot.
  setUpAll(loadRealFonts);

  testWidgets('screenshot: daftar catatan dengan badge dirty',
      (tester) async {
    await captureApp(
      tester,
      'notes_list_dirty.png',
      buildScreenshotApp(notes: seedDirtyNotes()),
    );
  });

  testWidgets('screenshot: daftar catatan semua tersinkron', (tester) async {
    await captureApp(
      tester,
      'notes_list_synced.png',
      buildScreenshotApp(notes: seedSyncedNotes()),
    );
  });

  testWidgets('screenshot: state loading', (tester) async {
    await captureApp(
      tester,
      'notes_loading.png',
      buildScreenshotApp(
        notes: seedDirtyNotes(),
        fetchDelay: const Duration(seconds: 2),
      ),
      initialPump: const Duration(milliseconds: 400),
    );
  });

  testWidgets('screenshot: state error', (tester) async {
    await captureApp(
      tester,
      'notes_error.png',
      buildScreenshotApp(notes: const [], throwError: true),
    );
  });

  testWidgets('screenshot: state empty', (tester) async {
    await captureApp(
      tester,
      'notes_empty.png',
      buildScreenshotApp(notes: const []),
    );
  });

  testWidgets('screenshot: halaman detail catatan', (tester) async {
    await captureApp(
      tester,
      'note_detail.png',
      buildScreenshotApp(
        notes: seedDirtyNotes(),
        initialLocation: '/note/1',
      ),
    );
  });

  testWidgets('screenshot: antrean sync saat offline', (tester) async {
    await captureApp(
      tester,
      'offline_queue.png',
      buildScreenshotApp(notes: seedDirtyNotes(), forceOffline: true),
    );
  });

  testWidgets('screenshot: pengaturan tema terang', (tester) async {
    await captureApp(
      tester,
      'settings_light.png',
      buildScreenshotApp(
        notes: seedSyncedNotes(),
        initialLocation: '/settings',
      ),
    );
  });

  testWidgets('screenshot: pengaturan tema gelap + offline', (tester) async {
    await captureApp(
      tester,
      'settings_dark.png',
      buildScreenshotApp(
        notes: seedSyncedNotes(),
        darkMode: true,
        forceOffline: true,
        initialLocation: '/settings',
      ),
    );
  });
}

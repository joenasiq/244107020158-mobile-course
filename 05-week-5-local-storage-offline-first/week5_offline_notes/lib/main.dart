import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/providers.dart';
import 'pages/settings_page.dart';
import 'router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

/// Root aplikasi.
///
/// Menerapkan tema sesuai preferensi tersimpan (SharedPreferences)
/// dan menandai waktu aplikasi baru saja dibuka saat start.
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key, this.router});

  /// Router injeksi; dipakai test untuk membuka layar tertentu langsung.
  final GoRouter? router;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Tandai waktu aplikasi dibuka (ditampilkan di halaman Pengaturan).
    ref.read(prefsRepositoryProvider).markOpenedNow();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(darkModeProvider).value ?? false;

    return MaterialApp.router(
      title: 'Week 5 - Offline Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: widget.router ?? createAppRouter(),
    );
  }
}

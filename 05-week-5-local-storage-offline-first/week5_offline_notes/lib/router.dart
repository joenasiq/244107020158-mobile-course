import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/note_detail_page.dart';
import 'pages/notes_page.dart';
import 'pages/settings_page.dart';

/// Daftar rute aplikasi.
///
/// Dipisah dari instance GoRouter agar mudah dipakai ulang,
/// misalnya pada test yang membuka layar tertentu langsung.
final List<RouteBase> appRoutes = [
  // Rute tab utama (Catatan & Pengaturan) dibungkus NavigationBar.
  ShellRoute(
    builder: (context, state, child) => MainNavigationScaffold(
      location: state.uri.path,
      child: child,
    ),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const NotesPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  ),
  // Detail catatan: di luar tab, punya AppBar kembali sendiri.
  GoRoute(
    path: '/note/:id',
    builder: (context, state) {
      final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
      return NoteDetailPage(noteId: id);
    },
  ),
];

/// Membuat instance GoRouter dengan lokasi awal yang bisa dikustomisasi.
GoRouter createAppRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: appRoutes,
  );
}

/// Scaffold utama pembungkus rute tab yang menampilkan NavigationBar.
class MainNavigationScaffold extends StatelessWidget {
  final String location;
  final Widget child;

  const MainNavigationScaffold({
    super.key,
    required this.location,
    required this.child,
  });

  int get _currentIndex => location == '/settings' ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go('/');
          } else {
            context.go('/settings');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Catatan',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

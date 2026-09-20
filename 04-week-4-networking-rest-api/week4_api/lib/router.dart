import 'package:go_router/go_router.dart';
import 'pages/paged_post_page.dart';
import 'pages/post_detail_page.dart';
import 'pages/post_list_page.dart';

/// Konfigurasi GoRouter aplikasi
final router = GoRouter(
  initialLocation: '/',
  routes: [
    // Halaman daftar post utama
    GoRoute(
      path: '/',
      builder: (context, state) => const PostListPage(),
      routes: [
        // Halaman detail post dengan parameter ID (/post/:id)
        GoRoute(
          path: 'post/:id',
          builder: (context, state) {
            final idStr = state.pathParameters['id'] ?? '0';
            final id = int.tryParse(idStr) ?? 0;
            return PostDetailPage(postId: id);
          },
        ),
      ],
    ),
    // Halaman daftar post dengan infinite scroll pagination
    GoRoute(
      path: '/paged',
      builder: (context, state) => const PagedPostPage(),
    ),
  ],
);

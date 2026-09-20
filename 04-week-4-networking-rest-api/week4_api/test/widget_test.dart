import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/main.dart';

/// Fake PostRepository untuk mencegah timer HTTP aktif saat widget test
class FakePostRepository implements PostRepository {
  @override
  Future<List<Post>> fetchPosts() async => const [
        Post(userId: 1, id: 1, title: 'Test Post 1', body: 'Body 1'),
      ];

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async =>
      const [
        Post(userId: 1, id: 1, title: 'Test Post 1', body: 'Body 1'),
      ];

  @override
  Future<Post> fetchPost(int id) async => const Post(
        userId: 1,
        id: 1,
        title: 'Test Post 1',
        body: 'Body 1',
      );
}

void main() {
  testWidgets('Aplikasi Week 4 REST API berhasil dirender', (WidgetTester tester) async {
    // 1. Build aplikasi utama dengan provider override agar tidak melakukan HTTP call sungguhan
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(FakePostRepository()),
        ],
        child: const MyApp(),
      ),
    );

    // 2. Settle semua frame
    await tester.pumpAndSettle();

    // 3. Verifikasi widget utama berhasil dirender
    expect(find.byType(MyApp), findsOneWidget);
  });
}

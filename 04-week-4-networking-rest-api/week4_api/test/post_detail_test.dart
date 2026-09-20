import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/comment_repository.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/pages/post_detail_page.dart';
import 'package:week4_api/router.dart';

class MockPostRepository implements PostRepository {
  bool fetchPostCalled = false;

  @override
  Future<List<Post>> fetchPosts() async => const [
        Post(userId: 1, id: 10, title: 'List Title 10', body: 'List Body 10'),
      ];

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async =>
      const [];

  @override
  Future<Post> fetchPost(int id) async {
    fetchPostCalled = true;
    return Post(
      userId: 1,
      id: id,
      title: 'Direct Fetch Title $id',
      body: 'Direct Fetch Body $id',
    );
  }
}

class MockCommentRepository implements CommentRepository {
  @override
  Future<List<Comment>> fetchComments(int postId) async => [
        Comment(
          postId: postId,
          id: 1,
          name: 'Commenter One',
          email: 'one@example.com',
          body: 'This is a sample comment body.',
        ),
      ];
}

void main() {
  group('Post Detail & Provider Tests', () {
    test('postDetailProvider mengambil dari postListProvider bila sudah dimuat di list', () async {
      final mockPostRepo = MockPostRepository();
      final container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(mockPostRepo),
        ],
      );
      addTearDown(container.dispose);

      // 1. Muat postListProvider terlebih dahulu
      await container.read(postListProvider.future);

      // 2. Baca postDetailProvider untuk id: 10 yang ada di list
      final detailPost = await container.read(postDetailProvider(10).future);

      // 3. Pastikan data berasal dari cache list, dan fetchPost TIDAK dipanggil
      expect(detailPost.title, equals('List Title 10'));
      expect(mockPostRepo.fetchPostCalled, isFalse);
    });

    test('postDetailProvider mengambil via repository bila dibuka langsung (tidak ada di list)', () async {
      final mockPostRepo = MockPostRepository();
      final container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(mockPostRepo),
        ],
      );
      addTearDown(container.dispose);

      // Buka langsung post id: 99 (tidak ada di cache list)
      final detailPost = await container.read(postDetailProvider(99).future);

      // Pastikan memanggil repository fetchPost
      expect(detailPost.title, equals('Direct Fetch Title 99'));
      expect(mockPostRepo.fetchPostCalled, isTrue);
    });

    testWidgets('PostDetailPage merender judul, body lengkap, dan komentar', (tester) async {
      final mockPostRepo = MockPostRepository();
      final mockCommentRepo = MockCommentRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            postRepositoryProvider.overrideWithValue(mockPostRepo),
            commentRepositoryProvider.overrideWithValue(mockCommentRepo),
          ],
          child: const MaterialApp(
            home: PostDetailPage(postId: 42),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi Judul & Body lengkap tampil
      expect(find.text('Post #42'), findsOneWidget);
      expect(find.text('Direct Fetch Title 42'), findsOneWidget);
      expect(find.text('Direct Fetch Body 42'), findsOneWidget);

      // Verifikasi Komentar tampil
      expect(find.text('Commenter One'), findsOneWidget);
      expect(find.text('one@example.com'), findsOneWidget);
      expect(find.text('This is a sample comment body.'), findsOneWidget);
    });

    testWidgets('Navigasi GoRouter ke /post/:id berhasil membuka detail', (tester) async {
      final mockPostRepo = MockPostRepository();
      final mockCommentRepo = MockCommentRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            postRepositoryProvider.overrideWithValue(mockPostRepo),
            commentRepositoryProvider.overrideWithValue(mockCommentRepo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigasi ke detail post
      router.go('/post/10');
      await tester.pumpAndSettle();

      // Pastikan PostDetailPage tampil
      expect(find.byType(PostDetailPage), findsOneWidget);
      expect(find.text('Post #10'), findsOneWidget);
    });
  });
}

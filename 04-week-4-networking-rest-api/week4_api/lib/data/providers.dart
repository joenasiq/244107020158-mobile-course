import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'models/comment.dart';
import 'models/post.dart';
import 'repositories/comment_repository.dart';
import 'repositories/post_repository.dart';

/// Provider utama untuk instance Dio HTTP Client
final dioProvider = Provider<Dio>((ref) => createDio());

/// Provider untuk PostRepository
final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

/// Provider untuk CommentRepository
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// Notifier untuk mengelola list Post
class PostListNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repository = ref.watch(postRepositoryProvider);
    return repository.fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(postRepositoryProvider);
      state = AsyncData(await repository.fetchPosts());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final postListProvider =
    AsyncNotifierProvider<PostListNotifier, List<Post>>(
  PostListNotifier.new,
  retry: (retryCount, error) => null,
);

/// Provider untuk mengambil detail satu Post berdasarkan ID.
/// - Mengambil state dari list yang sudah dimuat (postListProvider) jika ada.
/// - Mengambil langsung via repository (PostRepository.fetchPost) bila halaman dibuka langsung.
final postDetailProvider = FutureProvider.family<Post, int>((ref, id) async {
  // Cek apakah list post saat ini sudah dimuat dan memiliki post yang dicari
  final postListState = ref.read(postListProvider);
  final postFromList =
      postListState.value?.where((p) => p.id == id).firstOrNull;
  if (postFromList != null) {
    return postFromList;
  }

  // Bila dibuka langsung (misal deep link), ambil dari repository
  final repo = ref.watch(postRepositoryProvider);
  return repo.fetchPost(id);
});

/// Notifier untuk mengelola list Comment berdasarkan postId (AsyncNotifier per postId)
class CommentsNotifier extends AsyncNotifier<List<Comment>> {
  final int postId;
  CommentsNotifier(this.postId);

  @override
  Future<List<Comment>> build() async {
    // Exception yang dilempar dari repository otomatis ditangkap dan diubah menjadi AsyncError oleh Riverpod
    final repository = ref.watch(commentRepositoryProvider);
    return repository.fetchComments(postId);
  }

  /// Fungsi untuk menyegarkan daftar komentar secara manual
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(postId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Provider family untuk komentar per postId
final commentsProvider =
    AsyncNotifierProvider.family<CommentsNotifier, List<Comment>, int>(
  (postId) => CommentsNotifier(postId),
  retry: (retryCount, error) => null,
);

/// Helper khusus testing: membaca state pertama yang bukan loading lewat listener + completer
Future<List<Post>> readPostsOnce(ProviderContainer container) {
  final completer = Completer<List<Post>>();
  final sub = container.listen<AsyncValue<List<Post>>>(
    postListProvider,
    (previous, next) {
      if (next.isLoading || completer.isCompleted) return;
      next.whenData(completer.complete);
      if (next.hasError) {
        completer.completeError(
          next.error ?? StateError('unknown error'),
          next.stackTrace ?? StackTrace.empty,
        );
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}

Future<Object?> readPostsErrorOnce(ProviderContainer container) {
  final completer = Completer<Object?>();
  final sub = container.listen<AsyncValue<List<Post>>>(
    postListProvider,
    (previous, next) {
      if (next.isLoading || completer.isCompleted) return;
      completer.complete(next.error);
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}
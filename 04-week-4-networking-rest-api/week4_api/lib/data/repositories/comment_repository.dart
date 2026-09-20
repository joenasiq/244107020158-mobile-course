import 'package:dio/dio.dart';
import '../models/comment.dart';

/// Repository untuk mengelola pemanggilan API terkait komentar (Comments)
class CommentRepository {
  final Dio _dio;

  CommentRepository(this._dio);

  /// Mengambil daftar komentar berdasarkan postId: GET /comments?postId={id}
  /// Dilengkapi dengan timeout konfigurasi 10 detik
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}

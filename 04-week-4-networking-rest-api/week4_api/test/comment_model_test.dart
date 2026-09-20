import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  group('Comment Model Unit Tests', () {
    // -------------------------------------------------------------------------
    // Test Case: fromJson dengan field yang hilang (Missing/Null Fields)
    // Memastikan Null-Safety berjalan baik dan nilai default fallback terisi aman
    // -------------------------------------------------------------------------
    test('fromJson harus mengembalikan default fallback saat field json hilang atau bernilai null', () {
      // 1. Menyiapkan JSON dengan beberapa field yang hilang (misal: postId, email, body tidak ada, name bernilai null)
      final Map<String, dynamic> incompleteJson = {
        'id': 101,
        'name': null,
        // postId, email, body sengaja dihilangkan (missing fields)
      };

      // 2. Melakukan deserialisasi menggunakan Comment.fromJson
      final comment = Comment.fromJson(incompleteJson);

      // 3. Verifikasi bahwa tidak terjadi exception / crash
      expect(comment, isNotNull);

      // 4. Verifikasi field yang ada diparse dengan benar
      expect(comment.id, equals(101));

      // 5. Verifikasi field yang null/hilang terisi nilai aman default (fallback)
      expect(comment.postId, equals(0)); // Default integer fallback
      expect(comment.name, equals(''));  // Default string fallback untuk null
      expect(comment.email, equals('')); // Default string fallback untuk missing field
      expect(comment.body, equals(''));  // Default string fallback untuk missing field
    });

    // -------------------------------------------------------------------------
    // Test Case Tambahan: fromJson dengan JSON lengkap (Full Valid JSON)
    // -------------------------------------------------------------------------
    test('fromJson harus memetakan semua field dengan benar saat JSON lengkap', () {
      final Map<String, dynamic> fullJson = {
        'postId': 1,
        'id': 5,
        'name': 'Budi Santoso',
        'email': 'budi@example.com',
        'body': 'Komentar ini sangat bermanfaat.',
      };

      final comment = Comment.fromJson(fullJson);

      expect(comment.postId, equals(1));
      expect(comment.id, equals(5));
      expect(comment.name, equals('Budi Santoso'));
      expect(comment.email, equals('budi@example.com'));
      expect(comment.body, equals('Komentar ini sangat bermanfaat.'));
    });
  });
}

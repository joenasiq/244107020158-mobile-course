import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/widgets/post_tile.dart';

void main() {
  group('PostTile Widget Tests', () {
    testWidgets('PostTile menampilkan ID, Title, dan Body dengan benar', (WidgetTester tester) async {
      const testPost = Post(
        userId: 1,
        id: 42,
        title: 'Judul Postingan Uji Coba',
        body: 'Isi konten postingan uji coba untuk testing PostTile.',
      );

      bool wasTapped = false;

      // 1. Render PostTile di dalam MaterialApp & Scaffold
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostTile(
              post: testPost,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      // 2. Verifikasi ID pada avatar lingkaran
      expect(find.text('42'), findsOneWidget);

      // 3. Verifikasi Title dan Body
      expect(find.text('Judul Postingan Uji Coba'), findsOneWidget);
      expect(find.text('Isi konten postingan uji coba untuk testing PostTile.'), findsOneWidget);

      // 4. Uji interaksi tap
      await tester.tap(find.byType(PostTile));
      expect(wasTapped, isTrue);
    });
  });
}

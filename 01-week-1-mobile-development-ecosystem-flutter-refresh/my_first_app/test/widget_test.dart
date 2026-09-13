import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/main.dart';

void main() {
  testWidgets('Profil Mahasiswa smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProfileApp());

    // Verify that student profile information is displayed.
    expect(find.text('Profil Mahasiswa'), findsWidgets);
    expect(find.text('Arjuna Satria Hutama'), findsOneWidget);
    expect(find.text('NIM: 244107020158'), findsOneWidget);
    expect(find.text('Program Studi: D4 Teknik Informatika'), findsOneWidget);
  });
}

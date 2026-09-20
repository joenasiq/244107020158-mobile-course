import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wekk3_todo/main.dart';

void main() {
  testWidgets('menambah tugas baru', (tester) async {
    // 1. Build aplikasi dengan ProviderScope
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // 2. Verifikasi tampilan awal ketika belum ada tugas
    expect(find.text('Belum ada tugas'), findsOneWidget);

    // 3. Tekan tombol FloatingActionButton (+) untuk membuka dialog
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // 4. Masukkan teks tugas baru ke TextField dan tekan 'Tambah'
    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    // 5. Verifikasi bahwa tugas baru berhasil ditambahkan dan muncul di layar
    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });

  testWidgets('berpindah halaman menggunakan NavigationBar ke /stats', (tester) async {
    // 1. Build aplikasi
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // 2. Pastikan berada di halaman ToDo
    expect(find.text('ToDo Riverpod'), findsOneWidget);

    // 3. Tekan navigasi 'Statistik' pada NavigationBar
    await tester.tap(find.text('Statistik'));
    await tester.pumpAndSettle();

    // 4. Verifikasi berpindah ke halaman Statistik
    expect(find.text('Statistik Akademik'), findsOneWidget);
  });
}

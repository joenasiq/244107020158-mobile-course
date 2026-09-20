import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wekk3_todo/providers/stats_provider.dart';

/// Fake Random untuk menguji skenario Sukses (menghasilkan nilai >= 0.3)
class FakeAlwaysSuccessRandom implements Random {
  @override
  double nextDouble() => 0.5; // 0.5 >= 0.3 -> Selalu Sukses

  @override
  bool nextBool() => true;
  @override
  int nextInt(int max) => 0;
}

/// Fake Random untuk menguji skenario Gagal (menghasilkan nilai < 0.3)
class FakeAlwaysFailRandom implements Random {
  @override
  double nextDouble() => 0.1; // 0.1 < 0.3 -> Selalu Melempar Error (30% simulation)

  @override
  bool nextBool() => false;
  @override
  int nextInt(int max) => 0;
}

void main() {
  group('StatsNotifier Unit Tests', () {
    // -------------------------------------------------------------------------
    // Test Case 1: Memverifikasi State Awal adalah AsyncLoading
    // -------------------------------------------------------------------------
    test('State awal notifier harus berupa AsyncLoading', () {
      // 1. Membuat ProviderContainer terisolasi untuk unit testing Riverpod
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 2. Membaca state awal provider
      final initialState = container.read(statsProvider);

      // 3. Verifikasi bahwa state awal bertipe AsyncLoading
      expect(initialState, isA<AsyncLoading>());
    });

    // -------------------------------------------------------------------------
    // Test Case 2: Memverifikasi Skenario Sukses (Mengembalikan 3 Item Statistik)
    // -------------------------------------------------------------------------
    test('Notifier berhasil mengembalikan 3 item statistik saat tidak terjadi error', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(() {
            final notifier = StatsNotifier();
            // Menyuntikkan random fake yang selalu sukses (0.5 >= 0.3)
            notifier.random = FakeAlwaysSuccessRandom();
            return notifier;
          }),
        ],
      );
      addTearDown(container.dispose);

      // 1. Menunggu Future dari provider selesai dieksekusi (setelah delay 2 detik)
      final result = await container.read(statsProvider.future);

      // 2. Verifikasi jumlah data yang dihasilkan adalah 3 item
      expect(result.length, equals(3));
      expect(result[0].title, equals('Total Tugas'));
      expect(result[1].title, equals('Tingkat Keberhasilan'));
      expect(result[2].title, equals('Waktu Belajar'));

      // 3. Verifikasi state akhir di container adalah AsyncData
      final finalState = container.read(statsProvider);
      expect(finalState, isA<AsyncData<List<StatItem>>>());
    });

    // -------------------------------------------------------------------------
    // Test Case 3: Memverifikasi Skenario Error (Melempar Exception pada kegagalan 30%)
    // -------------------------------------------------------------------------
    test('Notifier berpindah ke AsyncError saat simulasi kegagalan terjadi', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(() {
            final notifier = StatsNotifier();
            // Menyuntikkan random fake yang memicu error (< 0.3)
            notifier.random = FakeAlwaysFailRandom();
            return notifier;
          }),
        ],
      );

      // 1. Memasang listener agar provider aktif dan menyelesaikan build()
      final listener = container.listen(statsProvider, (prev, next) {});

      // 2. Menunggu 2.5 detik hingga proses async build() yang melempar error selesai
      await Future.delayed(const Duration(milliseconds: 2500));

      // 3. Verifikasi bahwa state akhir adalah error dan memiliki pesan yang sesuai
      final state = container.read(statsProvider);
      expect(state.hasError, isTrue);
      expect(state.error.toString(), contains('Gagal memuat data statistik'));

      listener.close();
      container.dispose();
    });

    // -------------------------------------------------------------------------
    // Test Case 4: Memverifikasi Fungsi refreshStats() / Invalidate
    // -------------------------------------------------------------------------
    test('refreshStats() mengubah state kembali menjadi loading dan mengambil data baru', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(() {
            final notifier = StatsNotifier();
            notifier.random = FakeAlwaysSuccessRandom();
            return notifier;
          }),
        ],
      );
      addTearDown(container.dispose);

      // 1. Tunggu data pertama selesai dimuat
      await container.read(statsProvider.future);

      // 2. Panggil refreshStats()
      final refreshFuture = container.read(statsProvider.notifier).refreshStats();

      // 3. Tunggu refresh selesai dan cek bahwa data tetap valid 3 item
      await refreshFuture;
      final updatedState = container.read(statsProvider);
      expect(updatedState, isA<AsyncData<List<StatItem>>>());
      expect(updatedState.value?.length, equals(3));
    });
  });
}

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model sederhana untuk merepresentasikan data statistik
class StatItem {
  final String title;
  final String value;
  final String description;

  const StatItem({
    required this.title,
    required this.value,
    required this.description,
  });
}

/// AsyncNotifier untuk mengelola state asynchronous dari data statistik
class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  // Instance Random untuk simulasi kegagalan 30%
  // Dibuat injectable / dapat dioverride untuk kemudahan testing jika diperlukan
  Random random = Random();

  @override
  Future<List<StatItem>> build() async {
    // 1. Simulasi jeda network selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    // 2. Simulasi probabilitas kegagalan 30% (angka acak 0.0 sampai 1.0 < 0.3)
    if (random.nextDouble() < 0.3) {
      throw Exception('Gagal memuat data statistik dari server (Koneksi terputus).');
    }

    // 3. Mengembalikan 3 item statistik jika berhasil (Success State)
    return const [
      StatItem(
        title: 'Total Tugas',
        value: '48 Selesai',
        description: 'Tugas yang telah diselesaikan semester ini',
      ),
      StatItem(
        title: 'Tingkat Keberhasilan',
        value: '95.8%',
        description: 'Persentase keberhasilan pengerjaan tugas tepat waktu',
      ),
      StatItem(
        title: 'Waktu Belajar',
        value: '34 Jam',
        description: 'Total waktu pengerjaan praktikum & materi',
      ),
    ];
  }

  /// Fungsi untuk memicu pengambilan ulang data secara manual
  Future<void> refreshStats() async {
    // Ubah state menjadi loading
    state = const AsyncLoading();
    // Gunakan AsyncValue.guard untuk otomatis menangkap error jika terjadi exception
    state = await AsyncValue.guard(() => build());
  }
}

/// Provider global yang menghubungkan StatsNotifier dengan UI
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<StatItem>>(StatsNotifier.new);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

/// Halaman StatsPage menggunakan ConsumerWidget untuk mengakses data dari Riverpod
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Memantau (watch) state dari statsProvider secara reaktif
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Akademik'),
        centerTitle: true,
        actions: [
          // Tombol refresh manual di AppBar
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Data',
            onPressed: () => ref.read(statsProvider.notifier).refreshStats(),
          ),
        ],
      ),
      // 2. Menggunakan .when() untuk menangani 3 kondisi state: Loading, Error, dan Data
      body: statsAsync.when(
        // Kondisi 1: Loading State (Menampilkan Spinner / Progress Indicator)
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Memuat statistik (simulasi 2 detik)...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        // Kondisi 2: Error State (Menampilkan Pesan Kesalahan & Tombol Coba Lagi)
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Terjadi Kesalahan!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                // Tombol Retry: menggunakan ref.invalidate() untuk memicu ulang pengambilan data
                FilledButton.icon(
                  icon: const Icon(Icons.replay),
                  label: const Text('Coba Lagi'),
                  onPressed: () {
                    // invalidate akan mereset provider dan menjalankan build() kembali
                    ref.invalidate(statsProvider);
                  },
                ),
              ],
            ),
          ),
        ),

        // Kondisi 3: Success / Data State (Menampilkan ListView dengan 3 Item Statistik)
        data: (statsList) => ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: statsList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = statsList[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(item.description),
                trailing: Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

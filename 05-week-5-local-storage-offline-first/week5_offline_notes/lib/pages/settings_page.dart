import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../widgets/note_tile.dart' show formatNoteTime;

/// Notifier preferensi tema gelap/terang (disimpan di SharedPreferences).
///
/// Setiap perubahan langsung dipersist sehingga bertahan setelah
/// aplikasi ditutup.
class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final darkModeProvider = AsyncNotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
  // Matikan auto-retry bawaan: kegagalan baca preferensi langsung
  // ditampilkan sebagai error, tidak diulang diam-diam di background.
  retry: (retryCount, error) => null,
);

/// Halaman Pengaturan.
///
/// Menampilkan preferensi tersimpan (SharedPreferences):
///  1. Toggle tema gelap/terang
///  2. Simulasi offline deterministik (forceOffline)
///  3. Waktu terakhir dibuka & status cache offline
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider).value ?? false;
    final isOffline = ref.watch(forceOfflineProvider);
    final lastOpened = ref.watch(lastOpenedProvider).value;
    final postsCache = ref.watch(postsCacheProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Preferensi tema (SharedPreferences)
          Card(
            child: SwitchListTile.adaptive(
              title: const Text('Mode Gelap'),
              subtitle: const Text('Disimpan di SharedPreferences'),
              secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              value: isDark,
              onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Simulasi offline deterministik
          Card(
            child: SwitchListTile.adaptive(
              title: const Text('Simulasi Offline'),
              subtitle: const Text(
                'Cegah semua panggilan jaringan (forceOffline)',
              ),
              secondary: const Icon(Icons.cloud_off),
              value: isOffline,
              onChanged: (value) => ref
                  .read(forceOfflineProvider.notifier)
                  .setForceOffline(value),
            ),
          ),
          const SizedBox(height: 12),

          // 3. Informasi aplikasi
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Info',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Terakhir dibuka',
                    value: lastOpened == null
                        ? 'Pertama kali'
                        : formatNoteTime(
                            DateTime.tryParse(lastOpened) ?? DateTime.now(),
                          ),
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    label: 'Cache posts offline',
                    value: postsCache.when(
                      loading: () => 'Memuat cache...',
                      error: (_, _) => 'Gagal memuat',
                      data: (posts) => '${posts.length} posts tersimpan',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris label + nilai (pola Row + Expanded, gaya profil minggu 1).
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

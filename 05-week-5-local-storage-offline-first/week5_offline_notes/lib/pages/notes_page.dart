import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../widgets/note_tile.dart';

/// Halaman daftar catatan offline.
///
/// Berfungsi penuh tanpa internet: membaca, menambah, dan menghapus
/// catatan dari SQLite lokal, dengan banner antrean sinkronisasi
/// (dirty flag) sebagai indikator sync.
class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyCount = ref.watch(dirtyCountProvider).value ?? 0;
    final isOffline = ref.watch(forceOfflineProvider);
    final syncState = ref.watch(syncProvider);

    // Umpan balik hasil sinkronisasi lewat SnackBar.
    ref.listen(syncProvider, (_, next) {
      final messenger = ScaffoldMessenger.of(context);
      if (next.hasValue && (next.value ?? 0) > 0) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('${next.value} catatan tersinkron.')),
          );
      } else if (next.hasError) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          // Tombol sinkronisasi antrean dirty.
          IconButton(
            tooltip: 'Sinkronkan',
            icon: syncState.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            onPressed: syncState.isLoading
                ? null
                : () => ref.read(syncProvider.notifier).runSync(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah Catatan',
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: notesAsync.when(
        // Kondisi 1: Loading — spinner saat catatan pertama kali dimuat.
        loading: () => const Center(child: CircularProgressIndicator()),

        // Kondisi 2: Error — pesan ramah + tombol Coba lagi.
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Gagal memuat catatan: $err',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(notesProvider),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),

        // Kondisi 3: Data — daftar catatan / empty state.
        data: (notes) => Column(
          children: [
            // Banner indikator antrean sinkronisasi / status offline.
            if (notes.isNotEmpty)
              _SyncBanner(dirtyCount: dirtyCount, isOffline: isOffline),
            Expanded(
              child: notes.isEmpty
                  ? const _EmptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(notesProvider);
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: notes.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return NoteTile(
                            note: note,
                            onTap: () => context.push('/note/${note.id}'),
                            onDelete: () => ref
                                .read(notesProvider.notifier)
                                .deleteNote(note.id!),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog tambah catatan baru (judul + isi opsional).
  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catatan baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Judul catatan'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              maxLines: 3,
              decoration:
                  const InputDecoration(hintText: 'Isi catatan (opsional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                ref.read(notesProvider.notifier).addNote(
                      title: title,
                      body: bodyController.text.trim(),
                    );
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

/// Banner status sinkronisasi di atas daftar catatan.
class _SyncBanner extends StatelessWidget {
  final int dirtyCount;
  final bool isOffline;

  const _SyncBanner({required this.dirtyCount, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    // Semua bersih & online: status hijau.
    if (dirtyCount == 0 && !isOffline) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.green.shade50,
        child: Row(
          children: [
            Icon(Icons.cloud_done, size: 16, color: Colors.green.shade700),
            const SizedBox(width: 8),
            Text(
              'Semua catatan tersinkron',
              style: TextStyle(fontSize: 12, color: Colors.green.shade900),
            ),
          ],
        ),
      );
    }

    // Ada catatan mengambang di antrean (atau sedang offline).
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isOffline ? Colors.orange.shade100 : Colors.amber.shade50,
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.cloud_off : Icons.schedule,
            size: 16,
            color: isOffline
                ? Colors.orange.shade800
                : Colors.amber.shade800,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOffline
                  ? 'Offline • $dirtyCount catatan menunggu sinkronisasi'
                  : '$dirtyCount catatan belum tersinkron',
              style: TextStyle(
                fontSize: 12,
                color: isOffline
                    ? Colors.orange.shade900
                    : Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tampilan kosong saat belum ada catatan.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 56,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada catatan',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Tekan + untuk membuat catatan pertama',
            style: TextStyle(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../data/local/note.dart';

/// Format waktu gaya Indonesia tanpa dependensi intl,
/// mis. "23 Okt 2026, 08:45".
String formatNoteTime(DateTime dateTime) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  String two(int value) => value.toString().padLeft(2, '0');
  return '${dateTime.day} ${months[dateTime.month - 1]} '
      '${dateTime.year}, ${two(dateTime.hour)}:${two(dateTime.minute)}';
}

/// Badge penanda catatan yang belum tersinkron (dirty flag).
class DirtyBadge extends StatelessWidget {
  const DirtyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'belum tersinkron',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.orange,
        ),
      ),
    );
  }
}

/// Widget baris catatan.
///
/// Dipisah dari NotesPage agar build halaman tetap pendek, rapi, dan
/// mudah diuji (Refactoring Challenge #1). Menampilkan badge
/// "belum tersinkron" bila `dirty == true`.
class NoteTile extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NoteTile({
    super.key,
    required this.note,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      title: Text(
        note.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note.body.isNotEmpty)
            Text(
              note.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 12,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(width: 4),
              // Expanded agar tanggal tidak memaksa badge keluar layar
              // saat lebar terbatas (mencegah overflow).
              Expanded(
                child: Text(
                  formatNoteTime(note.updatedAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.outline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Badge hanya tampil saat catatan belum tersinkron.
              if (note.dirty) ...const [
                SizedBox(width: 8),
                DirtyBadge(),
              ],
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Hapus Catatan',
        onPressed: onDelete,
      ),
    );
  }
}

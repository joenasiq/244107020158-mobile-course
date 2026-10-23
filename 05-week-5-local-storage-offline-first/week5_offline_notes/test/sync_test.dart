import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/sync.dart';

import 'fakes.dart';

void main() {
  group('syncNotes', () {
    // -------------------------------------------------------------------------
    // Test Case 1: tidak ada catatan dirty -> langsung 0, tanpa delay
    // -------------------------------------------------------------------------
    test('mengembalikan 0 dan tidak mengubah data bila tidak ada dirty',
        () async {
      final repo = FakeNoteRepository(
        items: [
          Note(
            id: 1,
            title: 'bersih',
            updatedAt: DateTime(2026, 9, 18),
          ),
        ],
      );

      final synced = await syncNotes(repo);

      expect(synced, 0);
      expect(repo.countDirty(), completion(0));
    });

    // -------------------------------------------------------------------------
    // Test Case 2: antrean dirty diproses berurutan lalu ditandai bersih
    // -------------------------------------------------------------------------
    test('memproses antrean dirty dan menandai semua catatan bersih',
        () async {
      final repo = FakeNoteRepository(
        items: [
          Note(
            id: 1,
            title: 'kotor 1',
            updatedAt: DateTime(2026, 9, 19),
            dirty: true,
          ),
          Note(
            id: 2,
            title: 'bersih',
            updatedAt: DateTime(2026, 9, 18),
          ),
          Note(
            id: 3,
            title: 'kotor 2',
            updatedAt: DateTime(2026, 9, 20),
            dirty: true,
          ),
        ],
      );

      final synced = await syncNotes(repo);

      // 1. Kembalikan jumlah catatan yang berhasil disinkronkan
      expect(synced, 2);

      // 2. Seluruh antrean kosong setelah sync sukses
      expect(await repo.countDirty(), 0);
    });
  });
}

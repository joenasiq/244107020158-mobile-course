import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/providers.dart';

import 'fakes.dart';

void main() {
  group('Note Model Unit Tests', () {
    // -------------------------------------------------------------------------
    // Test Case 1: fromMap aman terhadap field yang hilang
    // -------------------------------------------------------------------------
    test('fromMap harus mengembalikan fallback aman saat field map hilang', () {
      // 1. Hanya title yang tersedia; id, body, updated_at, dirty hilang
      final note = Note.fromMap({'title': 'Belanja'});

      // 2. Field tersedia ter-mapping dengan benar
      expect(note.title, 'Belanja');

      // 3. Field hilang terisi nilai fallback aman (tidak crash)
      expect(note.id, isNull);
      expect(note.body, '');
      expect(note.dirty, isFalse);
    });

    // -------------------------------------------------------------------------
    // Test Case 2: flag dirty bertahan pada serialisasi
    // -------------------------------------------------------------------------
    test('flag dirty harus bertahan setelah toMap lalu fromMap', () {
      final note = Note(
        title: 'a',
        updatedAt: DateTime(2026, 9, 18),
        dirty: true,
      );

      final restored = Note.fromMap(note.toMap());

      expect(restored.dirty, isTrue);
      expect(restored.title, 'a');
      expect(restored.updatedAt, DateTime(2026, 9, 18));
    });
  });

  group('notesProvider dengan repository palsu', () {
    // -------------------------------------------------------------------------
    // Test Case 3: provider sukses dengan repository palsu
    // -------------------------------------------------------------------------
    test('provider mengembalikan data saat repository palsu sukses', () async {
      // 1. ProviderContainer terisolasi dengan override repository palsu
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(
              items: [Note(title: 'Tes', updatedAt: DateTime.now())],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // 2. Membaca future provider hingga selesai
      final notes = await container.read(notesProvider.future);

      // 3. Verifikasi isi data
      expect(notes.length, 1);
      expect(notes.first.title, 'Tes');
    });

    // -------------------------------------------------------------------------
    // Test Case 4: provider error dengan repository palsu
    // -------------------------------------------------------------------------
    test(
        'provider menghasilkan AsyncError saat repository palsu '
        'melempar exception', () async {
      // 1. Override repository palsu yang selalu gagal
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(throwError: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      // 2. Future provider harus melempar exception yang sama
      await expectLater(
        container.read(notesProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });
}

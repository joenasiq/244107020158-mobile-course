import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local/note.dart';
import 'local/post.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';
import 'sync.dart';

/// Repository preferensi (satu-satunya pintu UI ke SharedPreferences).
/// Hasil instance ter-cache oleh Riverpod dan mudah disubstitusi di test.
final prefsRepositoryProvider =
    Provider<PrefsRepository>((ref) => PrefsRepository());

/// Repository catatan lokal: satu-satunya pintu UI ke database SQLite.
final noteRepositoryProvider =
    Provider<NoteRepository>((ref) => NoteRepository());

/// Notifier daftar catatan lokal.
///
/// Seluruh mutasi (tambah/hapus) disimpan ke local dulu dengan dirty flag,
/// lalu provider di-invalidate agar UI tersegarkan (UI tidak menunggu sync).
class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() =>
      ref.watch(noteRepositoryProvider).fetchNotes();

  /// Tambah catatan baru (selalu dirty karena belum tersinkron).
  Future<void> addNote({required String title, String body = ''}) async {
    await ref.read(noteRepositoryProvider).addNote(title: title, body: body);
    ref.invalidate(notesProvider);
  }

  /// Hapus catatan berdasarkan ID.
  Future<void> deleteNote(int id) async {
    await ref.read(noteRepositoryProvider).deleteNote(id);
    ref.invalidate(notesProvider);
  }
}

/// Provider global daftar catatan (AsyncValue: loading/error/data).
///
/// `retry: null` mematikan auto-retry bawaan Riverpod 3 (10x backoff
/// hingga 6,4 detik per percobaan). Tanpa ini, error jaringan akan
/// menampilkan spinner lama sebelum masuk state error; lebih baik
/// langsung tampilkan AsyncError dengan tombol "Coba lagi".
final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  retry: (retryCount, error) => null,
);

/// Detail satu catatan berdasarkan ID.
/// Dibaca langsung dari repository lokal (bukan state halaman list),
/// sehingga halaman tetap valid bila dibuka lewat deep-link
/// (Refactoring Challenge #3).
final noteDetailProvider = FutureProvider.family<Note?, int>(
  (ref, id) {
    return ref.watch(noteRepositoryProvider).fetchNote(id);
  },
  retry: (retryCount, error) => null,
);

/// Jumlah catatan yang belum tersinkron (untuk badge antrean sync).
final dirtyCountProvider = FutureProvider<int>(
  (ref) => ref.watch(noteRepositoryProvider).countDirty(),
  retry: (retryCount, error) => null,
);

/// Toggle simulasi offline deterministik.
///
/// Dipakai demo & testing agar tidak bergantung kondisi Wi-Fi kelas:
/// saat aktif, aplikasi tidak melakukan panggilan jaringan sama sekali.
class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setForceOffline(bool value) => state = value;
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

/// Notifier cache posts dengan strategi cache-first.
class PostsCacheNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    // Cache-first: kembalikan cache lokal seketika; refresh jaringan
    // berjalan di background (lihat loadPostsCacheFirst).
    return loadPostsCacheFirst(online: !ref.read(forceOfflineProvider));
  }

  /// Segarkan cache dari jaringan. Saat offline/gagal, UI tetap
  /// menampilkan cache lama (layar tidak dikosongkan).
  Future<void> refresh() async {
    if (ref.read(forceOfflineProvider)) return;
    try {
      final posts = await fetchPostsRemote();
      await saveCachedPosts(posts);
      state = AsyncData(posts);
    } catch (_) {
      // Gagal (misal offline): pertahankan data lama bila ada.
      if (!state.hasValue) {
        state = AsyncError(
          Exception('Gagal memuat data (offline).'),
          StackTrace.empty,
        );
      }
    }
  }
}

final postsCacheProvider =
    AsyncNotifierProvider<PostsCacheNotifier, List<Post>>(
  PostsCacheNotifier.new,
  retry: (retryCount, error) => null,
);

/// Notifier antrean sinkronisasi catatan dirty.
///
/// State `AsyncValue<int>`: loading = sedang sync, data = jumlah tersinkron,
/// error = sinkronisasi ditunda/gagal (mis. sedang offline).
class SyncNotifier extends Notifier<AsyncValue<int>> {
  @override
  AsyncValue<int> build() => const AsyncData(0);

  /// Jalankan sinkronisasi. Saat offline, operasi ditunda — catatan tetap
  /// mengambang dengan dirty flag dan akan diproses saat online kembali.
  Future<void> runSync() async {
    if (state.isLoading) return; // cegah sinkronisasi ganda

    if (ref.read(forceOfflineProvider)) {
      state = AsyncError(
        Exception('Mode offline aktif. Catatan menunggu koneksi kembali.'),
        StackTrace.empty,
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final synced = await syncNotes(ref.read(noteRepositoryProvider));
      // Segarkan daftar catatan & badge setelah antrean diproses.
      ref.invalidate(notesProvider);
      ref.invalidate(dirtyCountProvider);
      return synced;
    });
  }
}

final syncProvider =
    NotifierProvider<SyncNotifier, AsyncValue<int>>(SyncNotifier.new);

/// Waktu aplikasi terakhir dibuka (ditampilkan di halaman Pengaturan).
final lastOpenedProvider = FutureProvider<String?>(
  (ref) => ref.watch(prefsRepositoryProvider).getLastOpened(),
  retry: (retryCount, error) => null,
);

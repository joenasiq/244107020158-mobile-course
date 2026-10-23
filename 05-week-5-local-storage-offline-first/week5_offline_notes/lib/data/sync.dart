import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import 'local/db.dart';
import 'local/post.dart';
import 'api_client.dart';
import 'repositories/note_repository.dart';

/// ============================================================================
/// Layer sinkronisasi & strategi cache-first (offline-first).
///
/// Dipisahkan dari repository agar NoteRepository tetap fokus pada CRUD
/// (Refactoring Challenge #2). Tiga mekanisme inti offline-first:
///  1. Cache-first read     -> loadPostsCacheFirst()
///  2. Dirty flag           -> flag pada model Note (diproses oleh syncNotes)
///  3. Antrean sinkronisasi -> syncNotes() memproses catatan dirty berurutan
///
/// Aturan konflik: last-write-wins berdasarkan kolom `updated_at` —
/// perubahan yang lebih baru dianggap pemenang.
/// ============================================================================

/// Membaca seluruh cache posts dari tabel `cached_posts`.
Future<List<Post>> readCachedPosts(
  {Future<Database> Function()? openDb}
) async {
  final db = await (openDb ?? openNotesDb)();
  final rows = await db.query('cached_posts', orderBy: 'id ASC');
  return rows
      .map((row) {
        final payload = row['payload'] as String? ?? '{}';
        return Post.fromJson(jsonDecode(payload));
      })
      .toList();
}

/// Menyimpan hasil terbaru ke cache (mengganti seluruh isi lama).
Future<void> saveCachedPosts(
  List<Post> posts, {
  Future<Database> Function()? openDb,
}) async {
  final db = await (openDb ?? openNotesDb)();
  final cachedAt = DateTime.now().toIso8601String();
  await db.transaction((txn) async {
    await txn.delete('cached_posts');
    for (final post in posts) {
      await txn.insert(
        'cached_posts',
        {
          'id': post.id,
          'payload': jsonEncode(post.toJson()),
          'cached_at': cachedAt,
        },
      );
    }
  });
}

/// Ambil posts terbaru dari jaringan melalui Dio.
Future<List<Post>> fetchPostsRemote({Dio? dio}) async {
  final client = dio ?? createDio();
  final response = await client.get<List>('/posts');
  final data = response.data ?? const [];
  return data.whereType<Map<String, dynamic>>().map(Post.fromJson).toList();
}

/// Cache-first: kembalikan cache lokal seketika agar UI tidak blank saat
/// offline, lalu segarkan dari jaringan di background dan simpan hasilnya
/// untuk kunjungan berikutnya.
Future<List<Post>> loadPostsCacheFirst({
  bool online = true,
  Future<Database> Function()? openDb,
  Dio? dio,
}) async {
  final cached = await readCachedPosts(openDb: openDb);

  // Jangan sentuh jaringan bila aplikasi sedang offline.
  if (online) {
    unawaited(_refreshInBackground(openDb: openDb, dio: dio));
  }
  return cached;
}

/// Refresh background: fetch Dio -> simpan ke cached_posts.
/// Kegagalan (offline) tidak dibalikkan ke UI; cache lama dipertahankan.
Future<void> _refreshInBackground({
  Future<Database> Function()? openDb,
  Dio? dio,
}) async {
  try {
    final posts = await fetchPostsRemote(dio: dio);
    await saveCachedPosts(posts, openDb: openDb);
  } catch (_) {
    // Gagal (offline/error jaringan): pertahankan cache lama,
    // akan dicoba lagi pada refresh berikutnya.
  }
}

/// Sinkronisasi catatan kotor (dirty) ke server.
///
/// Karena codelab ini belum punya backend tulis, "upload" disimulasikan
/// dengan delay 1 detik. Pada project nyata, setiap catatan dirty dikirim
/// ke REST API di sini (berurutan sesuai antrean), lalu ditandai bersih
/// hanya bila server menjawab 2xx.
///
/// Kembalikan jumlah catatan yang berhasil disinkronkan.
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;

  // Simulasi upload: pada project nyata, kirim tiap catatan dirty
  // ke REST API di sini, lalu tandai bersih bila server menjawab 2xx.
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}

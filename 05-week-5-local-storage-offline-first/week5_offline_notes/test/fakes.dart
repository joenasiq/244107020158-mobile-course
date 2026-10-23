import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/prefs.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';

/// Fake [NoteRepository] tanpa database sungguhan (tanpa sqflite).
///
/// Menyuntikkan `openDb` yang selalu gagal memastikan test tidak pernah
/// menyentuh SQLite asli; seluruh method di-override dengan data di memori.
class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({
    this.items = const [],
    this.throwError = false,
    this.fetchDelay,
  }) : super(
          openDb: () =>
              throw UnimplementedError('fake: tidak ada database sungguhan'),
        );

  List<Note> items;
  final bool throwError;

  /// Jeda simulasi untuk menguji state loading.
  final Duration? fetchDelay;

  @override
  Future<List<Note>> fetchNotes() async {
    if (fetchDelay != null) {
      await Future.delayed(fetchDelay!);
    }
    if (throwError) {
      throw Exception('db locked (simulasi)');
    }
    return [...items]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<Note?> fetchNote(int id) async {
    return items.where((note) => note.id == id).firstOrNull;
  }

  @override
  Future<Note> addNote({required String title, String body = ''}) async {
    final note = Note(
      id: (items.isEmpty ? 1 : (items.last.id ?? 0) + 1),
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    items = [...items, note];
    return note;
  }

  @override
  Future<void> deleteNote(int id) async {
    items = items.where((note) => note.id != id).toList();
  }

  @override
  Future<int> countDirty() async {
    return items.where((note) => note.dirty).length;
  }

  @override
  Future<void> markAllSynced() async {
    items = [
      for (final note in items)
        Note(
          id: note.id,
          title: note.title,
          body: note.body,
          updatedAt: note.updatedAt,
          dirty: false,
        ),
    ];
  }
}

/// Fake [PrefsRepository] dengan state di memori
/// (tanpa SharedPreferences asli).
class FakePrefsRepository extends PrefsRepository {
  bool darkMode = false;
  String? lastOpened;

  @override
  Future<bool> getDarkMode() async => darkMode;

  @override
  Future<void> setDarkMode(bool value) async => darkMode = value;

  @override
  Future<String?> getLastOpened() async => lastOpened;

  @override
  Future<void> markOpenedNow() async {
    lastOpened = DateTime.now().toIso8601String();
  }
}

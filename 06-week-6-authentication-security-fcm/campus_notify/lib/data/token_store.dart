// Penyimpanan token yang aman via flutter_secure_storage.
//
// Seluruh token hanya keluar-masuk lewat kelas ini.
// Token TIDAK PERNAH disimpan di SharedPreferences (tidak terenkripsi).
//
// Constructor menerima FlutterSecureStorage opsional agar test
// bisa menyuntikkan fake tanpa plugin asli.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  /// Simpan access + refresh token secara aman.
  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  /// Baca access token. Null bila belum login / sudah logout.
  Future<String?> readAccess() => _storage.read(key: _accessKey);

  /// Baca refresh token.
  Future<String?> readRefresh() => _storage.read(key: _refreshKey);

  /// Hapus semua token (logout).
  Future<void> clear() => _storage.deleteAll();
}

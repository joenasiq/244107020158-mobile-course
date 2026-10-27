/// Sesi autentikasi: access token + refresh token.
class AuthSession {
  const AuthSession({required this.access, required this.refresh});

  /// Access token berumur pendek (mis. 15 menit).
  /// Dikirim sebagai `Authorization: Bearer ...` di setiap request API.
  final String access;

  /// Refresh token berumur panjang (mis. 7 hari).
  /// Hanya disimpan di secure storage, tidak pernah di SharedPreferences.
  final String refresh;
}

/// Repository autentikasi (mock).
///
/// Pada production, ganti body method ini dengan panggilan ke
/// `FirebaseAuth.instance.signInWithEmailAndPassword` atau REST API sendiri.
/// Pola repository dan token refresh-nya identik — migrasi hanya mengganti
/// sumber token.
class AuthRepository {
  /// Login dengan email + password.
  /// Kembalikan sesi berisi access + refresh token.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    // Simulasi latency server.
    await Future.delayed(const Duration(milliseconds: 500));

    if (!email.contains('@') || password.length < 6) {
      throw Exception('Email atau kata sandi tidak valid');
    }

    // Simulasi JWT (jangan parse manual di production,
    // gunakan verifikasi server).
    return AuthSession(
      access: 'mock-access-for-$email',
      refresh: 'mock-refresh-for-$email',
    );
  }

  /// Tukar refresh token → access token baru.
  /// Lempar exception bila refresh token sudah kedaluwarsa.
  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) throw Exception('Refresh token hilang');
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}

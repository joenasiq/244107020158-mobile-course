import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/data/token_store.dart';

/// Fake TokenStore: menyimpan token di memori (tanpa flutter_secure_storage).
class FakeTokenStore extends TokenStore {
  FakeTokenStore() : super(storage: null);

  String? _access;
  String? _refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    _access = access;
    _refresh = refresh;
  }

  @override
  Future<String?> readAccess() async => _access;

  @override
  Future<String?> readRefresh() async => _refresh;

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}

/// Fake AuthRepository: login/refresh di memori (tanpa delay server).
class FakeAuthRepository extends AuthRepository {
  bool shouldThrow = false;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) throw Exception('Fake login error');
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Email atau kata sandi tidak valid');
    }
    return AuthSession(
      access: 'fake-access-for-$email',
      refresh: 'fake-refresh-for-$email',
    );
  }

  @override
  Future<String> refresh(String refreshToken) async {
    if (shouldThrow || refreshToken.isEmpty) {
      throw Exception('Refresh token hilang');
    }
    return 'fake-renewed-access';
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialStore {
  CredentialStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  String _passwordKey(String accountId) => 'account.$accountId.password';

  String _accessTokenKey(String accountId) => 'account.$accountId.accessToken';

  String _refreshTokenKey(String accountId) => 'account.$accountId.refreshToken';

  Future<void> savePassword(String accountId, String password) {
    return _storage.write(key: _passwordKey(accountId), value: password);
  }

  Future<String?> readPassword(String accountId) {
    return _storage.read(key: _passwordKey(accountId));
  }

  Future<void> saveOAuthTokens({
    required String accountId,
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey(accountId), value: accessToken);
    if (refreshToken != null) {
      await _storage.write(
        key: _refreshTokenKey(accountId),
        value: refreshToken,
      );
    }
  }

  Future<String?> readAccessToken(String accountId) {
    return _storage.read(key: _accessTokenKey(accountId));
  }

  Future<String?> readRefreshToken(String accountId) {
    return _storage.read(key: _refreshTokenKey(accountId));
  }

  Future<void> deleteForAccount(String accountId) async {
    await _storage.delete(key: _passwordKey(accountId));
    await _storage.delete(key: _accessTokenKey(accountId));
    await _storage.delete(key: _refreshTokenKey(accountId));
  }
}

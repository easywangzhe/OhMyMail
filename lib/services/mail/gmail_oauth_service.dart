import 'package:flutter_appauth/flutter_appauth.dart';

class GmailOAuthConfig {
  const GmailOAuthConfig({
    required this.clientId,
    required this.redirectUrl,
  });

  final String clientId;
  final String redirectUrl;
}

class GmailOAuthService {
  GmailOAuthService({
    FlutterAppAuth? appAuth,
    GmailOAuthConfig? config,
  })  : _appAuth = appAuth ?? const FlutterAppAuth(),
        _config = config;

  final FlutterAppAuth _appAuth;
  final GmailOAuthConfig? _config;

  bool get isConfigured {
    final config = _config;
    return config != null &&
        config.clientId.isNotEmpty &&
        config.redirectUrl.isNotEmpty;
  }

  Future<GmailOAuthTokens> signIn() async {
    final config = _config;
    if (config == null) {
      throw const GmailOAuthException(
        'Gmail OAuth is not configured. Add a Google OAuth client id first.',
      );
    }

    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        config.clientId,
        config.redirectUrl,
        discoveryUrl:
            'https://accounts.google.com/.well-known/openid-configuration',
        scopes: const [
          'openid',
          'email',
          'https://mail.google.com/',
        ],
        promptValues: const ['consent'],
      ),
    );
    final accessToken = result.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw const GmailOAuthException('Google did not return an access token.');
    }
    return GmailOAuthTokens(
      accessToken: accessToken,
      refreshToken: result.refreshToken,
    );
  }
}

class GmailOAuthTokens {
  const GmailOAuthTokens({
    required this.accessToken,
    this.refreshToken,
  });

  final String accessToken;
  final String? refreshToken;
}

class GmailOAuthException implements Exception {
  const GmailOAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

import 'desktop_service.dart';
import 'mail/gmail_oauth_service.dart';
import 'mail/mail_sync_service.dart';
import 'notification_service.dart';
import 'storage/credential_store.dart';
import 'storage/database_service.dart';

class AppServices {
  const AppServices({
    required this.database,
    required this.credentials,
    required this.mailSync,
    required this.notifications,
    required this.desktop,
    required this.gmailOAuth,
  });

  final DatabaseService database;
  final CredentialStore credentials;
  final MailSyncService mailSync;
  final NotificationService notifications;
  final DesktopService desktop;
  final GmailOAuthService gmailOAuth;

  static Future<AppServices> bootstrap() async {
    final database = await DatabaseService.open();
    final credentials = CredentialStore();
    final notifications = NotificationService();
    final desktop = DesktopService();
    await notifications.initialize();
    await desktop.initialize();

    const gmailClientId = String.fromEnvironment('GMAIL_CLIENT_ID');
    const gmailRedirectUrl = String.fromEnvironment('GMAIL_REDIRECT_URL');
    final gmailOAuth = GmailOAuthService(
      config: gmailClientId.isEmpty || gmailRedirectUrl.isEmpty
          ? null
          : const GmailOAuthConfig(
              clientId: gmailClientId,
              redirectUrl: gmailRedirectUrl,
            ),
    );

    final mailSync = MailSyncService(
      database: database,
      credentials: credentials,
    );
    return AppServices(
      database: database,
      credentials: credentials,
      mailSync: mailSync,
      notifications: notifications,
      desktop: desktop,
      gmailOAuth: gmailOAuth,
    );
  }
}

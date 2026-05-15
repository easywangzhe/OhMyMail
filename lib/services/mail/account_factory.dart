import '../../models/mail_account.dart';

class AccountFactory {
  static MailAccount gmail({
    required String id,
    required String email,
    required String displayName,
  }) {
    return MailAccount(
      id: id,
      email: email,
      displayName: displayName,
      type: MailAccountType.gmail,
      authType: MailAuthType.oauth2,
      imapHost: 'imap.gmail.com',
      imapPort: 993,
      security: MailSecurity.sslTls,
      enabled: true,
      createdAt: DateTime.now(),
    );
  }

  static MailAccount imap({
    required String id,
    required String email,
    required String displayName,
    required String host,
    required int port,
    required MailSecurity security,
    String? username,
  }) {
    return MailAccount(
      id: id,
      email: email,
      displayName: displayName,
      type: MailAccountType.imap,
      authType: MailAuthType.password,
      imapHost: host,
      imapPort: port,
      security: security,
      enabled: true,
      username: username,
      createdAt: DateTime.now(),
    );
  }
}

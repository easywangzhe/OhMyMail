import '../../models/mail_account.dart';

class MailProviderPreset {
  const MailProviderPreset({
    required this.id,
    required this.label,
    required this.host,
    required this.port,
    required this.security,
    this.gmail = false,
  });

  final String id;
  final String label;
  final String host;
  final int port;
  final MailSecurity security;
  final bool gmail;
}

const mailProviderPresets = [
  MailProviderPreset(
    id: 'gmail',
    label: 'Gmail',
    host: 'imap.gmail.com',
    port: 993,
    security: MailSecurity.sslTls,
    gmail: true,
  ),
  MailProviderPreset(
    id: '163',
    label: '163',
    host: 'imap.163.com',
    port: 993,
    security: MailSecurity.sslTls,
  ),
  MailProviderPreset(
    id: 'qq',
    label: 'QQ',
    host: 'imap.qq.com',
    port: 993,
    security: MailSecurity.sslTls,
  ),
  MailProviderPreset(
    id: 'linuxdo',
    label: 'Linux.do',
    host: 'mail.linux.do',
    port: 993,
    security: MailSecurity.sslTls,
  ),
  MailProviderPreset(
    id: 'custom',
    label: 'IMAP',
    host: '',
    port: 993,
    security: MailSecurity.sslTls,
  ),
];

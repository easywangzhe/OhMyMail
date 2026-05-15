import 'package:flutter_test/flutter_test.dart';
import 'package:oh_my_mail/models/mail_message.dart';

void main() {
  test('detects GitHub notification messages', () {
    final message = MailMessage(
      id: '1',
      accountId: 'account',
      folder: 'INBOX',
      uid: 1,
      messageId: '<1@example.com>',
      subject: '[repo] Issue updated',
      from: 'notifications@github.com',
      to: 'me@example.com',
      date: DateTime.utc(2026),
      snippet: 'Update',
      unread: true,
      hasAttachments: false,
      bodyCached: false,
    );

    expect(message.isGitHubNotification, isTrue);
  });
}

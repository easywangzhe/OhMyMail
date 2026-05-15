import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oh_my_mail/models/mail_message.dart';
import 'package:oh_my_mail/shared/date_formatters.dart';

void main() {
  testWidgets('renders a simple OhMyMail themed surface', (tester) async {
    final message = MailMessage(
      id: '1',
      accountId: 'account',
      folder: 'INBOX',
      uid: 1,
      messageId: '<1@example.com>',
      subject: 'Welcome to OhMyMail',
      from: 'hello@example.com',
      to: 'me@example.com',
      date: DateTime.now(),
      snippet: 'Your inbox is ready.',
      unread: true,
      hasAttachments: false,
      bodyCached: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('OhMyMail')),
          body: ListTile(
            leading: const Icon(Icons.mark_email_unread),
            title: Text(message.subject),
            subtitle: Text(formatMessageDate(message.date)),
          ),
        ),
      ),
    );

    expect(find.text('OhMyMail'), findsOneWidget);
    expect(find.text('Welcome to OhMyMail'), findsOneWidget);
    expect(find.byIcon(Icons.mark_email_unread), findsOneWidget);
  });
}

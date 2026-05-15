import 'dart:async';

import 'package:enough_mail/enough_mail.dart' hide MailAccount;

import '../../models/mail_account.dart';
import '../../models/mail_message.dart';
import '../storage/credential_store.dart';
import '../storage/database_service.dart';

class MailSyncService {
  MailSyncService({
    required DatabaseService database,
    required CredentialStore credentials,
  })  : _database = database,
        _credentials = credentials;

  final DatabaseService _database;
  final CredentialStore _credentials;
  final Map<String, Timer> _pollTimers = {};
  final StreamController<List<MailMessage>> _newMessagesController =
      StreamController<List<MailMessage>>.broadcast();

  Stream<List<MailMessage>> get newMessages => _newMessagesController.stream;

  Future<void> testConnection(MailAccount account) async {
    final client = await _connect(account);
    try {
      await client.selectInbox();
    } finally {
      await client.logout();
    }
  }

  Future<List<MailMessage>> syncInbox(MailAccount account) async {
    final client = await _connect(account);
    try {
      await client.selectInbox();
      final fetch = await client.fetchRecentMessages(
        messageCount: 40,
        criteria:
            '(UID FLAGS BODY.PEEK[HEADER.FIELDS (FROM TO SUBJECT DATE MESSAGE-ID)] BODYSTRUCTURE)',
      );
      final now = DateTime.now();
      final messages = fetch.messages.map((mime) {
        final uid = mime.uid ?? mime.sequenceId ?? mime.hashCode;
        return _mapMimeMessage(
          account: account,
          mime: mime,
          uid: uid,
          now: now,
        );
      }).toList();

      await _database.upsertMessages(messages);
      await _database.updateLastSync(account.id, now);
      await _database.pruneOlderThan(now.subtract(const Duration(days: 30)));
      return messages;
    } finally {
      await client.logout();
    }
  }

  Future<String> loadBody(MailAccount account, MailMessage message) async {
    if (message.bodyCached && message.body != null) return message.body!;

    final client = await _connect(account);
    try {
      await client.selectInbox();
      final fetch = await client.uidFetchMessage(
        message.uid,
        'BODY.PEEK[]',
      );
      final mime = fetch.messages.isEmpty ? null : fetch.messages.single;
      final body = mime == null ? '' : _extractBody(mime);
      await _database.updateMessageBody(message.id, body);
      return body;
    } finally {
      await client.logout();
    }
  }

  Future<void> markRead(MailAccount account, MailMessage message) async {
    final client = await _connect(account);
    try {
      await client.selectInbox();
      await client.uidMarkSeen(
        MessageSequence.fromId(message.uid, isUid: true),
      );
      await _database.markRead(message.id);
    } finally {
      await client.logout();
    }
  }

  Future<void> startListening(
    List<MailAccount> accounts, {
    Duration pollInterval = const Duration(minutes: 2),
  }) async {
    // This is the conservative fallback listener. It keeps the public service
    // contract stable while provider-specific IMAP IDLE handling is added.
    await stopListening();
    for (final account in accounts.where((item) => item.enabled)) {
      await _pollAccount(account);
      _pollTimers[account.id] = Timer.periodic(
        pollInterval,
        (_) => unawaited(_pollAccount(account)),
      );
    }
  }

  Future<void> stopListening() async {
    for (final timer in _pollTimers.values) {
      timer.cancel();
    }
    _pollTimers.clear();
  }

  Future<void> dispose() async {
    await stopListening();
    await _newMessagesController.close();
  }

  Future<void> _pollAccount(MailAccount account) async {
    try {
      final before = await _database.loadMessages(accountId: account.id);
      final knownIds = before.map((message) => message.id).toSet();
      final synced = await syncInbox(account);
      final fresh = synced
          .where((message) => message.unread && !knownIds.contains(message.id))
          .toList();
      if (fresh.isNotEmpty) {
        _newMessagesController.add(fresh);
      }
    } on Object {
      // Polling continues on the next tick; UI exposes explicit sync errors.
    }
  }

  Future<ImapClient> _connect(MailAccount account) async {
    final client = ImapClient(isLogEnabled: false);
    final useSsl = account.security == MailSecurity.sslTls;
    await client.connectToServer(
      account.imapHost,
      account.imapPort,
      isSecure: useSsl,
      timeout: const Duration(seconds: 20),
    );

    if (account.security == MailSecurity.startTls) {
      await client.startTls();
    }

    if (account.authType == MailAuthType.oauth2) {
      final accessToken = await _credentials.readAccessToken(account.id);
      if (accessToken == null || accessToken.isEmpty) {
        throw const MailSyncException('Missing OAuth access token.');
      }
      await client.authenticateWithOAuth2(account.loginName, accessToken);
    } else {
      final password = await _credentials.readPassword(account.id);
      if (password == null || password.isEmpty) {
        throw const MailSyncException('Missing mailbox authorization code.');
      }
      await client.login(account.loginName, password);
    }
    return client;
  }

  MailMessage _mapMimeMessage({
    required MailAccount account,
    required MimeMessage mime,
    required int uid,
    required DateTime now,
  }) {
    final subject = mime.decodeSubject() ?? '(No subject)';
    final from = mime.from?.map((address) => address.toString()).join(', ') ??
        'Unknown sender';
    final to = mime.to?.map((address) => address.toString()).join(', ') ?? '';
    final date = mime.decodeDate() ?? now;
    final messageId = mime.getHeaderValue('message-id');
    final id = '${account.id}:INBOX:$uid';
    final body = _extractBody(mime);
    return MailMessage(
      id: id,
      accountId: account.id,
      folder: 'INBOX',
      uid: uid,
      messageId: messageId,
      subject: subject,
      from: from,
      to: to,
      date: date,
      snippet: _snippet(body),
      unread: !mime.isSeen,
      hasAttachments: mime.hasAttachments(),
      bodyCached: body.isNotEmpty,
      body: body.isEmpty ? null : body,
      createdAt: now,
      updatedAt: now,
    );
  }

  String _extractBody(MimeMessage mime) {
    final plain = mime.decodeTextPlainPart();
    if (plain != null && plain.trim().isNotEmpty) return plain.trim();
    final html = mime.decodeTextHtmlPart();
    if (html == null) return '';
    return html
        .replaceAll(RegExp('<br\\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp('<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _snippet(String body) {
    final compact = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 160) return compact;
    return '${compact.substring(0, 157)}...';
  }

}

class MailSyncException implements Exception {
  const MailSyncException(this.message);

  final String message;

  @override
  String toString() => message;
}

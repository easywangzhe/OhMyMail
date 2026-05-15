import 'dart:async';

import 'package:flutter/widgets.dart';

import '../models/mail_account.dart';
import '../models/mail_message.dart';
import '../models/sync_status.dart';
import '../services/app_services.dart';
import '../services/mail/account_factory.dart';

class AppController extends ChangeNotifier {
  AppController(this._services);

  final AppServices _services;
  StreamSubscription<List<MailMessage>>? _newMailSubscription;

  List<MailAccount> _accounts = const [];
  List<MailMessage> _messages = const [];
  Map<String, int> _messageCountsByAccount = const {};
  SyncStatus _syncStatus = const SyncStatus.idle();
  bool _githubOnly = false;
  bool _unreadOnly = false;
  bool _attachmentsOnly = false;
  String _query = '';
  String? _selectedAccountId;
  MailMessage? _selectedMessage;
  Locale _locale = const Locale('zh');

  List<MailAccount> get accounts => _accounts;

  List<MailMessage> get messages => _messages;

  Map<String, int> get messageCountsByAccount => _messageCountsByAccount;

  SyncStatus get syncStatus => _syncStatus;

  bool get githubOnly => _githubOnly;

  bool get unreadOnly => _unreadOnly;

  bool get attachmentsOnly => _attachmentsOnly;

  String get query => _query;

  String? get selectedAccountId => _selectedAccountId;

  MailMessage? get selectedMessage => _selectedMessage;

  Locale get locale => _locale;

  int get unreadCount => _messages.where((message) => message.unread).length;

  int get unreadOnlyCount => _messages.where((message) => message.unread).length;

  int get attachmentCount =>
      _messages.where((message) => message.hasAttachments).length;

  bool get hasDesktopNotifications {
    return _services.notifications.supportsBackgroundNotifications;
  }

  Future<void> initialize() async {
    await _services.database.removeDemoData();
    await _services.credentials.deleteForAccount('demo-gmail');
    _newMailSubscription = _services.mailSync.newMessages.listen((messages) {
      for (final message in messages) {
        final account = _accountFor(message.accountId);
        if (account?.notificationsEnabled ?? true) {
          unawaited(_services.notifications.showNewMail(message));
        }
      }
      unawaited(refreshMessages());
    });
    await refreshAccounts();
    await refreshMessages();
    await _services.mailSync.startListening(_accounts);
  }

  Future<void> refreshAccounts() async {
    _accounts = await _services.database.loadAccounts();
    if (_selectedAccountId != null &&
        !_accounts.any((account) => account.id == _selectedAccountId)) {
      _selectedAccountId = null;
    }
    notifyListeners();
  }

  Future<void> refreshMessages() async {
    _messages = await _services.database.loadMessages(
      githubOnly: _githubOnly,
      unreadOnly: _unreadOnly,
      attachmentsOnly: _attachmentsOnly,
      accountId: _selectedAccountId,
      query: _query,
    );
    final unfiltered = await _services.database.loadMessages(
      githubOnly: _githubOnly,
      unreadOnly: _unreadOnly,
      attachmentsOnly: _attachmentsOnly,
      query: _query,
    );
    _messageCountsByAccount = {
      for (final account in _accounts)
        account.id: unfiltered
            .where((message) => message.accountId == account.id)
            .length,
    };
    if (_selectedMessage != null &&
        !_messages.any((message) => message.id == _selectedMessage!.id)) {
      _selectedMessage = null;
    } else if (_selectedMessage != null) {
      _selectedMessage = await _services.database.loadMessage(
        _selectedMessage!.id,
      );
    }
    notifyListeners();
  }

  Future<void> setGithubOnly(bool value) async {
    _githubOnly = value;
    await refreshMessages();
  }

  Future<void> setUnreadOnly(bool value) async {
    _unreadOnly = value;
    await refreshMessages();
  }

  Future<void> setAttachmentsOnly(bool value) async {
    _attachmentsOnly = value;
    await refreshMessages();
  }

  Future<void> setSelectedAccount(String? accountId) async {
    _selectedAccountId = accountId;
    await refreshMessages();
  }

  Future<void> search(String value) async {
    _query = value;
    await refreshMessages();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  Future<void> selectMessage(MailMessage message) async {
    _selectedMessage = message;
    notifyListeners();
    final account = _accountFor(message.accountId);
    if (account == null) return;

    if (!message.bodyCached) {
      final body = await _services.mailSync.loadBody(account, message);
      _selectedMessage = message.copyWith(body: body, bodyCached: true);
      notifyListeners();
    }
    if (message.unread) {
      await _services.mailSync.markRead(account, message);
      await refreshMessages();
    }
  }

  Future<void> syncNow() async {
    _syncStatus = SyncStatus(
      phase: SyncPhase.syncing,
      message: null,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    try {
      for (final account in _accounts.where((item) => item.enabled)) {
        try {
          await _services.mailSync.syncInbox(account);
        } on Object catch (error) {
          await _services.database.updateAccountError(
            account.id,
            error.toString(),
          );
        }
      }
      await refreshAccounts();
      await refreshMessages();
      _syncStatus = SyncStatus(
        phase: SyncPhase.polling,
        message: null,
        updatedAt: DateTime.now(),
      );
    } on Object catch (error) {
      _syncStatus = SyncStatus(
        phase: SyncPhase.error,
        message: error.toString(),
        updatedAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  Future<void> addImapAccount({
    required String email,
    required String displayName,
    required String host,
    required int port,
    required MailSecurity security,
    required String password,
    String? username,
  }) async {
    final id = 'imap-${DateTime.now().microsecondsSinceEpoch}';
    final account = AccountFactory.imap(
      id: id,
      email: email,
      displayName: displayName,
      host: host,
      port: port,
      security: security,
      username: username,
    );
    try {
      await _services.credentials.savePassword(id, password);
      await _services.mailSync.testConnection(account);
      await _services.database.upsertAccount(account);
      await refreshAccounts();
      await _services.mailSync.startListening(_accounts);
    } on Object {
      await _services.credentials.deleteForAccount(id);
      rethrow;
    }
  }

  Future<void> testAccount(MailAccount account) async {
    try {
      await _services.mailSync.testConnection(account);
      await _services.database.updateLastSync(
        account.id,
        account.lastSyncAt ?? DateTime.now(),
      );
    } on Object catch (error) {
      await _services.database.updateAccountError(account.id, error.toString());
      rethrow;
    } finally {
      await refreshAccounts();
    }
  }

  Future<void> updateImapAccount({
    required MailAccount account,
    required String displayName,
    required String host,
    required int port,
    required MailSecurity security,
    required bool enabled,
    required bool notificationsEnabled,
    String? username,
    String? password,
  }) async {
    final updated = account.copyWith(
      displayName: displayName,
      imapHost: host,
      imapPort: port,
      security: security,
      enabled: enabled,
      notificationsEnabled: notificationsEnabled,
      username: username,
      lastError: null,
      lastErrorAt: null,
    );
    if (password != null && password.isNotEmpty) {
      await _services.credentials.savePassword(account.id, password);
    }
    if (enabled) {
      await _services.mailSync.testConnection(updated);
    }
    await _services.database.upsertAccount(updated);
    await refreshAccounts();
    await refreshMessages();
    await _services.mailSync.startListening(_accounts);
  }

  Future<void> deleteAccount(MailAccount account) async {
    await _services.database.deleteAccount(account.id);
    await _services.credentials.deleteForAccount(account.id);
    if (_selectedAccountId == account.id) {
      _selectedAccountId = null;
    }
    await refreshAccounts();
    await refreshMessages();
    await _services.mailSync.startListening(_accounts);
  }

  Future<void> clearLocalCache() async {
    await _services.database.clearMessageCache();
    _selectedMessage = null;
    await refreshMessages();
  }

  Future<void> addGmailAccount({
    required String email,
    required String displayName,
  }) async {
    final id = 'gmail-${DateTime.now().microsecondsSinceEpoch}';
    final account = AccountFactory.gmail(
      id: id,
      email: email,
      displayName: displayName,
    );
    try {
      final tokens = await _services.gmailOAuth.signIn();
      await _services.credentials.saveOAuthTokens(
        accountId: id,
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await _services.mailSync.testConnection(account);
      await _services.database.upsertAccount(account);
      await refreshAccounts();
      await _services.mailSync.startListening(_accounts);
    } on Object {
      await _services.credentials.deleteForAccount(id);
      rethrow;
    }
  }

  Future<void> setLaunchAtStartup(bool enabled) {
    return _services.desktop.setLaunchAtStartup(enabled);
  }

  MailAccount? _accountFor(String accountId) {
    for (final account in _accounts) {
      if (account.id == accountId) return account;
    }
    return null;
  }

  @override
  void dispose() {
    unawaited(_newMailSubscription?.cancel());
    unawaited(_services.mailSync.dispose());
    super.dispose();
  }
}

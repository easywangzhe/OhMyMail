import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/mail_account.dart';
import '../../models/mail_message.dart';

class DatabaseService {
  DatabaseService._(this._db);

  final Database _db;

  static Future<DatabaseService> open() async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final documents = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documents.path, 'oh_my_mail.db');
    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE accounts (
            id TEXT PRIMARY KEY,
            email TEXT NOT NULL,
            display_name TEXT NOT NULL,
            type TEXT NOT NULL,
            auth_type TEXT NOT NULL,
            imap_host TEXT NOT NULL,
            imap_port INTEGER NOT NULL,
            security TEXT NOT NULL,
            enabled INTEGER NOT NULL,
            username TEXT,
            created_at TEXT,
            last_sync_at TEXT
          )
        ''');
        await database.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            account_id TEXT NOT NULL,
            folder TEXT NOT NULL,
            uid INTEGER NOT NULL,
            message_id TEXT,
            subject TEXT NOT NULL,
            from_address TEXT NOT NULL,
            to_address TEXT NOT NULL,
            date TEXT NOT NULL,
            snippet TEXT NOT NULL,
            unread INTEGER NOT NULL,
            has_attachments INTEGER NOT NULL,
            body_cached INTEGER NOT NULL,
            body TEXT,
            created_at TEXT,
            updated_at TEXT,
            UNIQUE(account_id, folder, uid)
          )
        ''');
        await database.execute(
          'CREATE INDEX idx_messages_date ON messages(date DESC)',
        );
        await database.execute(
          'CREATE INDEX idx_messages_account ON messages(account_id, folder)',
        );
      },
    );
    return DatabaseService._(db);
  }

  Future<List<MailAccount>> loadAccounts() async {
    final rows = await _db.query('accounts', orderBy: 'created_at ASC');
    return rows.map(MailAccount.fromMap).toList();
  }

  Future<void> upsertAccount(MailAccount account) async {
    await _db.insert(
      'accounts',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteAccount(String accountId) async {
    await _db.transaction((transaction) async {
      await transaction.delete(
        'messages',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );
      await transaction.delete(
        'accounts',
        where: 'id = ?',
        whereArgs: [accountId],
      );
    });
  }

  Future<void> updateLastSync(String accountId, DateTime at) async {
    await _db.update(
      'accounts',
      {'last_sync_at': at.toIso8601String()},
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  Future<List<MailMessage>> loadMessages({
    bool githubOnly = false,
    String? accountId,
    String query = '',
  }) async {
    final where = <String>[];
    final args = <Object?>[];
    if (accountId != null) {
      where.add('account_id = ?');
      args.add(accountId);
    }
    if (query.trim().isNotEmpty) {
      where.add('(subject LIKE ? OR from_address LIKE ? OR snippet LIKE ?)');
      final like = '%${query.trim()}%';
      args.addAll([like, like, like]);
    }

    final rows = await _db.query(
      'messages',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC',
      limit: 500,
    );
    final messages = rows.map(MailMessage.fromMap).toList();
    if (!githubOnly) return messages;
    return messages.where((message) => message.isGitHubNotification).toList();
  }

  Future<MailMessage?> loadMessage(String id) async {
    final rows = await _db.query(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return MailMessage.fromMap(rows.single);
  }

  Future<void> upsertMessages(List<MailMessage> messages) async {
    final batch = _db.batch();
    for (final message in messages) {
      batch.insert(
        'messages',
        message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> updateMessageBody(String id, String body) async {
    await _db.update(
      'messages',
      {
        'body': body,
        'body_cached': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markRead(String id) async {
    await _db.update(
      'messages',
      {'unread': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> unreadCount() async {
    final rows = await _db.rawQuery(
      'SELECT COUNT(*) AS total FROM messages WHERE unread = 1',
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<void> pruneOlderThan(DateTime cutoff) async {
    await _db.delete(
      'messages',
      where: 'date < ?',
      whereArgs: [cutoff.toIso8601String()],
    );
  }

  Future<void> removeDemoData() async {
    await _db.delete(
      'messages',
      where: 'account_id LIKE ? OR id LIKE ?',
      whereArgs: ['demo-%', 'demo-%'],
    );
    await _db.delete(
      'accounts',
      where: 'id LIKE ? OR email = ?',
      whereArgs: ['demo-%', 'demo@example.com'],
    );
  }

  Future<bool> isEmpty() async {
    final rows = await _db.rawQuery('SELECT COUNT(*) AS total FROM accounts');
    return (Sqflite.firstIntValue(rows) ?? 0) == 0;
  }
}

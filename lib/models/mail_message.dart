class MailMessage {
  const MailMessage({
    required this.id,
    required this.accountId,
    required this.folder,
    required this.uid,
    required this.messageId,
    required this.subject,
    required this.from,
    required this.to,
    required this.date,
    required this.snippet,
    required this.unread,
    required this.hasAttachments,
    required this.bodyCached,
    this.body,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String accountId;
  final String folder;
  final int uid;
  final String? messageId;
  final String subject;
  final String from;
  final String to;
  final DateTime date;
  final String snippet;
  final bool unread;
  final bool hasAttachments;
  final bool bodyCached;
  final String? body;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isGitHubNotification {
    final haystack = '${from.toLowerCase()} ${subject.toLowerCase()}';
    return haystack.contains('github') ||
        haystack.contains('notifications@github.com') ||
        haystack.contains('noreply@github.com');
  }

  MailMessage copyWith({
    String? id,
    String? accountId,
    String? folder,
    int? uid,
    String? messageId,
    String? subject,
    String? from,
    String? to,
    DateTime? date,
    String? snippet,
    bool? unread,
    bool? hasAttachments,
    bool? bodyCached,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MailMessage(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      folder: folder ?? this.folder,
      uid: uid ?? this.uid,
      messageId: messageId ?? this.messageId,
      subject: subject ?? this.subject,
      from: from ?? this.from,
      to: to ?? this.to,
      date: date ?? this.date,
      snippet: snippet ?? this.snippet,
      unread: unread ?? this.unread,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      bodyCached: bodyCached ?? this.bodyCached,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'folder': folder,
      'uid': uid,
      'message_id': messageId,
      'subject': subject,
      'from_address': from,
      'to_address': to,
      'date': date.toIso8601String(),
      'snippet': snippet,
      'unread': unread ? 1 : 0,
      'has_attachments': hasAttachments ? 1 : 0,
      'body_cached': bodyCached ? 1 : 0,
      'body': body,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static MailMessage fromMap(Map<String, Object?> map) {
    return MailMessage(
      id: map['id']! as String,
      accountId: map['account_id']! as String,
      folder: map['folder']! as String,
      uid: map['uid']! as int,
      messageId: map['message_id'] as String?,
      subject: map['subject']! as String,
      from: map['from_address']! as String,
      to: map['to_address']! as String,
      date: DateTime.parse(map['date']! as String),
      snippet: map['snippet']! as String,
      unread: (map['unread']! as int) == 1,
      hasAttachments: (map['has_attachments']! as int) == 1,
      bodyCached: (map['body_cached']! as int) == 1,
      body: map['body'] as String?,
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value as String);
  }
}

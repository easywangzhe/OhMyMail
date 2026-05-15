enum MailAccountType { gmail, imap }

enum MailAuthType { oauth2, password }

enum MailSecurity { sslTls, startTls, plain }

class MailAccount {
  const MailAccount({
    required this.id,
    required this.email,
    required this.displayName,
    required this.type,
    required this.authType,
    required this.imapHost,
    required this.imapPort,
    required this.security,
    required this.enabled,
    this.username,
    this.createdAt,
    this.lastSyncAt,
  });

  final String id;
  final String email;
  final String displayName;
  final MailAccountType type;
  final MailAuthType authType;
  final String imapHost;
  final int imapPort;
  final MailSecurity security;
  final bool enabled;
  final String? username;
  final DateTime? createdAt;
  final DateTime? lastSyncAt;

  String get loginName => username?.isNotEmpty == true ? username! : email;

  MailAccount copyWith({
    String? id,
    String? email,
    String? displayName,
    MailAccountType? type,
    MailAuthType? authType,
    String? imapHost,
    int? imapPort,
    MailSecurity? security,
    bool? enabled,
    String? username,
    DateTime? createdAt,
    DateTime? lastSyncAt,
  }) {
    return MailAccount(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      type: type ?? this.type,
      authType: authType ?? this.authType,
      imapHost: imapHost ?? this.imapHost,
      imapPort: imapPort ?? this.imapPort,
      security: security ?? this.security,
      enabled: enabled ?? this.enabled,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'type': type.name,
      'auth_type': authType.name,
      'imap_host': imapHost,
      'imap_port': imapPort,
      'security': security.name,
      'enabled': enabled ? 1 : 0,
      'username': username,
      'created_at': createdAt?.toIso8601String(),
      'last_sync_at': lastSyncAt?.toIso8601String(),
    };
  }

  static MailAccount fromMap(Map<String, Object?> map) {
    return MailAccount(
      id: map['id']! as String,
      email: map['email']! as String,
      displayName: map['display_name']! as String,
      type: MailAccountType.values.byName(map['type']! as String),
      authType: MailAuthType.values.byName(map['auth_type']! as String),
      imapHost: map['imap_host']! as String,
      imapPort: map['imap_port']! as int,
      security: MailSecurity.values.byName(map['security']! as String),
      enabled: (map['enabled']! as int) == 1,
      username: map['username'] as String?,
      createdAt: _parseDate(map['created_at']),
      lastSyncAt: _parseDate(map['last_sync_at']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value as String);
  }
}

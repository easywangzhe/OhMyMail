// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'OhMyMail';

  @override
  String get syncNow => '立即同步';

  @override
  String get addAccount => '添加账号';

  @override
  String get settings => '设置';

  @override
  String get all => '全部';

  @override
  String get github => 'GitHub';

  @override
  String get searchMail => '搜索邮件';

  @override
  String get accounts => '账号';

  @override
  String get allMailboxes => '所有邮箱';

  @override
  String get noAccounts => '还没有账号';

  @override
  String get addGmailOrImap => '添加 Gmail 或 IMAP 后开始同步。';

  @override
  String get ready => '就绪';

  @override
  String unreadCount(Object count) {
    return '$count 封未读';
  }

  @override
  String accountMessageCount(Object count) {
    return '$count 封';
  }

  @override
  String get selectMessage => '选择一封邮件阅读。';

  @override
  String get message => '邮件';

  @override
  String get attachment => '附件';

  @override
  String from(Object value) {
    return '发件人：$value';
  }

  @override
  String to(Object value) {
    return '收件人：$value';
  }

  @override
  String date(Object value) {
    return '日期：$value';
  }

  @override
  String get noMessagesYet => '暂无邮件';

  @override
  String get addAccountOrSync => '添加账号或同步收件箱。';

  @override
  String get addMailbox => '添加邮箱';

  @override
  String get editMailbox => '编辑邮箱';

  @override
  String get imap => 'IMAP';

  @override
  String get gmail => 'Gmail';

  @override
  String get emailAddress => '邮箱地址';

  @override
  String get displayName => '显示名称';

  @override
  String get username => '用户名';

  @override
  String get usernameHint => '留空则使用邮箱地址';

  @override
  String get imapHost => 'IMAP 服务器';

  @override
  String get imapHostHint => 'imap.example.com';

  @override
  String get port => '端口';

  @override
  String get security => '安全';

  @override
  String get sslTls => 'SSL/TLS';

  @override
  String get startTls => 'STARTTLS';

  @override
  String get plain => '明文';

  @override
  String get authorizationCodeOrAppPassword => '授权码或应用专用密码';

  @override
  String get leavePasswordBlankToKeep => '留空则保留当前授权码或应用专用密码';

  @override
  String get enabled => '启用账号';

  @override
  String get saveChanges => '保存修改';

  @override
  String get deleteAccount => '删除账号';

  @override
  String get deleteAccountConfirmTitle => '删除账号？';

  @override
  String get deleteAccountConfirmBody => '将删除该账号及本地缓存的邮件，邮箱服务器上的邮件不会被删除。';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get gmailImapAppPasswordHint =>
      'Gmail 使用 IMAP 时不能填写谷歌账号登录密码。请在 Google 账号开启两步验证后生成“应用专用密码”，或使用 Gmail OAuth 登录。';

  @override
  String get gmailImapAuthFailed =>
      'Gmail IMAP 登录失败。请确认已开启 IMAP，并使用 Google 账号的应用专用密码，而不是网页登录密码。';

  @override
  String get required => '必填';

  @override
  String get enterValidPort => '请输入有效端口';

  @override
  String get launchAtStartup => '桌面端开机自动监听';

  @override
  String get desktopListenerEnabledDescription => '桌面应用运行时会持续检查新邮件。';

  @override
  String get desktopListenerUnavailableDescription =>
      '仅 Windows 和 macOS 桌面版本可用。';

  @override
  String get mobileReminders => '移动端提醒';

  @override
  String get mobileReminderDescription => '移动端在应用打开或前台运行时同步并提醒。';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '中文';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get syncingInboxes => '正在同步收件箱...';

  @override
  String get checkingNewMail => '每隔几分钟检查新邮件';

  @override
  String get unknownSender => '未知发件人';

  @override
  String get noSubject => '无主题';
}

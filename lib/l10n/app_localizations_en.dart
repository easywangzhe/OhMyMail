// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OhMyMail';

  @override
  String get syncNow => 'Sync now';

  @override
  String get addAccount => 'Add account';

  @override
  String get settings => 'Settings';

  @override
  String get all => 'All';

  @override
  String get github => 'GitHub';

  @override
  String get searchMail => 'Search mail';

  @override
  String get accounts => 'Accounts';

  @override
  String get allMailboxes => 'All mailboxes';

  @override
  String get noAccounts => 'No accounts';

  @override
  String get addGmailOrImap => 'Add Gmail or IMAP to start syncing.';

  @override
  String get ready => 'Ready';

  @override
  String unreadCount(Object count) {
    return '$count unread';
  }

  @override
  String accountMessageCount(Object count) {
    return '$count messages';
  }

  @override
  String get selectMessage => 'Select a message to read.';

  @override
  String get message => 'Message';

  @override
  String get attachment => 'Attachment';

  @override
  String from(Object value) {
    return 'From: $value';
  }

  @override
  String to(Object value) {
    return 'To: $value';
  }

  @override
  String date(Object value) {
    return 'Date: $value';
  }

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get addAccountOrSync => 'Add an account or sync your inboxes.';

  @override
  String get addMailbox => 'Add mailbox';

  @override
  String get editMailbox => 'Edit mailbox';

  @override
  String get imap => 'IMAP';

  @override
  String get gmail => 'Gmail';

  @override
  String get emailAddress => 'Email address';

  @override
  String get displayName => 'Display name';

  @override
  String get username => 'Username';

  @override
  String get usernameHint => 'Leave blank to use email';

  @override
  String get imapHost => 'IMAP host';

  @override
  String get imapHostHint => 'imap.example.com';

  @override
  String get port => 'Port';

  @override
  String get security => 'Security';

  @override
  String get sslTls => 'SSL/TLS';

  @override
  String get startTls => 'STARTTLS';

  @override
  String get plain => 'Plain';

  @override
  String get authorizationCodeOrAppPassword =>
      'Authorization code or app password';

  @override
  String get leavePasswordBlankToKeep =>
      'Leave blank to keep the current authorization code or app password';

  @override
  String get enabled => 'Enable account';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirmTitle => 'Delete account?';

  @override
  String get deleteAccountConfirmBody =>
      'This removes the account and locally cached mail. Messages on the mail server are not deleted.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get gmailImapAppPasswordHint =>
      'Gmail IMAP does not accept your normal Google password. Enable 2-Step Verification and generate an app password, or use Gmail OAuth sign-in.';

  @override
  String get gmailImapAuthFailed =>
      'Gmail IMAP sign-in failed. Confirm IMAP is enabled and use a Google app password instead of your web sign-in password.';

  @override
  String get required => 'Required';

  @override
  String get enterValidPort => 'Enter a valid port';

  @override
  String get launchAtStartup => 'Launch desktop listener at startup';

  @override
  String get desktopListenerEnabledDescription =>
      'Keeps checking mail while the desktop app is running.';

  @override
  String get desktopListenerUnavailableDescription =>
      'Available on Windows and macOS desktop builds.';

  @override
  String get mobileReminders => 'Mobile reminders';

  @override
  String get mobileReminderDescription =>
      'Mobile builds sync and notify while the app is open or foregrounded.';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Chinese';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get syncingInboxes => 'Syncing inboxes...';

  @override
  String get checkingNewMail => 'Checking for new mail every few minutes';

  @override
  String get unknownSender => 'Unknown sender';

  @override
  String get noSubject => 'No subject';
}

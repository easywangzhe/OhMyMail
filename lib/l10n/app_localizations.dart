import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'OhMyMail'**
  String get appTitle;

  /// No description provided for @syncNow.
  ///
  /// In zh, this message translates to:
  /// **'立即同步'**
  String get syncNow;

  /// No description provided for @addAccount.
  ///
  /// In zh, this message translates to:
  /// **'添加账号'**
  String get addAccount;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @all.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get all;

  /// No description provided for @github.
  ///
  /// In zh, this message translates to:
  /// **'GitHub'**
  String get github;

  /// No description provided for @searchMail.
  ///
  /// In zh, this message translates to:
  /// **'搜索邮件'**
  String get searchMail;

  /// No description provided for @accounts.
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get accounts;

  /// No description provided for @allMailboxes.
  ///
  /// In zh, this message translates to:
  /// **'所有邮箱'**
  String get allMailboxes;

  /// No description provided for @mailProvider.
  ///
  /// In zh, this message translates to:
  /// **'邮箱服务商'**
  String get mailProvider;

  /// No description provided for @noAccounts.
  ///
  /// In zh, this message translates to:
  /// **'还没有账号'**
  String get noAccounts;

  /// No description provided for @addGmailOrImap.
  ///
  /// In zh, this message translates to:
  /// **'添加 Gmail 或 IMAP 后开始同步。'**
  String get addGmailOrImap;

  /// No description provided for @ready.
  ///
  /// In zh, this message translates to:
  /// **'就绪'**
  String get ready;

  /// No description provided for @unreadCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 封未读'**
  String unreadCount(Object count);

  /// No description provided for @accountMessageCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 封'**
  String accountMessageCount(Object count);

  /// No description provided for @selectMessage.
  ///
  /// In zh, this message translates to:
  /// **'选择一封邮件阅读。'**
  String get selectMessage;

  /// No description provided for @unread.
  ///
  /// In zh, this message translates to:
  /// **'未读'**
  String get unread;

  /// No description provided for @hasAttachments.
  ///
  /// In zh, this message translates to:
  /// **'有附件'**
  String get hasAttachments;

  /// No description provided for @message.
  ///
  /// In zh, this message translates to:
  /// **'邮件'**
  String get message;

  /// No description provided for @attachment.
  ///
  /// In zh, this message translates to:
  /// **'附件'**
  String get attachment;

  /// No description provided for @cachedBody.
  ///
  /// In zh, this message translates to:
  /// **'已缓存正文'**
  String get cachedBody;

  /// No description provided for @attachmentNotice.
  ///
  /// In zh, this message translates to:
  /// **'当前版本会识别附件状态，附件下载将在后续版本提供。'**
  String get attachmentNotice;

  /// No description provided for @from.
  ///
  /// In zh, this message translates to:
  /// **'发件人：{value}'**
  String from(Object value);

  /// No description provided for @to.
  ///
  /// In zh, this message translates to:
  /// **'收件人：{value}'**
  String to(Object value);

  /// No description provided for @date.
  ///
  /// In zh, this message translates to:
  /// **'日期：{value}'**
  String date(Object value);

  /// No description provided for @noMessagesYet.
  ///
  /// In zh, this message translates to:
  /// **'暂无邮件'**
  String get noMessagesYet;

  /// No description provided for @addAccountOrSync.
  ///
  /// In zh, this message translates to:
  /// **'添加账号或同步收件箱。'**
  String get addAccountOrSync;

  /// No description provided for @addMailbox.
  ///
  /// In zh, this message translates to:
  /// **'添加邮箱'**
  String get addMailbox;

  /// No description provided for @editMailbox.
  ///
  /// In zh, this message translates to:
  /// **'编辑邮箱'**
  String get editMailbox;

  /// No description provided for @imap.
  ///
  /// In zh, this message translates to:
  /// **'IMAP'**
  String get imap;

  /// No description provided for @gmail.
  ///
  /// In zh, this message translates to:
  /// **'Gmail'**
  String get gmail;

  /// No description provided for @emailAddress.
  ///
  /// In zh, this message translates to:
  /// **'邮箱地址'**
  String get emailAddress;

  /// No description provided for @displayName.
  ///
  /// In zh, this message translates to:
  /// **'显示名称'**
  String get displayName;

  /// No description provided for @username.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In zh, this message translates to:
  /// **'留空则使用邮箱地址'**
  String get usernameHint;

  /// No description provided for @imapHost.
  ///
  /// In zh, this message translates to:
  /// **'IMAP 服务器'**
  String get imapHost;

  /// No description provided for @imapHostHint.
  ///
  /// In zh, this message translates to:
  /// **'imap.example.com'**
  String get imapHostHint;

  /// No description provided for @port.
  ///
  /// In zh, this message translates to:
  /// **'端口'**
  String get port;

  /// No description provided for @security.
  ///
  /// In zh, this message translates to:
  /// **'安全'**
  String get security;

  /// No description provided for @sslTls.
  ///
  /// In zh, this message translates to:
  /// **'SSL/TLS'**
  String get sslTls;

  /// No description provided for @startTls.
  ///
  /// In zh, this message translates to:
  /// **'STARTTLS'**
  String get startTls;

  /// No description provided for @plain.
  ///
  /// In zh, this message translates to:
  /// **'明文'**
  String get plain;

  /// No description provided for @authorizationCodeOrAppPassword.
  ///
  /// In zh, this message translates to:
  /// **'授权码或应用专用密码'**
  String get authorizationCodeOrAppPassword;

  /// No description provided for @leavePasswordBlankToKeep.
  ///
  /// In zh, this message translates to:
  /// **'留空则保留当前授权码或应用专用密码'**
  String get leavePasswordBlankToKeep;

  /// No description provided for @enabled.
  ///
  /// In zh, this message translates to:
  /// **'启用账号'**
  String get enabled;

  /// No description provided for @saveChanges.
  ///
  /// In zh, this message translates to:
  /// **'保存修改'**
  String get saveChanges;

  /// No description provided for @deleteAccount.
  ///
  /// In zh, this message translates to:
  /// **'删除账号'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除账号？'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmBody.
  ///
  /// In zh, this message translates to:
  /// **'将删除该账号及本地缓存的邮件，邮箱服务器上的邮件不会被删除。'**
  String get deleteAccountConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @gmailImapAppPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'Gmail 使用 IMAP 时不能填写谷歌账号登录密码。请在 Google 账号开启两步验证后生成“应用专用密码”，或使用 Gmail OAuth 登录。'**
  String get gmailImapAppPasswordHint;

  /// No description provided for @gmailImapAuthFailed.
  ///
  /// In zh, this message translates to:
  /// **'Gmail IMAP 登录失败。请确认已开启 IMAP，并使用 Google 账号的应用专用密码，而不是网页登录密码。'**
  String get gmailImapAuthFailed;

  /// No description provided for @accountNotifications.
  ///
  /// In zh, this message translates to:
  /// **'该账号新邮件提醒'**
  String get accountNotifications;

  /// No description provided for @testConnection.
  ///
  /// In zh, this message translates to:
  /// **'测试连接'**
  String get testConnection;

  /// No description provided for @connectionOk.
  ///
  /// In zh, this message translates to:
  /// **'连接测试通过。'**
  String get connectionOk;

  /// No description provided for @lastSync.
  ///
  /// In zh, this message translates to:
  /// **'上次同步：{value}'**
  String lastSync(Object value);

  /// No description provided for @accountError.
  ///
  /// In zh, this message translates to:
  /// **'错误：{value}'**
  String accountError(Object value);

  /// No description provided for @required.
  ///
  /// In zh, this message translates to:
  /// **'必填'**
  String get required;

  /// No description provided for @enterValidPort.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效端口'**
  String get enterValidPort;

  /// No description provided for @launchAtStartup.
  ///
  /// In zh, this message translates to:
  /// **'桌面端开机自动监听'**
  String get launchAtStartup;

  /// No description provided for @desktopListenerEnabledDescription.
  ///
  /// In zh, this message translates to:
  /// **'桌面应用运行时会持续检查新邮件。'**
  String get desktopListenerEnabledDescription;

  /// No description provided for @desktopListenerUnavailableDescription.
  ///
  /// In zh, this message translates to:
  /// **'仅 Windows 和 macOS 桌面版本可用。'**
  String get desktopListenerUnavailableDescription;

  /// No description provided for @mobileReminders.
  ///
  /// In zh, this message translates to:
  /// **'移动端提醒'**
  String get mobileReminders;

  /// No description provided for @mobileReminderDescription.
  ///
  /// In zh, this message translates to:
  /// **'移动端在应用打开或前台运行时同步并提醒。'**
  String get mobileReminderDescription;

  /// No description provided for @clearCache.
  ///
  /// In zh, this message translates to:
  /// **'清除本地邮件缓存'**
  String get clearCache;

  /// No description provided for @clearCacheDescription.
  ///
  /// In zh, this message translates to:
  /// **'只删除本地缓存，不会删除邮箱服务器上的邮件。'**
  String get clearCacheDescription;

  /// No description provided for @localSecurity.
  ///
  /// In zh, this message translates to:
  /// **'本地安全'**
  String get localSecurity;

  /// No description provided for @localSecurityDescription.
  ///
  /// In zh, this message translates to:
  /// **'凭据已存入系统安全存储；数据库加密和应用锁将在后续版本提供。'**
  String get localSecurityDescription;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get languageSystem;

  /// No description provided for @languageChinese.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @syncingInboxes.
  ///
  /// In zh, this message translates to:
  /// **'正在同步收件箱...'**
  String get syncingInboxes;

  /// No description provided for @checkingNewMail.
  ///
  /// In zh, this message translates to:
  /// **'每隔几分钟检查新邮件'**
  String get checkingNewMail;

  /// No description provided for @unknownSender.
  ///
  /// In zh, this message translates to:
  /// **'未知发件人'**
  String get unknownSender;

  /// No description provided for @noSubject.
  ///
  /// In zh, this message translates to:
  /// **'无主题'**
  String get noSubject;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

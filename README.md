# OhMyMail

OhMyMail is a local-first Flutter mail manager for Android, iOS, Windows, and macOS. The first version focuses on multiple inboxes, foreground/mobile reminders, desktop notifications while the app is running, 30-day local message indexing, on-demand body caching, and GitHub notification filtering.

## Current Implementation

- Flutter shared UI with responsive desktop and mobile layouts.
- Gmail account shape using OAuth2/XOAUTH2, with a configuration placeholder for your Google OAuth client.
- Generic IMAP account setup for 163, QQ, Linux.do/Roundcube-backed mailboxes, and other IMAP servers.
- Secure credential storage for app passwords, authorization codes, and OAuth tokens.
- SQLite message cache with account metadata, unread status, snippets, attachment presence, and cached bodies.
- Local notifications for new mail and desktop startup/tray integration wrappers.
- Conservative desktop listener implemented with periodic IMAP checks; the service boundary is ready for provider-specific IMAP IDLE.

## Local Setup

This workspace did not have Flutter installed during implementation, so the generated Dart code was not compiled locally.

1. Install Flutter 3.24 or newer and enable target platforms:

   ```powershell
   flutter config --enable-windows-desktop --enable-macos-desktop
   ```

2. Generate platform folders in this repo:

   ```powershell
   flutter create --platforms=android,ios,windows,macos .
   ```

3. Fetch dependencies and run checks:

   ```powershell
   flutter pub get
   flutter analyze
   flutter test
   flutter run -d windows
   ```

4. For Gmail, pass your OAuth configuration at run time:

   ```powershell
   flutter run -d windows --dart-define=GMAIL_CLIENT_ID=your-client-id --dart-define=GMAIL_REDIRECT_URL=your-redirect-url
   ```

## Mail Account Notes

- Gmail requires a Google OAuth client ID and redirect URL. Wire those values into `GmailOAuthService` before using the Gmail button in production.
- 163 and QQ usually require enabling IMAP/SMTP in their web settings and using an authorization code or app password.
- Roundcube is a webmail client, not a mailbox protocol. Linux.do mail can be added if the underlying mailbox exposes IMAP settings.
- GitHub is treated as notification mail sent into a connected mailbox, not as a standalone mailbox provider.

## First-Version Limits

- No send, reply, forward, contacts, or full attachment downloads.
- iOS and Android only promise sync/notifications while the app is open or foregrounded.
- Desktop checks mail while the app is running and can be configured for startup launch. IMAP IDLE should replace the polling internals once validated against target providers.

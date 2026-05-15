import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../models/mail_account.dart';
import '../../models/mail_message.dart';
import '../../models/sync_status.dart';
import '../../shared/date_formatters.dart';
import '../accounts/add_account_sheet.dart';
import '../settings/settings_sheet.dart';

class MailHomePage extends StatelessWidget {
  const MailHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: l10n.syncNow,
            onPressed: controller.syncStatus.phase == SyncPhase.syncing
                ? null
                : () => controller.syncNow(),
            icon: const Icon(Icons.sync),
          ),
          IconButton(
            tooltip: l10n.addAccount,
            onPressed: () => showAddAccountSheet(context),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            tooltip: l10n.settings,
            onPressed: () => showSettingsSheet(context),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 840) {
            return _MobileMailView(controller: controller);
          }
          return _DesktopMailView(controller: controller);
        },
      ),
    );
  }
}

class _DesktopMailView extends StatelessWidget {
  const _DesktopMailView({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 260,
          child: _Sidebar(controller: controller),
        ),
        const VerticalDivider(width: 1),
        SizedBox(
          width: 420,
          child: _MessageList(controller: controller),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _MessageDetail(message: controller.selectedMessage),
        ),
      ],
    );
  }
}

class _MobileMailView extends StatelessWidget {
  const _MobileMailView({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _MessageList(
      controller: controller,
      onOpen: (message) async {
        await controller.selectMessage(message);
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              appBar: AppBar(title: Text(AppLocalizations.of(context)!.message)),
              body: _MessageDetail(message: controller.selectedMessage),
            ),
          ),
        );
      },
      header: _Sidebar(controller: controller, compact: true),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.controller,
    this.compact = false,
  });

  final AppController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final status = controller.syncStatus;
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _UnreadSummary(count: controller.unreadCount),
        const SizedBox(height: 16),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(
              value: false,
              icon: const Icon(Icons.all_inbox_outlined),
              label: Text(l10n.all),
            ),
            ButtonSegment(
              value: true,
              icon: const Icon(Icons.code),
              label: Text(l10n.github),
            ),
          ],
          selected: {controller.githubOnly},
          onSelectionChanged: (value) => controller.setGithubOnly(value.first),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              avatar: const Icon(Icons.mark_email_unread_outlined, size: 18),
              label: Text(l10n.unread),
              selected: controller.unreadOnly,
              onSelected: controller.setUnreadOnly,
            ),
            FilterChip(
              avatar: const Icon(Icons.attach_file, size: 18),
              label: Text(l10n.hasAttachments),
              selected: controller.attachmentsOnly,
              onSelected: controller.setAttachmentsOnly,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SearchBar(
          hintText: l10n.searchMail,
          leading: const Icon(Icons.search),
          onChanged: controller.search,
        ),
        const SizedBox(height: 20),
        Text(l10n.accounts, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          selected: controller.selectedAccountId == null,
          leading: const Icon(Icons.all_inbox_outlined),
          title: Text(l10n.allMailboxes),
          subtitle: Text(
            l10n.accountMessageCount(
              controller.messageCountsByAccount.values.fold<int>(
                0,
                (sum, count) => sum + count,
              ),
            ),
          ),
          onTap: () => controller.setSelectedAccount(null),
        ),
        for (final account in controller.accounts)
          ListTile(
            contentPadding: EdgeInsets.zero,
            selected: controller.selectedAccountId == account.id,
            onTap: () => controller.setSelectedAccount(account.id),
            leading: Icon(
              account.type.name == 'gmail'
                  ? Icons.alternate_email
                  : Icons.mail_outline,
            ),
            title: Text(account.displayName),
            subtitle: _AccountSubtitle(account: account),
            isThreeLine: account.lastError != null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AccountCountBadge(
                  count: controller.messageCountsByAccount[account.id] ?? 0,
                  enabled: account.enabled,
                ),
                IconButton(
                  tooltip: AppLocalizations.of(context)!.editMailbox,
                  onPressed: () => showAddAccountSheet(
                    context,
                    account: account,
                  ),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            dense: false,
          ),
        if (controller.accounts.isEmpty)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.mail_outline),
            title: Text(l10n.noAccounts),
            subtitle: Text(l10n.addGmailOrImap),
          ),
        if (!compact) ...[
          const SizedBox(height: 20),
          _StatusBanner(status: status),
        ],
      ],
    );
  }
}

class _AccountSubtitle extends StatelessWidget {
  const _AccountSubtitle({required this.account});

  final MailAccount account;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final error = account.lastError;
    final lastSyncAt = account.lastSyncAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(account.email),
        if (error != null && error.isNotEmpty)
          Text(
            l10n.accountError(error),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          )
        else if (lastSyncAt != null)
          Text(l10n.lastSync(formatMessageDate(lastSyncAt))),
      ],
    );
  }
}

class _AccountCountBadge extends StatelessWidget {
  const _AccountCountBadge({
    required this.count,
    required this.enabled,
  });

  final int count;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(width: 8),
        Icon(
          enabled ? Icons.check_circle : Icons.pause_circle_outline,
          color: enabled ? Colors.green : colorScheme.outline,
          size: 18,
        ),
      ],
    );
  }
}

class _UnreadSummary extends StatelessWidget {
  const _UnreadSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.mark_email_unread_outlined,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.unreadCount(count),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isError = status.phase == SyncPhase.error;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: isError ? colorScheme.error : colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.sensors,
              size: 20,
              color: isError ? colorScheme.error : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                status.message ?? _statusText(context, status.phase),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.controller,
    this.onOpen,
    this.header,
  });

  final AppController controller;
  final Future<void> Function(MailMessage message)? onOpen;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final messages = controller.messages;
    return Column(
      children: [
        if (header != null) SizedBox(height: 250, child: header),
        if (controller.syncStatus.phase == SyncPhase.syncing)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: messages.isEmpty
              ? const _EmptyInbox()
              : ListView.separated(
                  itemCount: messages.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _MessageTile(
                      message: message,
                      selected: controller.selectedMessage?.id == message.id,
                      onTap: () async {
                        if (onOpen != null) {
                          await onOpen!(message);
                        } else {
                          await controller.selectMessage(message);
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

String _statusText(BuildContext context, SyncPhase phase) {
  final l10n = AppLocalizations.of(context)!;
  return switch (phase) {
    SyncPhase.syncing => l10n.syncingInboxes,
    SyncPhase.polling => l10n.checkingNewMail,
    SyncPhase.error => l10n.ready,
    SyncPhase.idle => l10n.ready,
  };
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.message,
    required this.selected,
    required this.onTap,
  });

  final MailMessage message;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colorScheme.secondaryContainer : Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          message.unread ? Icons.mark_email_unread : Icons.drafts_outlined,
          color: message.unread ? colorScheme.primary : null,
        ),
        title: Text(
          message.subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: message.unread ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.from,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              message.snippet,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(formatMessageDate(message.date)),
            if (message.hasAttachments)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.attach_file, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageDetail extends StatelessWidget {
  const _MessageDetail({required this.message});

  final MailMessage? message;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    if (message == null) {
      return Center(
        child: Text(AppLocalizations.of(context)!.selectMessage),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (message.isGitHubNotification)
              Chip(
                avatar: const Icon(Icons.code, size: 18),
                label: Text(AppLocalizations.of(context)!.github),
              ),
            if (message.hasAttachments)
              Chip(
                avatar: const Icon(Icons.attach_file, size: 18),
                label: Text(AppLocalizations.of(context)!.attachment),
              ),
            if (message.bodyCached)
              Chip(
                avatar: const Icon(Icons.offline_pin_outlined, size: 18),
                label: Text(AppLocalizations.of(context)!.cachedBody),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          message.subject,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.from(message.from)),
        Text(AppLocalizations.of(context)!.to(message.to)),
        Text(AppLocalizations.of(context)!.date(formatMessageDate(message.date))),
        const Divider(height: 32),
        if (message.hasAttachments) ...[
          _InfoBanner(text: AppLocalizations.of(context)!.attachmentNotice),
          const SizedBox(height: 16),
        ],
        SelectableText(
          message.body ?? message.snippet,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.noMessagesYet,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(AppLocalizations.of(context)!.addAccountOrSync),
          ],
        ),
      ),
    );
  }
}

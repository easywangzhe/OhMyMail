import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../models/mail_account.dart';

Future<void> showAddAccountSheet(
  BuildContext context, {
  MailAccount? account,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => AddAccountSheet(account: account),
  );
}

class AddAccountSheet extends StatefulWidget {
  const AddAccountSheet({super.key, this.account});

  final MailAccount? account;

  @override
  State<AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<AddAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _displayName = TextEditingController();
  final _username = TextEditingController();
  final _host = TextEditingController();
  final _port = TextEditingController(text: '993');
  final _password = TextEditingController();
  MailSecurity _security = MailSecurity.sslTls;
  bool _isGmail = false;
  bool _enabled = true;
  bool _submitting = false;
  String? _error;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    if (account == null) return;
    _email.text = account.email;
    _displayName.text = account.displayName;
    _username.text = account.username ?? '';
    _host.text = account.imapHost;
    _port.text = account.imapPort.toString();
    _security = account.security;
    _enabled = account.enabled;
    _isGmail = account.imapHost == 'imap.gmail.com';
  }

  @override
  void dispose() {
    _email.dispose();
    _displayName.dispose();
    _username.dispose();
    _host.dispose();
    _port.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              _isEditing ? l10n.editMailbox : l10n.addMailbox,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (!_isEditing)
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.mail_outline),
                    label: Text(l10n.imap),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.alternate_email),
                    label: Text(l10n.gmail),
                  ),
                ],
                selected: {_isGmail},
                onSelectionChanged: (value) {
                  setState(() {
                    _isGmail = value.first;
                    if (_isGmail) {
                      _host.text = 'imap.gmail.com';
                      _port.text = '993';
                      _security = MailSecurity.sslTls;
                    }
                  });
                },
              ),
            if (_isEditing) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.power_settings_new),
                title: Text(l10n.enabled),
                value: _enabled,
                onChanged: (value) => setState(() => _enabled = value),
              ),
            ],
            if (_isGmail) ...[
              const SizedBox(height: 12),
              _InfoBanner(text: l10n.gmailImapAppPasswordHint),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              decoration: InputDecoration(
                labelText: l10n.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              enabled: !_isEditing,
              keyboardType: TextInputType.emailAddress,
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _displayName,
              decoration: InputDecoration(
                labelText: l10n.displayName,
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _username,
              decoration: InputDecoration(
                labelText: l10n.username,
                hintText: l10n.usernameHint,
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            if (!_isGmail) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _host,
                decoration: InputDecoration(
                  labelText: l10n.imapHost,
                  hintText: l10n.imapHostHint,
                  prefixIcon: const Icon(Icons.dns_outlined),
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _port,
                      decoration: InputDecoration(
                        labelText: l10n.port,
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsed = int.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return l10n.enterValidPort;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<MailSecurity>(
                      initialValue: _security,
                      decoration: InputDecoration(
                        labelText: l10n.security,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: MailSecurity.sslTls,
                          child: Text(l10n.sslTls),
                        ),
                        DropdownMenuItem(
                          value: MailSecurity.startTls,
                          child: Text(l10n.startTls),
                        ),
                        DropdownMenuItem(
                          value: MailSecurity.plain,
                          child: Text(l10n.plain),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _security = value);
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              decoration: InputDecoration(
                labelText: l10n.authorizationCodeOrAppPassword,
                helperText: _isEditing ? l10n.leavePasswordBlankToKeep : null,
                prefixIcon: const Icon(Icons.key_outlined),
              ),
              obscureText: true,
              validator: _isEditing ? null : _required,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_isEditing ? Icons.save_outlined : Icons.add),
              label: Text(_isEditing ? l10n.saveChanges : l10n.addAccount),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _submitting ? null : _delete,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.deleteAccount),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.required;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final controller = context.read<AppController>();
    final gmailImapAuthFailed =
        AppLocalizations.of(context)!.gmailImapAuthFailed;
    try {
      if (_isGmail) {
        if (_isEditing) {
          await controller.updateImapAccount(
            account: widget.account!,
            displayName: _displayName.text.trim(),
            host: 'imap.gmail.com',
            port: 993,
            security: MailSecurity.sslTls,
            enabled: _enabled,
            password: _password.text.trim().isEmpty ? null : _password.text,
            username:
                _username.text.trim().isEmpty ? null : _username.text.trim(),
          );
        } else {
          await controller.addImapAccount(
            email: _email.text.trim(),
            displayName: _displayName.text.trim(),
            host: 'imap.gmail.com',
            port: 993,
            security: MailSecurity.sslTls,
            password: _password.text,
            username:
                _username.text.trim().isEmpty ? null : _username.text.trim(),
          );
        }
      } else {
        if (_isEditing) {
          await controller.updateImapAccount(
            account: widget.account!,
            displayName: _displayName.text.trim(),
            host: _host.text.trim(),
            port: int.parse(_port.text.trim()),
            security: _security,
            enabled: _enabled,
            password: _password.text.trim().isEmpty ? null : _password.text,
            username:
                _username.text.trim().isEmpty ? null : _username.text.trim(),
          );
        } else {
          await controller.addImapAccount(
            email: _email.text.trim(),
            displayName: _displayName.text.trim(),
            host: _host.text.trim(),
            port: int.parse(_port.text.trim()),
            security: _security,
            password: _password.text,
            username:
                _username.text.trim().isEmpty ? null : _username.text.trim(),
          );
        }
      }
      if (mounted) Navigator.of(context).pop();
    } on Object catch (error) {
      setState(() {
        _error = _isGmail ? gmailImapAuthFailed : error.toString();
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountConfirmTitle),
        content: Text(l10n.deleteAccountConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _submitting = true);
    try {
      await context.read<AppController>().deleteAccount(widget.account!);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../models/mail_account.dart';

Future<void> showAddAccountSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const AddAccountSheet(),
  );
}

class AddAccountSheet extends StatefulWidget {
  const AddAccountSheet({super.key});

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
  bool _submitting = false;
  String? _error;

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
              l10n.addMailbox,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
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
                prefixIcon: const Icon(Icons.key_outlined),
              ),
              obscureText: true,
              validator: _required,
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
                  : const Icon(Icons.add),
              label: Text(l10n.addAccount),
            ),
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
        await controller.addImapAccount(
          email: _email.text.trim(),
          displayName: _displayName.text.trim(),
          host: 'imap.gmail.com',
          port: 993,
          security: MailSecurity.sslTls,
          password: _password.text,
          username: _username.text.trim().isEmpty
              ? null
              : _username.text.trim(),
        );
      } else {
        await controller.addImapAccount(
          email: _email.text.trim(),
          displayName: _displayName.text.trim(),
          host: _host.text.trim(),
          port: int.parse(_port.text.trim()),
          security: _security,
          password: _password.text,
          username: _username.text.trim().isEmpty
              ? null
              : _username.text.trim(),
        );
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

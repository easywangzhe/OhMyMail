import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_controller.dart';
import '../../l10n/app_localizations.dart';

Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => const SettingsSheet(),
  );
}

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  bool _launchAtStartup = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.settings, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.translate),
            title: Text(l10n.language),
            trailing: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'zh', label: Text(l10n.languageChinese)),
                ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
              ],
              selected: {controller.locale.languageCode},
              onSelectionChanged: (value) {
                controller.setLocale(Locale(value.first));
              },
            ),
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.power_settings_new),
            title: Text(l10n.launchAtStartup),
            subtitle: Text(
              controller.hasDesktopNotifications
                  ? l10n.desktopListenerEnabledDescription
                  : l10n.desktopListenerUnavailableDescription,
            ),
            value: _launchAtStartup,
            onChanged: controller.hasDesktopNotifications
                ? (value) async {
                    setState(() => _launchAtStartup = value);
                    await controller.setLaunchAtStartup(value);
                  }
                : null,
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.phone_android),
            title: Text(l10n.mobileReminders),
            subtitle: Text(l10n.mobileReminderDescription),
          ),
        ],
      ),
    );
  }
}

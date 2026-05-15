import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/mail_message.dart';

class NotificationService {
  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    const linux = LinuxInitializationSettings(defaultActionName: 'Open');
    const windows = WindowsInitializationSettings(
      appName: 'OhMyMail',
      appUserModelId: 'dev.ohmymail.app',
      guid: '2446cfc4-8aa9-4f9a-8e06-c3592d402430',
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
        linux: linux,
        windows: windows,
      ),
    );
  }

  Future<void> showNewMail(MailMessage message) async {
    const android = AndroidNotificationDetails(
      'new_mail',
      'New mail',
      channelDescription: 'New incoming mail notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwin = DarwinNotificationDetails();
    const linux = LinuxNotificationDetails();
    const windows = WindowsNotificationDetails();

    await _plugin.show(
      id: message.id.hashCode,
      title: message.subject,
      body: '${message.from}\n${message.snippet}',
      notificationDetails: const NotificationDetails(
        android: android,
        iOS: darwin,
        macOS: darwin,
        linux: linux,
        windows: windows,
      ),
    );
  }

  bool get supportsBackgroundNotifications {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }
}

import 'dart:io';

import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class DesktopService {
  bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  Future<void> initialize() async {
    if (!isDesktop) return;
    await windowManager.ensureInitialized();
    await windowManager.setPreventClose(true);
    final packageInfo = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath: Platform.resolvedExecutable,
      packageName: 'dev.ohmymail.app',
    );
    await trayManager.setToolTip('OhMyMail');
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(key: 'show', label: 'Show OhMyMail'),
          MenuItem.separator(),
          MenuItem(key: 'quit', label: 'Quit'),
        ],
      ),
    );
  }

  Future<void> setLaunchAtStartup(bool enabled) async {
    if (!isDesktop) return;
    if (enabled) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
  }
}

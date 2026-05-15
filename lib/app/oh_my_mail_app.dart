import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import 'app_controller.dart';
import '../features/mail/mail_home_page.dart';

class OhMyMailApp extends StatelessWidget {
  const OhMyMailApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    return MaterialApp(
      title: 'OhMyMail',
      debugShowCheckedModeBanner: false,
      locale: controller.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff2563eb),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.standard,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff60a5fa),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MailHomePage(),
    );
  }
}

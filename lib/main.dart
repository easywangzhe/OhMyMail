import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/oh_my_mail_app.dart';
import 'app/app_controller.dart';
import 'services/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final services = await AppServices.bootstrap();
  final controller = AppController(services);
  await controller.initialize();

  runApp(
    Provider<AppServices>.value(
      value: services,
      child: ChangeNotifierProvider<AppController>.value(
        value: controller,
        child: const OhMyMailApp(),
      ),
    ),
  );
}

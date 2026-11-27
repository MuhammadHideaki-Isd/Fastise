import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/fasting/application/fasting_controller.dart';
import 'features/fasting/data/fasting_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    FastiseApp(
      controller: FastingController(repository: FastingRepository(prefs)),
      showLaunchFlow: true,
    ),
  );
}

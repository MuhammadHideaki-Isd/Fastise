import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
=======
import 'package:shared_preferences/shared_preferences.dart';
>>>>>>> 9174678428320d9048e002f28c58843e015c2991

import 'app/app.dart';
import 'features/fasting/application/fasting_controller.dart';
import 'features/fasting/data/fasting_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
<<<<<<< HEAD
  await LiquidGlassWidgets.initialize();
  runApp(const FastiseApp());
=======
  final prefs = await SharedPreferences.getInstance();
  runApp(
    FastiseApp(
      controller: FastingController(repository: FastingRepository(prefs)),
    ),
  );
>>>>>>> 9174678428320d9048e002f28c58843e015c2991
}

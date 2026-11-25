import 'package:flutter/foundation.dart';

import '../domain/fasting_plan.dart';

/// App-wide fasting state. Extended with sessions (Task 5) and persistence
/// (Task 7).
class FastingController extends ChangeNotifier {
  FastingController({FastingPlan plan = FastingPlan.defaultPlan})
    : _selectedPlan = plan;

  FastingPlan _selectedPlan;

  FastingPlan get selectedPlan => _selectedPlan;

  void selectPlan(FastingPlan plan) {
    if (plan.id == _selectedPlan.id) return;
    _selectedPlan = plan;
    notifyListeners();
  }
}

import 'package:flutter/widgets.dart';

import 'fasting_controller.dart';

class FastingScope extends InheritedNotifier<FastingController> {
  const FastingScope({
    super.key,
    required FastingController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Depends on the controller: the caller rebuilds when it notifies.
  static FastingController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FastingScope>();
    assert(scope != null, 'No FastingScope found in context');
    return scope!.notifier!;
  }
}

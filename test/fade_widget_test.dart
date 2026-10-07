import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

import 'package:octo_image/src/image/fade_widget.dart';

void main() {
  LeakTesting.enable();

  testWidgets(
    'FadeWidget disposes its CurvedAnimation',
    experimentalLeakTesting: LeakTesting.settings.withTrackedAll(),
    (tester) async {
      await tester.pumpWidget(const FadeWidget(child: SizedBox()));
      // A child of another type can't update the old one, so
      // didUpdateWidget builds a new CurvedAnimation.
      await tester.pumpWidget(const FadeWidget(child: Placeholder()));
      await tester.pumpWidget(const SizedBox());
    },
  );
}

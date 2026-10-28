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
      // didUpdateWidget restarts the animation.
      await tester.pumpWidget(const FadeWidget(child: Placeholder()));
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'FadeWidget disposes its CurvedAnimation when fading out',
    experimentalLeakTesting: LeakTesting.settings.withTrackedAll(),
    (tester) async {
      const reverse = AnimationDirection.reverse;
      await tester
          .pumpWidget(const FadeWidget(direction: reverse, child: SizedBox()));
      await tester.pumpWidget(
          const FadeWidget(direction: reverse, child: Placeholder()));
      await tester.pumpAndSettle();
      // The status listener hides the child once the fade-out completes.
      expect(find.byType(Placeholder), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('FadeWidget applies a new curve mid-fade', (tester) async {
    const duration = Duration(milliseconds: 100);
    await tester.pumpWidget(const FadeWidget(
        duration: duration, curve: Curves.linear, child: SizedBox()));
    await tester.pump(const Duration(milliseconds: 50));
    // Same child, so the fade continues instead of restarting.
    await tester.pumpWidget(const FadeWidget(
        duration: duration, curve: Curves.easeIn, child: SizedBox()));
    final fade = tester.widget<FadeTransition>(find.byType(FadeTransition));
    expect(fade.opacity.value, Curves.easeIn.transform(0.5));
  });
}

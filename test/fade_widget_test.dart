import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

import 'package:octo_image/src/image/fade_widget.dart';

void main() {
  LeakTesting.enable();
  LeakTesting.settings = LeakTesting.settings.withTrackedAll();

  for (final direction in AnimationDirection.values) {
    final reverse = direction == AnimationDirection.reverse;
    // The status listener hides the child once a fade-out completes.
    final settled = reverse ? findsNothing : findsOneWidget;

    testWidgets('FadeWidget disposes its CurvedAnimation (${direction.name})',
        (tester) async {
      await tester.pumpWidget(
          FadeWidget(direction: direction, child: const SizedBox()));
      // A child of another type can't update the old one, so
      // didUpdateWidget restarts the animation.
      await tester.pumpWidget(
          FadeWidget(direction: direction, child: const Placeholder()));
      await tester.pumpAndSettle();
      expect(find.byType(Placeholder), settled);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('FadeWidget applies a new curve mid-fade (${direction.name})',
        (tester) async {
      Widget fade(Curve curve) => FadeWidget(
          direction: direction,
          duration: const Duration(milliseconds: 100),
          curve: curve,
          child: const Placeholder());
      await tester.pumpWidget(fade(Curves.linear));
      await tester.pump(const Duration(milliseconds: 50));
      // Same child, so the fade continues instead of restarting.
      await tester.pumpWidget(fade(Curves.easeIn));
      final eased = Curves.easeIn.transform(0.5);
      final opacity =
          tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity;
      expect(opacity.value, reverse ? 1 - eased : eased);
      await tester.pumpAndSettle();
      expect(find.byType(Placeholder), settled);
      await tester.pumpWidget(const SizedBox());
    });
  }
}

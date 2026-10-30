import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:octo_image/octo_image.dart';

import 'helpers/mock_image_provider.dart';

/// The mock image loads on the fake test clock, but decoding happens in the
/// engine on real time, so advance both until [done].
Future<void> _settle(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 500 && !done(); i++) {
    await tester.pump(const Duration(milliseconds: 20));
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 10)));
  }
  expect(done(), isTrue, reason: 'image did not finish loading');
  await tester.pumpAndSettle();
}

void main() {
  final modes = <String, OctoImage Function(ImageProvider, OctoLoadedCallback)>{
    'placeholder': (image, onLoaded) => OctoImage(
          image: image,
          placeholderBuilder: (context) => const SizedBox(),
          onLoaded: onLoaded,
        ),
    'progress indicator': (image, onLoaded) => OctoImage(
          image: image,
          progressIndicatorBuilder: (context, progress) => const SizedBox(),
          onLoaded: onLoaded,
        ),
    'no placeholder': (image, onLoaded) => OctoImage(
          image: image,
          onLoaded: onLoaded,
        ),
  };

  for (final mode in modes.entries) {
    testWidgets('onLoaded called once with ${mode.key}', (tester) async {
      final loaded = <OctoImageLoadInfo>[];
      await tester.pumpWidget(mode.value(
        MockImageProvider(useCase: TestUseCase.loadAndSuccess),
        loaded.add,
      ));
      await _settle(tester, () => loaded.isNotEmpty);

      expect(loaded, hasLength(1));
      expect(loaded.single.elapsed, greaterThan(Duration.zero));
      expect(loaded.single.synchronousCall, isFalse);
      expect(loaded.single.size, const Size(1, 1));
    });
  }

  testWidgets('onLoadError called when image fails', (tester) async {
    final loaded = <OctoImageLoadInfo>[];
    final errors = <Object>[];
    await tester.pumpWidget(OctoImage(
      image: MockImageProvider(useCase: TestUseCase.loadAndFail),
      onLoaded: loaded.add,
      onLoadError: (error, stackTrace) => errors.add(error),
    ));
    await _settle(tester, () => errors.isNotEmpty);

    expect(errors, hasLength(1));
    expect(loaded, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onLoaded called again when image changes', (tester) async {
    final loaded = <OctoImageLoadInfo>[];
    await tester.pumpWidget(OctoImage(
      image: MockImageProvider(useCase: TestUseCase.loadAndSuccess),
      onLoaded: loaded.add,
    ));
    await _settle(tester, () => loaded.isNotEmpty);
    await tester.pumpWidget(OctoImage(
      image: MockImageProvider(useCase: TestUseCase.loadAndSuccess),
      onLoaded: loaded.add,
    ));
    await _settle(tester, () => loaded.length == 2);

    expect(loaded, hasLength(2));
  });

  testWidgets('changing the callbacks does not report the image again',
      (tester) async {
    final image = MockImageProvider(useCase: TestUseCase.loadAndSuccess);
    final loaded = <OctoImageLoadInfo>[];
    void onLoadError(Object error, StackTrace? stackTrace) {}

    await tester.pumpWidget(OctoImage(image: image, onLoaded: loaded.add));
    await _settle(tester, () => loaded.isNotEmpty);
    await tester.pumpWidget(OctoImage(
      image: image,
      onLoaded: loaded.add,
      onLoadError: onLoadError,
    ));
    await tester.pumpWidget(OctoImage(image: image));
    await tester.pumpWidget(OctoImage(image: image, onLoaded: loaded.add));
    await tester.pumpAndSettle();

    expect(loaded, hasLength(1));
  });

  testWidgets('cached image reported after the frame', (tester) async {
    final image = MockImageProvider(useCase: TestUseCase.loadAndSuccess);
    var cached = false;
    await tester.pumpWidget(
      OctoImage(image: image, onLoaded: (_) => cached = true),
    );
    await _settle(tester, () => cached);

    final loaded = <OctoImageLoadInfo>[];
    await tester.pumpWidget(StatefulBuilder(
      builder: (context, setState) => OctoImage(
        key: const ValueKey('cached'),
        image: image,
        // setState on an ancestor throws when called during build.
        onLoaded: (info) => setState(() => loaded.add(info)),
      ),
    ));

    expect(loaded, hasLength(1));
    expect(loaded.single.synchronousCall, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nothing called after widget is removed', (tester) async {
    final image = MockImageProvider(useCase: TestUseCase.loadAndSuccess);
    final removedLoaded = <OctoImageLoadInfo>[];
    var keptLoaded = false;
    // The kept widget keeps loading the same image after the other is gone.
    Widget kept() => OctoImage(
          key: const ValueKey('kept'),
          image: image,
          onLoaded: (_) => keptLoaded = true,
        );

    await tester.pumpWidget(Column(children: [
      kept(),
      OctoImage(image: image, onLoaded: removedLoaded.add),
    ]));
    await tester.pumpWidget(Column(children: [kept()]));
    await _settle(tester, () => keptLoaded);

    expect(removedLoaded, isEmpty);
  });
}

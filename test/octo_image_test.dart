import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:octo_image/octo_image.dart';
import 'package:octo_image/src/image/image_handler.dart';

import 'helpers/mock_image_provider.dart';
import 'helpers/transparent_image.dart';

void main() {
  testWidgets('errorBuilder called when image fails', (tester) async {
    // Create the widget by telling the tester to build it.
    var thrown = false;
    await tester.pumpWidget(MyWidget(
      useCase: TestUseCase.loadAndFail,
      onError: () => thrown = true,
    ));
    await tester.pumpAndSettle();
    expect(thrown, isTrue);
  });

  testWidgets("errorBuilder doesn't call when image doesn't fail",
      (tester) async {
    // Create the widget by telling the tester to build it.
    var thrown = false;
    await tester.pumpWidget(MyWidget(
      useCase: TestUseCase.loadAndSuccess,
      onError: () => thrown = true,
    ));
    await tester.pumpAndSettle();
    expect(thrown, isFalse);
  });

  testWidgets('placeholder called when fail', (tester) async {
    // Create the widget by telling the tester to build it.
    var placeholderShown = false;
    var thrown = false;
    await tester.pumpWidget(MyWidget(
      useCase: TestUseCase.loadAndFail,
      onPlaceHolder: () => placeholderShown = true,
      onError: () => thrown = true,
    ));
    await tester.pumpAndSettle();
    expect(thrown, isTrue);
    expect(placeholderShown, isTrue);
  });

  testWidgets('placeholder called when success', (tester) async {
    // Create the widget by telling the tester to build it.
    var placeholderShown = false;
    var thrown = false;
    await tester.pumpWidget(MyWidget(
      useCase: TestUseCase.loadAndSuccess,
      onPlaceHolder: () => placeholderShown = true,
      onError: () => thrown = true,
    ));
    await tester.pumpAndSettle();
    expect(thrown, isFalse);
    expect(placeholderShown, isTrue);
  });

  testWidgets('placeholder called when success', (tester) async {
    // Create the widget by telling the tester to build it.
    var placeholderShown = false;
    var thrown = false;
    await tester.pumpWidget(MyWidget(
      useCase: TestUseCase.loadAndSuccess,
      onPlaceHolder: () => placeholderShown = true,
      onError: () => thrown = true,
    ));
    await tester.pumpAndSettle();
    expect(thrown, isFalse);
    expect(placeholderShown, isTrue);
  });

  testWidgets('progressIndicator called several times', (tester) async {
    // Create the widget by telling the tester to build it.
    var progressIndicatorCalled = 0;
    var thrown = false;
    await tester.pumpWidget(MyWidget(
      useCase: TestUseCase.loadAndSuccess,
      onProgress: () => progressIndicatorCalled++,
      onError: () => thrown = true,
    ));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(thrown, isFalse);
    expect(progressIndicatorCalled, 11);
  });

  testWidgets('rebuild with the same memCache size keeps the loaded image',
      (tester) async {
    Widget octo(BoxFit fit) => Directionality(
          textDirection: TextDirection.ltr,
          child: OctoImage(
            image: MemoryImage(kTransparentImage),
            memCacheWidth: 10,
            memCacheHeight: 20,
            gaplessPlayback: true,
            fit: fit,
            placeholderBuilder: (_) => const Text('placeholder'),
          ),
        );
    // Precached so the image has really shown: only then can a wrong image
    // change keep it as the previous image under gapless playback.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final context = tester.element(find.byType(SizedBox));
    await tester.runAsync(() => precacheImage(
        ResizeImage(MemoryImage(kTransparentImage), width: 10, height: 20),
        context));
    await tester.pumpWidget(octo(BoxFit.cover));
    final imageState = tester.state(find.byType(Image));

    await tester.pumpWidget(octo(BoxFit.contain));

    expect(find.byType(Image), findsOneWidget);
    expect(tester.state(find.byType(Image)), same(imageState));
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.contain);
  });

  testWidgets('rebuild with a different memCache size loads the new image',
      (tester) async {
    Widget octo(int width) => Directionality(
          textDirection: TextDirection.ltr,
          child: OctoImage(
            image: MemoryImage(kTransparentImage),
            memCacheWidth: width,
            memCacheHeight: 20,
            gaplessPlayback: true,
            placeholderBuilder: (_) => const Text('placeholder'),
          ),
        );
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final context = tester.element(find.byType(SizedBox));
    await tester.runAsync(() => precacheImage(
        ResizeImage(MemoryImage(kTransparentImage), width: 10, height: 20),
        context));
    await tester.pumpWidget(octo(10));

    await tester.pumpWidget(octo(30));

    final widths = find
        .byType(Image)
        .evaluate()
        .map((e) => ((e.widget as Image).image as ResizeImage).width);
    expect(widths, [30, 10]);
    expect(find.text('placeholder'), findsNothing);

    await tester.pumpAndSettle();
  });

  group('imageIdentity', () {
    final provider = MemoryImage(kTransparentImage);

    test('is equal for ResizeImages with the same provider and size', () {
      expect(
        imageIdentity(ResizeImage(provider, width: 10, height: 20)),
        imageIdentity(ResizeImage(provider, width: 10, height: 20)),
      );
    });

    test('differs when the size differs', () {
      expect(
        imageIdentity(ResizeImage(provider, width: 10)),
        isNot(imageIdentity(ResizeImage(provider, width: 11))),
      );
      expect(
        imageIdentity(ResizeImage(provider, height: 10)),
        isNot(imageIdentity(ResizeImage(provider, height: 11))),
      );
    });

    test('differs when the wrapped provider differs', () {
      expect(
        imageIdentity(ResizeImage(provider, width: 10)),
        isNot(imageIdentity(ResizeImage(
            MemoryImage(Uint8List.fromList(kTransparentImage)),
            width: 10))),
      );
    });

    test('leaves ResizeImage subclasses to their own ==', () {
      expect(
        imageIdentity(_VariantResizeImage(provider, width: 10, variant: 'a')),
        isNot(imageIdentity(
            _VariantResizeImage(provider, width: 10, variant: 'b'))),
      );
    });
  });
}

class _VariantResizeImage extends ResizeImage {
  const _VariantResizeImage(super.imageProvider,
      {super.width, required this.variant});

  final String variant;

  @override
  bool operator ==(Object other) =>
      other is _VariantResizeImage &&
      super == other &&
      other.variant == variant;

  @override
  int get hashCode => Object.hash(super.hashCode, variant);
}

class MyWidget extends StatelessWidget {
  final TestUseCase useCase;
  final OctoProgressIndicatorBuilder? progressBuilder;
  final OctoPlaceholderBuilder? placeholderBuilder;
  final OctoErrorBuilder? errorBuilder;

  MyWidget({
    super.key,
    required this.useCase,
    VoidCallback? onProgress,
    VoidCallback? onPlaceHolder,
    VoidCallback? onError,
  })  : progressBuilder = getProgress(onProgress),
        placeholderBuilder = getPlaceholder(onPlaceHolder),
        errorBuilder = getErrorBuilder(onError);

  static OctoProgressIndicatorBuilder? getProgress(VoidCallback? onProgress) {
    if (onProgress == null) return null;
    return (context, progress) {
      onProgress();
      return const CircularProgressIndicator();
    };
  }

  static OctoPlaceholderBuilder? getPlaceholder(VoidCallback? onPlaceHolder) {
    if (onPlaceHolder == null) return null;
    return (context) {
      onPlaceHolder();
      return const Placeholder();
    };
  }

  static OctoErrorBuilder? getErrorBuilder(VoidCallback? onError) {
    if (onError == null) return null;
    return (context, error, stacktrace) {
      onError();
      return const Icon(Icons.error);
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: Center(
          child: OctoImage(
            image: MockImageProvider(useCase: useCase),
            progressIndicatorBuilder: progressBuilder,
            placeholderBuilder: placeholderBuilder,
            errorBuilder: errorBuilder,
          ),
        ),
      ),
    );
  }
}

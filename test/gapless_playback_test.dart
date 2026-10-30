import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker/leak_tracker.dart';

import 'package:octo_image/octo_image.dart';

import 'helpers/transparent_image.dart';

Widget _app(ImageProvider image, {required bool progress}) => MaterialApp(
      home: Center(
        child: OctoImage(
          image: image,
          gaplessPlayback: true,
          placeholderBuilder: progress ? null : (_) => const Placeholder(),
          progressIndicatorBuilder:
              progress ? (_, __) => const CircularProgressIndicator() : null,
        ),
      ),
    );

ImageProvider _memoryImage() =>
    MemoryImage(Uint8List.fromList(kTransparentImage));

/// An image whose load never completes, whatever the test harness does.
class _NeverLoads extends ImageProvider<_NeverLoads> {
  @override
  Future<_NeverLoads> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
          _NeverLoads key, ImageDecoderCallback decode) =>
      OneFrameImageStreamCompleter(Completer<ImageInfo>().future);
}

List<ImageProvider> _imagesInTree() => find
    .byType(Image)
    .evaluate()
    .map((e) => (e.widget as Image).image)
    .toList();

void main() {
  for (final progress in [false, true]) {
    final builder =
        progress ? 'progressIndicatorBuilder' : 'placeholderBuilder';
    final fallback = progress ? CircularProgressIndicator : Placeholder;

    testWidgets('gaplessPlayback keeps only the last loaded image ($builder)',
        (tester) async {
      final loaded = _memoryImage();
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final context = tester.element(find.byType(SizedBox));
      await tester.runAsync(() => precacheImage(loaded, context));

      await tester.pumpWidget(_app(loaded, progress: progress));

      // Swap to images that never load while gapless playback is on.
      late _NeverLoads latest;
      for (var i = 0; i < 5; i++) {
        latest = _NeverLoads();
        await tester.pumpWidget(_app(latest, progress: progress));
      }

      // The loading image, with the last loaded one shown in its place. Nothing
      // in between is kept.
      expect(_imagesInTree(), [latest, loaded]);
      expect(find.byType(fallback), findsNothing);

      await tester.pumpAndSettle();
    });

    testWidgets('gaplessPlayback releases images it no longer shows ($builder)',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Center()));
      BuildContext context() => tester.element(find.byType(Center));

      // Show A, holding it only weakly from here on.
      Future<WeakReference<ImageProvider>> showFirst() async {
        final a = _memoryImage();
        await tester.runAsync(() => precacheImage(a, context()));
        await tester.pumpWidget(_app(a, progress: progress));
        return WeakReference(a);
      }

      final a = await showFirst();

      // B loads after it is swapped in, so it fades in over A.
      final b = _memoryImage();
      await tester.pumpWidget(_app(b, progress: progress));
      await tester.runAsync(() => precacheImage(b, context()));
      await tester.pumpAndSettle();

      final c = _NeverLoads();
      await tester.pumpWidget(_app(c, progress: progress));

      expect(_imagesInTree(), [c, b]);
      expect(find.byType(fallback), findsNothing);

      // Nothing but the widget should still reach A.
      imageCache
        ..clear()
        ..clearLiveImages();
      await tester.runAsync(() => forceGC(fullGcCycles: 2));
      expect(a.target, isNull);

      await tester.pumpAndSettle();
    });
  }
}

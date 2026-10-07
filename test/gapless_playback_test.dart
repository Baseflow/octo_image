import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:octo_image/octo_image.dart';

import 'helpers/mock_image_provider.dart';
import 'helpers/transparent_image.dart';

Widget _app(ImageProvider image) => MaterialApp(
      home: Center(
        child: OctoImage(
          image: image,
          gaplessPlayback: true,
          placeholderBuilder: (_) => const Placeholder(),
        ),
      ),
    );

List<ImageProvider> _imagesInTree() => find
    .byType(Image)
    .evaluate()
    .map((e) => (e.widget as Image).image)
    .toList();

void main() {
  testWidgets('gaplessPlayback keeps only the last loaded image',
      (tester) async {
    final loaded = MemoryImage(Uint8List.fromList(kTransparentImage));
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final context = tester.element(find.byType(SizedBox));
    await tester.runAsync(() => precacheImage(loaded, context));

    await tester.pumpWidget(_app(loaded));

    // Swap to images that never finish loading while gapless playback is on.
    late MockImageProvider latest;
    for (var i = 0; i < 5; i++) {
      latest = MockImageProvider(useCase: TestUseCase.loadAndSuccess);
      await tester.pumpWidget(_app(latest));
    }

    // The loading image, with the last loaded one shown in its place. Nothing
    // in between is kept.
    expect(_imagesInTree(), [latest, loaded]);

    await tester.pumpAndSettle();
  });
}

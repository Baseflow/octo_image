import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:octo_image/octo_image.dart';

import 'helpers/mock_image_provider.dart';

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
}

class MyWidget extends StatelessWidget {
  final TestUseCase useCase;
  final OctoPlaceholderBuilder placeholderBuilder;
  final OctoErrorBuilder errorBuilder;

  MyWidget({
    Key key,
    @required this.useCase,
    VoidCallback onPlaceHolder,
    VoidCallback onError,
  })  : placeholderBuilder = getPlaceholder(onPlaceHolder),
        errorBuilder = getErrorBuilder(onError),
        super(key: key);

  static OctoPlaceholderBuilder getPlaceholder(VoidCallback onPlaceHolder) {
    if (onPlaceHolder == null) return null;
    return (context) {
      onPlaceHolder();
      return Placeholder();
    };
  }

  static OctoErrorBuilder getErrorBuilder(VoidCallback onError) {
    if (onError == null) return null;
    return (context, error, stacktrace) {
      onError();
      return Icon(Icons.error);
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
            placeholderBuilder: placeholderBuilder,
            errorBuilder: errorBuilder,
          ),
        ),
      ),
    );
  }
}

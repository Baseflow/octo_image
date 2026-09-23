import 'package:example/helpers/mock_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Set Demo',
      theme: ThemeData(),
      home: OctoImagePage(
        sets: <OctoSet>[
          OctoSet.circleAvatar(
            backgroundColor: Colors.red,
            text: const Text(
              "M",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          OctoSet.circularIndicatorAndIcon(),
          OctoSet.circularIndicatorAndIcon(showProgress: true),
        ],
      ),
    );
  }
}

class OctoImagePage extends StatelessWidget {
  final List<OctoSet> sets;

  const OctoImagePage({super.key, required this.sets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Demo'),
      ),
      body: ListView(children: sets.map((element) => _row(element)).toList()),
    );
  }

  Widget _row(OctoSet octoSet) {
    return Row(
      children: <Widget>[
        Expanded(
          child: AspectRatio(
            aspectRatio: 269 / 173,
            child: OctoImage.fromSet(
              image: MockImageProvider(useCase: TestUseCase.loadAndFail),
              octoSet: octoSet,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          child: AspectRatio(
            aspectRatio: 269 / 173,
            child: OctoImage.fromSet(
              image: MockImageProvider(useCase: TestUseCase.loadAndSuccess),
              octoSet: octoSet,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

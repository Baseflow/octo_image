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
      title: 'OctoImage Demo',
      theme: ThemeData(),
      home: const OctoImagePage(),
    );
  }
}

class OctoImagePage extends StatelessWidget {
  const OctoImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OctoImage Demo'),
      ),
      body: ListView(
        children: [
          _customImage(),
          const SizedBox(height: 16),
          _circleAvatar(),
        ],
      ),
    );
  }

  Widget _customImage() {
    return SizedBox(
      height: 150,
      child: OctoImage(
        image: const NetworkImage('https://via.placeholder.com/150'),
        progressIndicatorBuilder: (context, progress) {
          double? value;
          var expectedBytes = progress?.expectedTotalBytes;
          if (progress != null && expectedBytes != null) {
            value = progress.cumulativeBytesLoaded / expectedBytes;
          }
          return CircularProgressIndicator(value: value);
        },
        errorBuilder: (context, error, stacktrace) => const Icon(Icons.error),
      ),
    );
  }

  Widget _circleAvatar() {
    return SizedBox(
      height: 75,
      child: OctoImage.fromSet(
        fit: BoxFit.cover,
        image: const NetworkImage(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Macaca_nigra_self-portrait_large.jpg/1024px-Macaca_nigra_self-portrait_large.jpg',
        ),
        octoSet: OctoSet.circleAvatar(
          backgroundColor: Colors.red,
          text: const Text("M"),
        ),
      ),
    );
  }
}

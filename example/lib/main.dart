import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OctoImage Demo',
      theme: ThemeData(
      ),
      home: OctoImagePage(),
    );
  }
}

class OctoImagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OctoImage Demo'),
      ),
      body: ListView(children: [
        _simpleSet()
      ],),
    );
  }

  Widget _simpleSet(){
    return AspectRatio(
      aspectRatio: 600/400,
      child: OctoImage.fromSet(
        image: NetworkImage('https://dummyimage.com/600x400/000/fff'),
        octoSet: OctoSet.simple(),
      ),
    );
  }
}
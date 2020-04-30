import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:octo_image/octo_image.dart';

void main() {
  test('adds one to input values', () {
    OctoImage(
      image: NetworkImage('https://dummyimage.com/600x400/000/fff'),
      imageBuilder: OctoImageTransformer.circleAvatar(),
    );
  });
}

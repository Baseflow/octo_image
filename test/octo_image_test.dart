import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:octo_image/octo_image.dart';
import 'package:octo_image/src/octo_set.dart';

void main() {
  test('adds one to input values', () {
    OctoImage.fromSet(
      image: NetworkImage('https://dummyimage.com/600x400/000/fff'),
      octoSet: OctoSet.simple(),
    );
  });
}

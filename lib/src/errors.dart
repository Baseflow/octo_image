import 'package:flutter/material.dart';

import '../octo_image.dart';

/// Helper class with pre-made [OctoErrorBuilder]s. These can be directly
/// used when creating an image.
/// For example:
///    OctoImage(
///      image: NetworkImage('https://dummyimage.com/600x400/000/fff'),
///      errorBuilder: OctoError.icon(),
///    );
class OctoError {
  /// Show an icon. Default to [Icons.error]. Color can be set, but defaults to
  /// the value given by the current [IconTheme].
  static OctoErrorBuilder icon({
    IconData icon = Icons.error,
    Color color,
  }) {
    return (context, error, stacktrace) => Icon(
          icon,
          color: color,
        );
  }

  /// Displays a [CircleAvatar] as errorWidget
  static OctoErrorBuilder circleAvatar({
    @required Color backgroundColor,
    @required Widget text,
  }) {
    return (context, error, stacktrace) => SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CircleAvatar(
            child: text,
            backgroundColor: backgroundColor,
          ),
        );
  }
}

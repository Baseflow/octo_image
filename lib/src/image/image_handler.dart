import 'package:flutter/widgets.dart';

import '../../octo_image.dart';
import 'fade_widget.dart';

enum _PlaceholderType {
  none,
  static,
  progress,
}

class ImageHandler {
  late _PlaceholderType _placeholderType;
  /// Optional builder to further customize the display of the image.
  final OctoImageBuilder? imageBuilder;

  /// Widget displayed while the target [imageUrl] is loading.
  final OctoPlaceholderBuilder? placeholderBuilder;

  /// Widget displayed while the target [imageUrl] is loading.
  final OctoProgressIndicatorBuilder? progressIndicatorBuilder;

  /// Widget displayed while the target [imageUrl] failed loading.
  final OctoErrorBuilder? errorBuilder;

  /// The duration of the fade-in animation for the [placeholderBuilder].
  final Duration placeholderFadeInDuration;

  /// The duration of the fade-out animation for the [placeholderBuilder].
  final Duration fadeOutDuration;

  /// The curve of the fade-out animation for the [placeholderBuilder].
  final Curve fadeOutCurve;

  /// The duration of the fade-in animation for the [imageUrl].
  final Duration fadeInDuration;

  /// The curve of the fade-in animation for the [imageUrl].
  final Curve fadeInCurve;

  ImageHandler({required this.imageBuilder, required this.placeholderBuilder,
  required this.progressIndicatorBuilder, required this.errorBuilder,
  required this.placeholderFadeInDuration, required this.fadeOutDuration,
  required this.fadeOutCurve, required this.fadeInDuration, required this
        .fadeInCurve,}){
    _placeholderType = _definePlaceholderType();
  }

  ImageFrameBuilder imageFrameBuilder(){
    switch (_placeholderType) {
      case _PlaceholderType.none:
        return _imageBuilder;
      case _PlaceholderType.static:
        return _placeholderBuilder;
      case _PlaceholderType.progress:
        return _preLoadingBuilder;
    }
  }

  ImageLoadingBuilder? imageLoadingBuilder(){
    return _placeholderType == _PlaceholderType.progress
        ? _loadingBuilder
        : null;
  }

  ImageErrorWidgetBuilder? errorWidgetBuilder(){
    return errorBuilder != null ? _errorBuilder : null;
  }

  Widget _stack(Widget revealing, Widget disappearing) {
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        FadeWidget(
          child: revealing,
          duration: fadeInDuration,
          curve: fadeInCurve,
        ),
        FadeWidget(
          child: disappearing,
          duration: fadeOutDuration,
          curve: fadeOutCurve,
          direction: AnimationDirection.reverse,
        )
      ],
    );
  }

  Widget _imageBuilder(BuildContext context, Widget child, int? frame,
      bool wasSynchronouslyLoaded) {
    if (frame == null) {
      return child;
    }
    return _image(context, child);
  }

  Widget _placeholderBuilder(BuildContext context, Widget child, int? frame,
      bool wasSynchronouslyLoaded) {
    if (frame == null) {
      if (placeholderFadeInDuration != Duration.zero) {
        return FadeWidget(
          child: _placeholder(context),
          duration: placeholderFadeInDuration,
          curve: fadeInCurve,
        );
      } else {
        return _placeholder(context);
      }
    }
    if (wasSynchronouslyLoaded) {
      return _image(context, child);
    }
    return _stack(
      _image(context, child),
      _placeholder(context),
    );
  }

  bool _wasSynchronouslyLoaded = false;
  bool _isLoaded = false;

  Widget _preLoadingBuilder(BuildContext context, Widget child, int? frame,
      bool wasSynchronouslyLoaded) {
    _wasSynchronouslyLoaded = wasSynchronouslyLoaded;
    _isLoaded = frame != null;
    return child;
  }

  Widget _loadingBuilder(
      BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (_isLoaded) {
      if (_wasSynchronouslyLoaded) {
        return _image(context, child);
      }
      return _stack(
        _image(context, child),
        _progressIndicator(context, null),
      );
    }

    if (placeholderFadeInDuration != Duration.zero) {
      return FadeWidget(
        child: _progressIndicator(context, loadingProgress),
        duration: placeholderFadeInDuration,
        curve: fadeInCurve,
      );
    } else {
      return _progressIndicator(context, loadingProgress);
    }
  }

  Widget _image(BuildContext context, Widget child) {
    if (imageBuilder != null) {
      return imageBuilder!(context, child);
    } else {
      return child;
    }
  }

  Widget _errorBuilder(
      BuildContext context,
      Object error,
      StackTrace? stacktrace,
      ) {
    if (errorBuilder == null) {
      throw StateError('Try to build errorBuilder with errorBuilder null');
    }
    return errorBuilder!(context, error, stacktrace);
  }

  Widget _progressIndicator(
      BuildContext context, ImageChunkEvent? loadingProgress) {
    if (progressIndicatorBuilder == null) {
      throw StateError(
          'Try to build progressIndicatorBuilder with progressIndicatorBuilder null');
    }
    return progressIndicatorBuilder!(context, loadingProgress);
  }

  Widget _placeholder(BuildContext context) {

    if (placeholderBuilder != null) {
      return placeholderBuilder!(context);
    }
    return Container();
  }

  _PlaceholderType _definePlaceholderType() {
    assert(placeholderBuilder == null ||
        progressIndicatorBuilder == null);

    if (placeholderBuilder != null) return _PlaceholderType.static;
    if (progressIndicatorBuilder != null) {
      return _PlaceholderType.progress;
    }
    return _PlaceholderType.none;
  }
}
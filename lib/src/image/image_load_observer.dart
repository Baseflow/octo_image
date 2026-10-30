import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'image.dart';

/// Listens to the [ImageStream] of an image and reports, once per image, when
/// its first frame is decoded or loading fails, and how long that took.
///
/// It resolves the provider with the same [ImageConfiguration] as [Image], so
/// both share the stream from the [ImageCache] and the image decodes once.
class ImageLoadObserver {
  /// The callbacks are getters so the latest widget's callbacks are used.
  ImageLoadObserver({required this.onLoaded, required this.onLoadError});

  final OctoLoadedCallback? Function() onLoaded;
  final OctoLoadErrorCallback? Function() onLoadError;

  final Stopwatch _stopwatch = Stopwatch();
  ImageStream? _imageStream;
  ImageStreamListener? _listener;
  bool _reported = false;
  bool _addingListener = false;

  /// Starts observing [image]. Does nothing when it resolves to the stream
  /// that is already observed.
  void resolve(
    ImageProvider image,
    ImageConfiguration configuration, {
    required bool handlesErrors,
  }) {
    final newStream = image.resolve(configuration);
    if (_imageStream?.key == newStream.key) return;
    _stopListening();
    _imageStream = newStream;
    _reported = false;
    _stopwatch
      ..reset()
      ..start();
    _listen(handlesErrors);
  }

  /// Whether stream errors are taken over. When false they are left to
  /// [Image] and [FlutterError], and [onLoadError] is not called.
  set handlesErrors(bool value) {
    if (_listener == null || (_listener!.onError != null) == value) return;
    _stopListening();
    _listen(value);
  }

  void dispose() {
    _stopListening();
    _imageStream = null;
  }

  void _listen(bool handlesErrors) {
    final listener = ImageStreamListener(
      _handleImage,
      onError: handlesErrors ? _handleError : null,
    );
    _listener = listener;
    // A cached image or error is replayed synchronously from addListener,
    // which can run during build. Those are reported after the frame instead.
    _addingListener = true;
    _imageStream!.addListener(listener);
    _addingListener = false;
  }

  void _stopListening() {
    final listener = _listener;
    if (listener == null) return;
    _listener = null;
    _imageStream?.removeListener(listener);
  }

  void _handleImage(ImageInfo imageInfo, bool synchronousCall) {
    // Every listener gets its own clone of the image and must dispose it.
    final image = imageInfo.image;
    final size = Size(image.width.toDouble(), image.height.toDouble());
    imageInfo.dispose();
    final info = OctoImageLoadInfo(
      size: size,
      elapsed: _stopwatch.elapsed,
      synchronousCall: synchronousCall,
    );
    _report(() => onLoaded()?.call(info));
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    _report(() => onLoadError()?.call(error, stackTrace));
  }

  /// Reports only the first event, then unsubscribes: staying subscribed
  /// would keep an animated image decoding frames while [Image] paused it.
  void _report(VoidCallback callback) {
    if (_reported) return;
    _reported = true;
    if (!_addingListener) {
      _stopListening();
      callback();
      return;
    }
    // A replay from addListener can run during build, and before Image has
    // subscribed, when removing the last listener could dispose the stream.
    final stream = _imageStream;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!identical(stream, _imageStream)) return;
      _stopListening();
      callback();
    });
  }
}

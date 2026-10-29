import 'package:flutter/widgets.dart';

/// The direction in which an animation is running.
enum AnimationDirection {
  /// The animation is running from beginning to end.
  forward,

  /// The animation is running backwards, from end to beginning.
  reverse,
}

/// Helper Widget to Fade in or out
class FadeWidget extends StatefulWidget {
  /// Child widget being faded
  final Widget child;

  /// Fade duration
  final Duration duration;

  /// Duration direction, forward is from invisible to visible
  final AnimationDirection direction;

  /// Animation curve. See [Curves] for more options.
  final Curve curve;

  /// Fading [child] in or out depending on [direction] with a [curve] and
  /// [duration]./
  const FadeWidget(
      {required this.child,
      this.duration = const Duration(milliseconds: 800),
      this.direction = AnimationDirection.forward,
      this.curve = Curves.easeOut,
      super.key});

  @override
  State createState() => _FadeWidgetState();
}

class _FadeWidgetState extends State<FadeWidget>
    with SingleTickerProviderStateMixin {
  late Animation<double> opacity;
  late final AnimationController controller;
  late final CurvedAnimation curved;
  late bool hideWidget;

  @override
  Widget build(BuildContext context) {
    if (hideWidget) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: opacity,
      child: widget.child,
    );
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: widget.duration, vsync: this);
    curved = CurvedAnimation(parent: controller, curve: widget.curve);
    _startAnimation();
  }

  @override
  void didUpdateWidget(FadeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.duration = widget.duration;
    curved.curve = widget.curve;
    if (Widget.canUpdate(oldWidget.child, widget.child)) {
      // Setting duration alone only affects the next run; forward() resumes
      // from the current value with the new one.
      if (controller.isAnimating && widget.duration != oldWidget.duration) {
        controller.forward();
      }
      return;
    }
    opacity.removeStatusListener(animationStatusChange);
    controller.value = 0;
    _startAnimation();
  }

  @override
  void dispose() {
    opacity.removeStatusListener(animationStatusChange);
    curved.dispose();
    controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    var begin = widget.direction == AnimationDirection.forward ? 0.0 : 1.0;
    var end = widget.direction == AnimationDirection.forward ? 1.0 : 0.0;
    opacity = Tween<double>(begin: begin, end: end).animate(curved);
    controller.forward();

    hideWidget = false;
    if (widget.direction == AnimationDirection.reverse) {
      if (widget.duration == Duration.zero) {
        hideWidget = true;
      } else {
        opacity.addStatusListener(animationStatusChange);
      }
    }
  }

  void animationStatusChange(AnimationStatus status) {
    setState(() {
      hideWidget = widget.direction == AnimationDirection.reverse &&
          status == AnimationStatus.completed;
    });
  }
}

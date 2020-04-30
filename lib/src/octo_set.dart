import '../octo_image.dart';

/// OctoSets are predefined combinations of a [OctoPlaceholderBuilder],
/// [OctoProgressIndicatorBuilder], [OctoImageBuilder] and/or [OctoErrorBuilder].
/// For example:
///     OctoImage.fromSet(
///      image: NetworkImage('https://dummyimage.com/600x400/000/fff'),
///      octoSet: OctoSet.simple(),
///    );
class OctoSet {
  /// Optional builder to further customize the display of the image.
  final OctoImageBuilder imageBuilder;

  /// Widget displayed while the target [imageUrl] is loading.
  final OctoPlaceholderBuilder placeholderBuilder;

  /// Widget displayed while the target [imageUrl] is loading.
  final OctoProgressIndicatorBuilder progressIndicatorBuilder;

  /// Widget displayed while the target [imageUrl] failed loading.
  final OctoErrorBuilder errorBuilder;

  OctoSet._({
    this.imageBuilder,
    this.placeholderBuilder,
    this.progressIndicatorBuilder,
    this.errorBuilder,
  }) : assert(placeholderBuilder != null || progressIndicatorBuilder != null);

  /// Simple set to show [OctoPlaceholder.circularProgressIndicator] as
  /// placeholder and [OctoError.icon] as error.
  factory OctoSet.simple() {
    return OctoSet._(
      placeholderBuilder: OctoPlaceholder.circularProgressIndicator(),
      errorBuilder: OctoError.icon(),
    );
  }
}

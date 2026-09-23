# octo_image agent instructions

Technical reference for AI agents and contributors developing in this repository.

Process and conduct live in their own files: contribution workflow in
[CONTRIBUTING.md](CONTRIBUTING.md), the [Contributor Covenant Code of
Conduct](CODE_OF_CONDUCT.md).

## Scope and stack

- **OctoImage** is a Flutter widget maintained by [Baseflow](https://baseflow.com):
  a drop-in replacement for `Image` that adds a placeholder-or-progress phase, an
  error phase, and a post-load transform hook, with cross-fades between phases.
- Single package at the repo root, not a monorepo. There is no nested package
  directory to `cd` into.
- The package has no runtime dependencies beyond the Flutter SDK itself.
- Run Flutter and Dart commands with the same tooling CI uses (`flutter`, `dart`).
  Nothing in this repo requires anything else. If you happen to manage SDK
  versions locally with [fvm](https://fvm.app), prefix commands with `fvm`; that
  is a personal setup choice and is never checked in.

### Prerequisites

- Basic Dart and Flutter knowledge
- A working Flutter SDK installation, stable channel, matching CI, currently
  Flutter **3.47.4** (`FLUTTER_VERSION` in `.github/workflows/build.yaml`)
- For running or building the example on iOS/macOS, access to a Mac is required
- Android example builds require JDK 17

### Reference documentation

This package is a **Dart/Flutter widget library**, not a federated platform
plugin. Prefer official Flutter/Dart docs and this repo's existing code for
hands-on work:

- [Using packages](https://docs.flutter.dev/packages-and-plugins/using-packages)
- [Developing packages & plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages)
- [Effective Dart](https://dart.dev/effective-dart)
- [pub versioning philosophy](https://dart.dev/tools/pub/versioning)

## Architecture overview

`OctoImage` takes any `ImageProvider` and delegates all actual decoding to a
framework `Image`; it owns no networking and no caching of its own. The four
public builder typedefs in `lib/src/image/image.dart` are the extension points:

```
OctoImage(imageBuilder, placeholderBuilder, progressIndicatorBuilder, errorBuilder)
    → ImageHandler (lib/src/image/image_handler.dart, internal)
        maps the builders onto Image's frameBuilder / loadingBuilder / errorBuilder
        and inserts FadeWidget cross-fades between phases
    → Image (framework widget, does the actual decode)
```

`OctoSet` (`lib/src/octo_set.dart`) bundles a placeholder-or-progress builder
with an optional image builder and error builder, consumed by
`OctoImage.fromSet`. `OctoPlaceholder`, `OctoProgressIndicator`, `OctoError` and
`OctoImageTransformer` are namespaces of prebuilt builders that sets are usually
assembled from.

## Authoritative project structure

- Public API: `lib/octo_image.dart` (exports only; the widget itself lives under `lib/src/`)
- Core widget: `lib/src/image/image.dart` (`OctoImage`, the four builder typedefs)
- Adapter/engine, not exported: `lib/src/image/image_handler.dart` (`ImageHandler`)
- Cross-fade, not exported: `lib/src/image/fade_widget.dart` (`FadeWidget`)
- Builder bundle: `lib/src/octo_set.dart` (`OctoSet`)
- Prebuilt placeholders: `lib/src/placeholders.dart` (`OctoPlaceholder`)
- Prebuilt progress indicators: `lib/src/progress_indicators.dart` (`OctoProgressIndicator`)
- Prebuilt error widgets: `lib/src/errors.dart` (`OctoError`)
- Prebuilt transformers: `lib/src/image_transformers.dart` (`OctoImageTransformer`)
- Example app: `example/`
- CI: `.github/workflows/build.yaml`

## Where to make changes

- **Public API / docs for app developers** → `lib/src/image/image.dart` exports
  and `README.md`
- **New prebuilt placeholder / error / progress indicator / transformer** →
  the matching file in the list above, following the existing static-factory
  style
- **Cross-fade behavior** → `lib/src/image/fade_widget.dart`

Two things to know before changing `ImageHandler` or `OctoSet`:

- **Placeholder and progress indicator are mutually exclusive.** Both
  `OctoSet` and `ImageHandler` assert this. Do not add a code path that sets
  both.
- **`ImageHandler` carries mutable state across callbacks.**
  `_wasSynchronouslyLoaded` and `_isLoaded` are written by one callback
  (`_preLoadingBuilder`) and read by another (`_loadingBuilder`). Gapless
  playback lives in `_OctoImageState.didUpdateWidget`, which rebuilds the
  `ImageHandler` on every widget update rather than only when the inputs
  actually changed; that behavior is the subject of an open pull request, so
  check for one before changing it.

Keep changes minimal in scope; match existing naming and testing patterns.

## Development setup

Baseflow's open-source forking workflow:

1. Fork `https://github.com/Baseflow/octo_image` on GitHub.
2. Clone your fork: `git clone git@github.com:<your_name>/octo_image.git`
3. Add upstream (the official repo you fetch from, not your fork):

```bash
git remote add upstream git@github.com:Baseflow/octo_image.git
```

4. Branch from latest `develop`:

```bash
git fetch upstream
git checkout upstream/develop -b <name_of_your_branch>
```

Expected remotes after setup:

```
origin    git@github.com:<your_name>/octo_image.git   # your fork (push here)
upstream  git@github.com:Baseflow/octo_image.git       # official repo (fetch here)
```

## Commands

Run from the repository root:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

CI runs the same commands with stricter flags, on the pinned Flutter version
above. Bump `FLUTTER_VERSION` in `.github/workflows/build.yaml` in its own PR,
which needs a green run of its own, and keep it in step with the version
`flutter_cache_manager` pins.

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test --coverage
```

Run the example app:

```bash
cd example
flutter run
```

Before finishing work, run the same checks CI runs (format, analyze, test).

## Testing expectations

Four files under `test/`: `octo_image_test.dart` and `templates_test.dart`
exercise the widget and the prebuilt builders, using `MockImageProvider` and a
transparent-image byte fixture under `test/helpers/`. There are no golden
tests.

Not covered directly: `FadeWidget`, `ImageHandler`, gapless playback
(`didUpdateWidget`), the `OctoSet` factories, and `OctoImage.fromSet`.

## Pull request workflow

**`develop` is the branch of record.** Fork from `upstream/develop`, open every
PR against `develop`, and rebase onto `develop` before submitting. `main` and
`master` are leftovers from an earlier branch layout: they are not maintained,
and must not be branched from or targeted. A move to a main-only model, matching
Baseflow's other cache packages, is planned; until it lands, `develop` is the
one to use.

This repo uses the **forking workflow**: contributors work on their own fork and
open PRs to the main repository. Maintainers review and merge; do not push
directly to `Baseflow/octo_image`.

1. Apply changes on a branch based on `upstream/develop`.
2. Verify locally:
   - `dart format .`
   - `flutter analyze`
   - `flutter test`
3. Push to your fork: `git push origin <name_of_your_branch>`
4. Open a PR against `Baseflow/octo_image` and fill out the full
   [PR template](.github/PULL_REQUEST_TEMPLATE.md).

Keep public API changes additive and non-breaking where possible; breaking
changes need a clear major-version plan and README/CHANGELOG callouts.

### PR description style

**Hard requirement**: use the [PR template](.github/PULL_REQUEST_TEMPLATE.md)'s
actual section headings verbatim — `What kind of change does this PR
introduce?`, `What is the current behavior?`, `What is the new behavior (if
this is a feature change)?`, `Does this PR introduce a breaking change?`,
`Recommendations for testing`, `Links to relevant issues/docs`, and the
`Checklist before submitting` with its exact four items. Do not substitute a
different structure even for small or maintainer-authored PRs.

Fill out the [PR template](.github/PULL_REQUEST_TEMPLATE.md), but keep each
section tight:

- State what changed and why. Don't narrate your own editing process.
- Don't repeat file paths in prose; the diff already shows them.
- Answer yes/no questions with a plain yes/no; add a sentence only when the
  answer is non-obvious. "Does this introduce a breaking change?" is the
  exception: answer "No" alone when it's not, but when it is, give a short
  explanation of what breaks and for whom.
- Keep "Recommendations for testing" to what a reviewer needs to act on.

### PR checklist

The repository's own template checklist:

- [ ] All projects build
- [ ] Follows style guide lines
- [ ] Relevant documentation was updated
- [ ] Rebased onto current `develop`

## Releases

One package, one tag scheme. Only maintainers cut releases.

1. Open a release PR against `develop`: add an entry under a new dated
   `## [x.y.z] - YYYY-MM-DD` heading in `CHANGELOG.md`, in the style already in
   use (see below), and bump `version:` in `pubspec.yaml`.
2. Verify: `dart format --set-exit-if-changed .`, `flutter analyze`,
   `flutter test`, and `dart pub publish --dry-run`.
3. Merge once CI is green, then tag the resulting commit `vX.Y.Z`.
4. Push the tag. **Pushing the tag is what publishes**: `build.yaml` runs
   `dart pub publish` via pub.dev OIDC trusted publishing, gated on
   `github.ref_type == 'tag'`. Never run `dart pub publish` by hand, and never
   bump a version without a tag to match.

`CHANGELOG.md` today uses `## [x.y.z] - YYYY-MM-DD` headings with `*` bullets
and no `## [Unreleased]` section. Match that format; introducing an
`[Unreleased]` section is a separate decision and not something to do as part
of an unrelated change.

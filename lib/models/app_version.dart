import 'package:fro/models/bump_strategy.dart';

/// Represents a parsed Flutter app version.
///
/// Versions follow semver with a build number: `1.2.3+45`.
/// Git tags include an environment prefix: `prod-v1.2.3+45`.
class AppVersion {
  const AppVersion({
    required this.major,
    required this.minor,
    required this.patch,
    required this.build,
  });

  final int major;
  final int minor;
  final int patch;
  final int build;

  /// Parses a version string like `1.2.3+45`.
  static AppVersion parse(String version) {
    final match = RegExp(
      r'^(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)\+(?<build>\d+)$',
    ).firstMatch(version);

    if (match == null) {
      throw FormatException(
          'Invalid version format: "$version". Expected MAJOR.MINOR.PATCH+BUILD.');
    }

    return AppVersion(
      major: int.parse(match.namedGroup('major')!),
      minor: int.parse(match.namedGroup('minor')!),
      patch: int.parse(match.namedGroup('patch')!),
      build: int.parse(match.namedGroup('build')!),
    );
  }

  /// Returns a new version with the [strategy] component incremented and [newBuild] applied.
  ///
  /// Minor bumps reset patch to 0. Major bumps reset both minor and patch.
  AppVersion bump(BumpStrategy strategy, {required int newBuild}) {
    return switch (strategy) {
      BumpStrategy.major =>
        AppVersion(major: major + 1, minor: 0, patch: 0, build: newBuild),
      BumpStrategy.minor =>
        AppVersion(major: major, minor: minor + 1, patch: 0, build: newBuild),
      BumpStrategy.patch => AppVersion(
          major: major, minor: minor, patch: patch + 1, build: newBuild),
    };
  }

  /// Returns true if this version is strictly newer than [other].
  bool isNewerThan(AppVersion other) {
    if (major != other.major) return major > other.major;
    if (minor != other.minor) return minor > other.minor;
    if (patch != other.patch) return patch > other.patch;
    return build > other.build;
  }

  @override
  String toString() => '$major.$minor.$patch+$build';
}

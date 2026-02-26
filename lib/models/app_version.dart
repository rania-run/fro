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

  @override
  String toString() => '$major.$minor.$patch+$build';
}

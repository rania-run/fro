/// The semver component to increment on a version bump.
enum BumpStrategy {
  major,
  minor,
  patch;

  /// Parses [value] (case-insensitive) into a [BumpStrategy].
  ///
  /// Throws [ArgumentError] for unknown values.
  static BumpStrategy parse(String value) {
    return switch (value.toLowerCase()) {
      'major' => BumpStrategy.major,
      'minor' => BumpStrategy.minor,
      'patch' => BumpStrategy.patch,
      _ => throw ArgumentError(
          'Unknown strategy: "$value". Expected major, minor, or patch.',
        ),
    };
  }
}

import 'dart:io';

import 'package:fro/models/app_version.dart';

/// Signature for running a process — injectable for testing.
typedef ProcessRunner = Future<ProcessResult> Function(
  String executable,
  List<String> arguments,
);

Future<ProcessResult> _defaultRunner(
  String executable,
  List<String> arguments,
) =>
    Process.run(executable, arguments);

/// Runs git commands and parses environment version tags.
///
/// Tag format: `env-vMAJOR.MINOR.PATCH+BUILD` (e.g. `prod-v1.2.3+45`).
class GitService {
  const GitService({ProcessRunner runner = _defaultRunner}) : _run = runner;

  final ProcessRunner _run;

  static final _tagPattern = RegExp(
    r'^(?<env>[a-zA-Z][\w-]*?)-v(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)\+(?<build>\d+)$',
  );

  /// Pattern that a valid environment name must match.
  static final envPattern = RegExp(r'^[a-zA-Z][\w-]*$');

  /// Returns all git tags in the repository.
  ///
  /// Throws [GitException] if the git command fails.
  Future<List<String>> tags() async {
    final result =
        await _run('git', ['tag', '--list', '--sort=-version:refname']);
    _assertSuccess(result, 'git tag');
    final output = (result.stdout as String).trim();
    if (output.isEmpty) return [];
    return output
        .split('\n')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  /// Returns the latest version for [env] parsed from git tags, or null if none exist.
  Future<AppVersion?> latestTagForEnv(String env) async {
    final allTags = await tags();
    final versions = allTags
        .where((t) {
          final m = _tagPattern.firstMatch(t);
          return m != null && m.namedGroup('env') == env;
        })
        .map(_parseTagVersion)
        .whereType<AppVersion>()
        .toList();

    if (versions.isEmpty) return null;
    return versions.reduce((a, b) => a.isNewerThan(b) ? a : b);
  }

  /// Returns the latest version tag for every environment found in git tags.
  Future<Map<String, AppVersion>> latestTagsPerEnv() async {
    final allTags = await tags();
    final result = <String, AppVersion>{};

    for (final tag in allTags) {
      final match = _tagPattern.firstMatch(tag);
      if (match == null) continue;
      final env = match.namedGroup('env')!;
      final version = _parseTagVersion(tag);
      if (version == null) continue;
      final existing = result[env];
      if (existing == null || version.isNewerThan(existing)) {
        result[env] = version;
      }
    }

    return result;
  }

  /// Creates a local git tag [tag].
  ///
  /// Throws [GitException] if the tag already exists or the command fails.
  Future<void> createTag(String tag) async {
    final result = await _run('git', ['tag', tag]);
    _assertSuccess(result, 'git tag $tag');
  }

  /// Pushes tag [tag] to origin.
  Future<void> pushTag(String tag) async {
    final result = await _run('git', ['push', 'origin', tag]);
    _assertSuccess(result, 'git push origin $tag');
  }

  /// Returns the current branch name.
  Future<String> currentBranch() async {
    final result = await _run('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
    _assertSuccess(result, 'git rev-parse');
    return (result.stdout as String).trim();
  }

  void _assertSuccess(ProcessResult result, String command) {
    if (result.exitCode != 0) {
      throw GitException('`$command` failed: ${result.stderr}');
    }
  }

  AppVersion? _parseTagVersion(String tag) {
    final match = _tagPattern.firstMatch(tag);
    if (match == null) return null;
    return AppVersion(
      major: int.parse(match.namedGroup('major')!),
      minor: int.parse(match.namedGroup('minor')!),
      patch: int.parse(match.namedGroup('patch')!),
      build: int.parse(match.namedGroup('build')!),
    );
  }
}

/// Thrown when a git command exits with a non-zero code.
class GitException implements Exception {
  const GitException(this.message);
  final String message;

  @override
  String toString() => 'GitException: $message';
}

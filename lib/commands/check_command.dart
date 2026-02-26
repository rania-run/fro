import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:chalkdart/chalkdart.dart';
import 'package:fro/services/git_service.dart';
import 'package:fro/services/version_service.dart';

/// `fro check` — shows the current app version.
///
/// Without flags: reads from pubspec.yaml.
/// With --env: also shows the latest git tag for that environment and
/// whether pubspec is in sync.
///
/// Usage:
///   fro check
///   fro check --env=prod
class CheckCommand extends Command<void> {
  CheckCommand({
    VersionService? versionService,
    GitService? gitService,
  })  : _versions =
            versionService ?? const VersionService(pubspecPath: 'pubspec.yaml'),
        _git = gitService ?? const GitService();

  @override
  final String name = 'check';

  @override
  final String description = 'Show the current app version.';

  final VersionService _versions;
  final GitService _git;

  @override
  ArgParser get argParser => ArgParser()
    ..addOption(
      'env',
      abbr: 'e',
      help:
          'Compare pubspec version against the latest git tag for this environment.',
      valueHelp: 'prod|stg|dev',
    );

  @override
  Future<void> run() async {
    final env = argResults?['env'] as String?;

    try {
      final pubspecVersion = _versions.readVersion();
      stdout.writeln('${chalk.bold('pubspec:')} $pubspecVersion');

      if (env != null) {
        final tagVersion = await _git.latestTagForEnv(env);

        if (tagVersion == null) {
          stdout.writeln(
              '${chalk.bold('git/$env:')} ${chalk.yellow('no tags found')}');
        } else {
          final inSync = pubspecVersion.toString() == tagVersion.toString();
          final status = inSync
              ? chalk.green('✓ in sync')
              : chalk.yellow('✗ not tagged yet');
          stdout.writeln('${chalk.bold('git/$env:')} $tagVersion  $status');
        }
      }
    } on FileSystemException catch (e) {
      stderr.writeln(chalk.red('File error: ${e.message} — ${e.path}'));
      exitCode = 1;
    } on FormatException catch (e) {
      stderr.writeln(chalk.red('Error: ${e.message}'));
      exitCode = 1;
    } on GitException catch (e) {
      stderr.writeln(chalk.red('Git error: ${e.message}'));
      exitCode = 1;
    }
  }
}

import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:chalkdart/chalkdart.dart';
import 'package:fro/models/bump_strategy.dart';
import 'package:fro/services/git_service.dart';
import 'package:fro/services/version_service.dart';

/// `fro bump` — bumps the app version and creates a git tag.
///
/// Reads the current version from pubspec.yaml, increments the requested
/// semver component, increments the build number based on the latest git
/// tag for the environment, writes the new version back to pubspec.yaml,
/// and creates a git tag in the format `env-vMAJOR.MINOR.PATCH+BUILD`.
///
/// Usage:
///   fro bump --env=prod --strategy=patch
///   fro bump --env=stg  --strategy=minor
///   fro bump --env=prod --strategy=patch --ci   # skip confirmation
class BumpCommand extends Command<void> {
  BumpCommand({
    VersionService? versionService,
    GitService? gitService,
  })  : _versions =
            versionService ?? const VersionService(pubspecPath: 'pubspec.yaml'),
        _git = gitService ?? const GitService();

  @override
  final String name = 'bump';

  @override
  final String description = 'Bump the app version and create a git tag.';

  final VersionService _versions;
  final GitService _git;

  @override
  ArgParser get argParser => ArgParser()
    ..addOption(
      'env',
      abbr: 'e',
      help: 'Target environment.',
      valueHelp: 'prod|stg|dev',
      mandatory: true,
    )
    ..addOption(
      'strategy',
      abbr: 's',
      help: 'Which semver component to bump.',
      allowed: ['major', 'minor', 'patch'],
      allowedHelp: {
        'major': 'Breaking change: 1.0.0 → 2.0.0',
        'minor': 'New feature:     1.0.0 → 1.1.0',
        'patch': 'Bug fix:         1.0.0 → 1.0.1',
      },
      defaultsTo: 'patch',
    )
    ..addFlag(
      'ci',
      help: 'Skip confirmation prompts (for CI pipelines).',
      negatable: false,
    )
    ..addFlag(
      'no-push',
      help: 'Create the git tag locally without pushing to origin.',
      negatable: false,
    );

  static final _envPattern = RegExp(r'^[a-zA-Z][\w-]*$');

  @override
  Future<void> run() async {
    final env = argResults!['env'] as String;
    final strategy = BumpStrategy.parse(argResults!['strategy'] as String);
    final ci = argResults!['ci'] as bool;
    final noPush = argResults!['no-push'] as bool;

    if (!_envPattern.hasMatch(env)) {
      stderr.writeln(chalk.red(
        'Invalid --env "$env": must start with a letter and contain only letters, digits, underscores, or hyphens.',
      ));
      exitCode = 1;
      return;
    }

    try {
      final current = _versions.readVersion();
      final latestTag = await _git.latestTagForEnv(env);
      final latestBuild = latestTag?.build ?? current.build;
      final next = current.bump(strategy, newBuild: latestBuild + 1);
      final tag = '$env-v$next';

      _printPlan(
          env: env, current: current, next: next, tag: tag, noPush: noPush);

      if (!ci && !_confirm()) {
        stdout.writeln(chalk.yellow('Aborted.'));
        return;
      }

      _versions.writeVersion(next);
      stdout.writeln(chalk.green('✓ pubspec.yaml updated to $next'));

      await _git.createTag(tag);
      stdout.writeln(chalk.green('✓ git tag $tag created'));

      if (!noPush) {
        await _git.pushTag(tag);
        stdout.writeln(chalk.green('✓ tag pushed to origin'));
      }
    } on FileSystemException catch (e) {
      stderr.writeln(chalk.red('File error: ${e.message} — ${e.path}'));
      exitCode = 1;
    } on ArgumentError catch (e) {
      stderr.writeln(chalk.red('Error: $e'));
      exitCode = 1;
    } on FormatException catch (e) {
      stderr.writeln(chalk.red('Error: ${e.message}'));
      exitCode = 1;
    } on GitException catch (e) {
      stderr.writeln(chalk.red('Git error: ${e.message}'));
      exitCode = 1;
    }
  }

  void _printPlan({
    required String env,
    required Object current,
    required Object next,
    required String tag,
    required bool noPush,
  }) {
    stdout.writeln('');
    stdout.writeln('  ${chalk.bold('current:')} $current');
    stdout.writeln('  ${chalk.bold('next:')}    $next');
    stdout.writeln('  ${chalk.bold('tag:')}     $tag');
    if (noPush) stdout.writeln('  ${chalk.yellow('(tag will not be pushed)')}');
    stdout.writeln('');
  }

  bool _confirm() {
    stdout.write('Apply? [y/N] ');
    final input = stdin.readLineSync()?.trim().toLowerCase();
    return input == 'y' || input == 'yes';
  }
}

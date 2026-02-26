import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:chalkdart/chalkdart.dart';
import 'package:fro/services/version_service.dart';

/// `fro check` — prints the current version from `pubspec.yaml`.
///
/// Usage:
///   fro check
class CheckCommand extends Command<void> {
  @override
  final String name = 'check';

  @override
  final String description = 'Show the current app version from pubspec.yaml.';

  @override
  Future<void> run() async {
    final pubspecPath = argResults?.rest.firstOrNull ?? 'pubspec.yaml';
    final service = VersionService(pubspecPath: pubspecPath);

    try {
      final version = service.readVersion();
      stdout.writeln('${chalk.bold('Version:')} $version');
    } on FormatException catch (e) {
      stderr.writeln(chalk.red('Error: ${e.message}'));
    }
  }
}

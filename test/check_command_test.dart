import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fro/commands/check_command.dart';
import 'package:fro/models/app_version.dart';
import 'package:fro/services/git_service.dart';
import 'package:fro/services/version_service.dart';
import 'package:test/test.dart';

class _FakeVersionService extends VersionService {
  _FakeVersionService() : super(pubspecPath: '');

  @override
  AppVersion readVersion() => AppVersion.parse('1.0.0+1');
}

CommandRunner<void> _runner({String gitOutput = ''}) =>
    CommandRunner<void>('fro', '')
      ..addCommand(CheckCommand(
        versionService: _FakeVersionService(),
        gitService: GitService(
          runner: (_, __) async => ProcessResult(0, 0, gitOutput, ''),
        ),
      ));

void main() {
  group('CheckCommand --env validation', () {
    setUp(() => exitCode = 0);

    test('rejects env starting with a digit', () async {
      await _runner().run(['check', '--env=1prod']);
      expect(exitCode, 1);
    });

    test('rejects env with dots', () async {
      await _runner().run(['check', '--env=prod.us']);
      expect(exitCode, 1);
    });

    test('accepts simple env', () async {
      await _runner().run(['check', '--env=prod']);
      expect(exitCode, 0);
    });

    test('accepts hyphenated env', () async {
      await _runner().run(['check', '--env=prod-us']);
      expect(exitCode, 0);
    });
  });

  group('CheckCommand without --env', () {
    setUp(() => exitCode = 0);

    test('exits successfully', () async {
      await _runner().run(['check']);
      expect(exitCode, 0);
    });
  });

  group('CheckCommand with --env and tags', () {
    setUp(() => exitCode = 0);

    test('exits successfully when env has no tags', () async {
      await _runner(gitOutput: '').run(['check', '--env=prod']);
      expect(exitCode, 0);
    });

    test('exits successfully when env has a matching tag', () async {
      await _runner(gitOutput: 'prod-v1.0.0+1\n').run(['check', '--env=prod']);
      expect(exitCode, 0);
    });
  });
}

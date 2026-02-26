import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fro/commands/bump_command.dart';
import 'package:fro/models/app_version.dart';
import 'package:fro/services/git_service.dart';
import 'package:fro/services/version_service.dart';
import 'package:test/test.dart';

class _FakeVersionService extends VersionService {
  _FakeVersionService() : super(pubspecPath: '');

  @override
  AppVersion readVersion() => AppVersion.parse('1.0.0+1');

  @override
  void writeVersion(AppVersion v) {}
}

CommandRunner<void> _runner() => CommandRunner<void>('fro', '')
  ..addCommand(BumpCommand(
    versionService: _FakeVersionService(),
    gitService: GitService(
      runner: (_, __) async => ProcessResult(0, 0, '', ''),
    ),
  ));

void main() {
  group('BumpCommand --env validation', () {
    setUp(() => exitCode = 0);

    test('rejects env starting with a digit', () async {
      await _runner().run(['bump', '--env=1prod', '--ci']);
      expect(exitCode, 1);
    });

    test('rejects env with invalid characters', () async {
      await _runner().run(['bump', '--env=prod.us', '--ci']);
      expect(exitCode, 1);
    });

    test('accepts simple env', () async {
      await _runner().run(['bump', '--env=prod', '--ci', '--no-push']);
      expect(exitCode, 0);
    });

    test('accepts hyphenated env', () async {
      await _runner().run(['bump', '--env=prod-us', '--ci', '--no-push']);
      expect(exitCode, 0);
    });
  });
}

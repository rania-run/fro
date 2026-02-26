import 'dart:io';

import 'package:fro/services/git_service.dart';
import 'package:test/test.dart';

/// Builds a fake [ProcessRunner] that returns [stdout] with exit code 0.
ProcessRunner _fakeRunner(String stdout) {
  return (executable, args) async => ProcessResult(0, 0, stdout, '');
}

/// Builds a fake [ProcessRunner] that fails with [stderr].
ProcessRunner _failingRunner(String stderr) {
  return (executable, args) async => ProcessResult(0, 1, '', stderr);
}

void main() {
  group('GitService.tags', () {
    test('returns parsed list of tags', () async {
      final svc =
          GitService(runner: _fakeRunner('prod-v1.0.0+1\nstg-v1.0.0+2\n'));
      expect(await svc.tags(), ['prod-v1.0.0+1', 'stg-v1.0.0+2']);
    });

    test('returns empty list when no tags exist', () async {
      final svc = GitService(runner: _fakeRunner(''));
      expect(await svc.tags(), isEmpty);
    });

    test('throws GitException when git command fails', () async {
      final svc = GitService(runner: _failingRunner('not a git repo'));
      expect(svc.tags(), throwsA(isA<GitException>()));
    });
  });

  group('GitService.latestTagForEnv', () {
    test('returns latest version for the requested env', () async {
      final svc = GitService(
        runner: _fakeRunner(
          'prod-v1.0.0+1\nprod-v1.2.0+5\nprod-v1.1.0+3\nstg-v2.0.0+10\n',
        ),
      );
      final version = await svc.latestTagForEnv('prod');
      expect(version.toString(), '1.2.0+5');
    });

    test('returns null when no tags exist for the env', () async {
      final svc = GitService(runner: _fakeRunner('stg-v1.0.0+1\n'));
      expect(await svc.latestTagForEnv('prod'), isNull);
    });

    test('ignores tags from other environments', () async {
      final svc =
          GitService(runner: _fakeRunner('stg-v9.9.9+99\nprod-v1.0.0+1\n'));
      final version = await svc.latestTagForEnv('prod');
      expect(version.toString(), '1.0.0+1');
    });
  });

  group('GitService.latestTagsPerEnv', () {
    test('returns latest version per environment', () async {
      final svc = GitService(
        runner: _fakeRunner('prod-v1.2.0+5\nstg-v1.3.0+8\ndev-v0.1.0+2\n'),
      );
      final map = await svc.latestTagsPerEnv();
      expect(map['prod']!.toString(), '1.2.0+5');
      expect(map['stg']!.toString(), '1.3.0+8');
      expect(map['dev']!.toString(), '0.1.0+2');
    });

    test('returns empty map when no tags exist', () async {
      final svc = GitService(runner: _fakeRunner(''));
      expect(await svc.latestTagsPerEnv(), isEmpty);
    });
  });

  group('GitService.currentBranch', () {
    test('returns trimmed branch name', () async {
      final svc = GitService(runner: _fakeRunner('feature/my-branch\n'));
      expect(await svc.currentBranch(), 'feature/my-branch');
    });
  });

  group('GitService.createTag', () {
    test('throws GitException when tag already exists', () async {
      final svc = GitService(runner: _failingRunner('tag already exists'));
      expect(svc.createTag('prod-v1.0.0+1'), throwsA(isA<GitException>()));
    });
  });

  group('GitService.pushTag', () {
    test('throws GitException when push fails', () async {
      final svc = GitService(runner: _failingRunner('failed to push tag'));
      expect(svc.pushTag('prod-v1.0.0+1'), throwsA(isA<GitException>()));
    });

    test('calls git push with correct arguments', () async {
      String? capturedExecutable;
      List<String>? capturedArgs;

      final svc = GitService(
        runner: (executable, args) async {
          capturedExecutable = executable;
          capturedArgs = args;
          return ProcessResult(0, 0, '', '');
        },
      );

      await svc.pushTag('prod-v1.0.0+1');

      expect(capturedExecutable, 'git');
      expect(capturedArgs, ['push', 'origin', 'prod-v1.0.0+1']);
    });
  });
}

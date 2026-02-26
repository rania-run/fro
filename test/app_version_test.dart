import 'package:fro/models/app_version.dart';
import 'package:fro/models/bump_strategy.dart';
import 'package:test/test.dart';

void main() {
  group('AppVersion.parse', () {
    test('parses a valid version string', () {
      final v = AppVersion.parse('1.2.3+45');
      expect(v.major, 1);
      expect(v.minor, 2);
      expect(v.patch, 3);
      expect(v.build, 45);
    });

    test('toString round-trips correctly', () {
      const input = '1.2.3+45';
      expect(AppVersion.parse(input).toString(), input);
    });

    test('throws FormatException for invalid input', () {
      expect(() => AppVersion.parse('1.2.3'), throwsFormatException);
      expect(() => AppVersion.parse('bad'), throwsFormatException);
      expect(() => AppVersion.parse(''), throwsFormatException);
    });
  });

  group('AppVersion.bump', () {
    final base = AppVersion.parse('1.2.3+10');

    test('patch increments patch and build', () {
      final v = base.bump(BumpStrategy.patch, newBuild: 11);
      expect(v.toString(), '1.2.4+11');
    });

    test('minor increments minor, resets patch, increments build', () {
      final v = base.bump(BumpStrategy.minor, newBuild: 11);
      expect(v.toString(), '1.3.0+11');
    });

    test('major increments major, resets minor and patch, increments build',
        () {
      final v = base.bump(BumpStrategy.major, newBuild: 11);
      expect(v.toString(), '2.0.0+11');
    });
  });

  group('BumpStrategy.parse', () {
    test('parses all valid strategies case-insensitively', () {
      expect(BumpStrategy.parse('patch'), BumpStrategy.patch);
      expect(BumpStrategy.parse('MINOR'), BumpStrategy.minor);
      expect(BumpStrategy.parse('Major'), BumpStrategy.major);
    });

    test('throws ArgumentError for unknown value', () {
      expect(() => BumpStrategy.parse('hotfix'), throwsArgumentError);
      expect(() => BumpStrategy.parse(''), throwsArgumentError);
    });
  });

  group('AppVersion.isNewerThan', () {
    test('higher major is newer', () {
      expect(
          AppVersion.parse('2.0.0+1').isNewerThan(AppVersion.parse('1.9.9+99')),
          isTrue);
    });

    test('higher minor is newer when major is equal', () {
      expect(
          AppVersion.parse('1.2.0+1').isNewerThan(AppVersion.parse('1.1.9+99')),
          isTrue);
    });

    test('higher patch is newer when major and minor are equal', () {
      expect(
          AppVersion.parse('1.0.1+1').isNewerThan(AppVersion.parse('1.0.0+99')),
          isTrue);
    });

    test('higher build is newer when semver is equal', () {
      expect(
          AppVersion.parse('1.0.0+5').isNewerThan(AppVersion.parse('1.0.0+4')),
          isTrue);
    });

    test('same version is not newer', () {
      expect(
          AppVersion.parse('1.0.0+1').isNewerThan(AppVersion.parse('1.0.0+1')),
          isFalse);
    });
  });
}

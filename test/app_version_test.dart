import 'package:fro/models/app_version.dart';
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
}

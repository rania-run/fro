import 'dart:io';
import 'package:fro/models/app_version.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Reads and writes the version field in a Flutter project's `pubspec.yaml`.
class VersionService {
  const VersionService({required this.pubspecPath});

  final String pubspecPath;

  /// Returns the current version from `pubspec.yaml`.
  ///
  /// Throws [FileSystemException] if the file does not exist.
  /// Throws [FormatException] if the version field is missing or invalid.
  AppVersion readVersion() {
    final content = File(pubspecPath).readAsStringSync();
    final match =
        RegExp(r'^version:\s*(.+)$', multiLine: true).firstMatch(content);

    if (match == null) {
      throw const FormatException('No version field found in pubspec.yaml.');
    }

    return AppVersion.parse(match.group(1)!.trim());
  }

  /// Writes [version] to the `version` field in `pubspec.yaml`.
  ///
  /// Preserves all comments and formatting in the file.
  void writeVersion(AppVersion version) {
    final content = File(pubspecPath).readAsStringSync();
    final editor = YamlEditor(content);
    editor.update(['version'], version.toString());
    File(pubspecPath).writeAsStringSync(editor.toString());
  }
}

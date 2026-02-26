import 'package:args/command_runner.dart';
import 'package:fro/commands/check_command.dart';

Future<void> main(List<String> arguments) async {
  final runner = CommandRunner<void>(
    'fro',
    'Flutter release manager — manage versions across environments.',
  )..addCommand(CheckCommand());

  await runner.run(arguments);
}

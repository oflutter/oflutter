import 'package:args/command_runner.dart';

Future<void> main(List<String> arguments) {
  const name = 'oflutter';
  const description = 'OFlutter command line tool.';
  final runner = CommandRunner<void>(name, description);

  return runner.run(arguments);
}

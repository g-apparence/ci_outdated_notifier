import 'package:ci_outdated_notifier/ci_outdated_notifier.dart'
    as ci_outdated_notifier;
import 'dart:io';
import 'package:args/args.dart';

const help = 'help';
const filePath = 'filePath';

late ArgResults argResults;

Future<void> main(List<String> arguments) async {
  exitCode = 0;
  final argParser = ArgParser()
    ..addOption(filePath,
        abbr: 'p', callback: (r) => r, help: 'pubspec file Path')
    ..addFlag(help, negatable: false, abbr: 'h', help: 'show help');
  argResults = argParser.parse(arguments);
  //---------
  if (argResults.wasParsed(help)) {
    stdout.writeln('Perfcli help: ');
    stdout.writeln(argParser.usage);
    return;
  }
  if (argResults[filePath] == null) {
    stdout.writeln('Perfcli help: ');
    stdout.writeln(argParser.usage);
    return;
  }
  //---------
  await ci_outdated_notifier.getOutdatedDependencies(argResults[filePath]);
}

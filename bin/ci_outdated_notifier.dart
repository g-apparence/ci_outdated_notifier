import 'package:ci_outdated_notifier/ci_outdated_notifier.dart' as app;
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
  final res = await app.getOutdatedDependencies(argResults[filePath]);
  if (res.dependencies.isEmpty) {
    stdout.writeln('...No outdated dependencies found.');
    return;
  }
  if (res.dependencies.isNotEmpty) {
    stderr.writeln('Outdated dependencies:');
    res.dependencies.forEach((key, value) {
      stderr.writeln('$key: ${value.current} -> ${value.latest}');
    });
    throw Exception("Outdated dependencies found.");
  }
}

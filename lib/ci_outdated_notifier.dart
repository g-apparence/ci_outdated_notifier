import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:pub_updater/pub_updater.dart';

final pubUpdater = PubUpdater();

class OutdatedDependencies {
  final Map<String, Version> dependencies;
  final Map<String, Version> devDependencies;

  OutdatedDependencies({
    required this.dependencies,
    required this.devDependencies,
  });
}

class Version {
  final String current;
  final String? latest;

  Version({
    required this.current,
    this.latest,
  });
}

Future<OutdatedDependencies> getOutdatedDependencies(String pubspecPath) async {
  File file = File(pubspecPath);
  if (!file.existsSync()) {
    throw Exception('File not found: $pubspecPath');
  }
  String yamlString = file.readAsStringSync();
  Map yaml = loadYaml(yamlString);
  YamlMap dependencies = yaml['dependencies'];
  YamlMap devDependencies = yaml['dev_dependencies'];
  final outdated = <String, Version>{};
  final outdatedDevDeps = <String, Version>{};
  for (final dependency in dependencies.keys) {
    print('checking dependency: $dependency');
    final isUpToDate = await _isUpToDate(
      dependency,
      dependencies[dependency],
    );
    if (!isUpToDate) {
      final lastVersion = await pubUpdater.getLatestVersion(dependency);
      final currentVersion = dependencies[dependency];
      outdated.putIfAbsent(
        dependency,
        () => Version(
          current: currentVersion,
          latest: lastVersion,
        ),
      );
    }
  }
  for (final dependency in devDependencies.keys) {
    print('checking dev dependency: $dependency');
    final isUpToDate = await _isUpToDate(
      dependency,
      devDependencies[dependency],
    );
    if (!isUpToDate) {
      final lastVersion = await pubUpdater.getLatestVersion(dependency);
      final currentVersion = devDependencies[dependency];
      outdatedDevDeps.putIfAbsent(
        dependency,
        () => Version(
          current: currentVersion,
          latest: lastVersion,
        ),
      );
    }
  }
  if (outdated.isEmpty) {
    print('...No outdated dependencies found.');
  }
  print('Outdated dependencies:');
  for (final dependency in outdated.keys) {
    print(
        '  $dependency  ${outdated[dependency]!.current}} => ${outdated[dependency]!.latest}}');
  }
  print('Outdated dev dependencies:');
  for (final dependency in outdatedDevDeps.keys) {
    print(
        '  $dependency  ${outdatedDevDeps[dependency]!.current}} => ${outdatedDevDeps[dependency]!.latest}}');
  }
  return OutdatedDependencies(
    dependencies: outdated,
    devDependencies: outdatedDevDeps,
  );
}

Future<bool> _isUpToDate(
  final String packageName,
  final dynamic currentVersion,
) async {
  if (currentVersion is YamlMap) {
    return true;
  }
  String currentVersionCpy = currentVersion;
  if (currentVersionCpy.startsWith('^')) {
    currentVersionCpy = currentVersionCpy.substring(1);
  }
  final isUpToDate = await pubUpdater.isUpToDate(
    packageName: packageName,
    currentVersion: currentVersionCpy,
  );
  return isUpToDate;
}

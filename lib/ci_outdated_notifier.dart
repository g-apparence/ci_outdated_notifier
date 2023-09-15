import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pub_updater/src/models/models.dart';

final pubUpdater = PubUpdater();

class OutdatedDependencies {
  final Map<String, DependencyVersion> dependencies;

  OutdatedDependencies({
    required this.dependencies,
  });
}

class DependencyVersion {
  final String current;
  final String? latest;

  DependencyVersion({
    required this.current,
    this.latest,
  });
}

/// list outdated dependencies and ignores minor patch updates
Future<OutdatedDependencies> getOutdatedDependencies(String pubspecPath) async {
  File file = File(pubspecPath);
  if (!file.existsSync()) {
    throw Exception('File not found: $pubspecPath');
  }
  String yamlString = file.readAsStringSync();
  Map yaml = loadYaml(yamlString);
  YamlMap dependencies = yaml['dependencies'];
  final outdated = <String, DependencyVersion>{};
  for (final dependency in dependencies.keys) {
    print('checking dependency: $dependency');
    if (dependencies[dependency] is YamlMap) {
      continue;
    }
    var isUpToDate = await _isUpToDate(
      dependency,
      dependencies[dependency],
    );
    final lastVersion = await pubUpdater.getLatestVersion(dependency);
    final currentVersion = dependencies[dependency];
    final currentVersionDesc = Version.parse(parseVersion(currentVersion));
    final latestVersionDesc = Version.parse(parseVersion(lastVersion));
    final hasMinorPatchOnly =
        latestVersionDesc.major == currentVersionDesc.major &&
            latestVersionDesc.minor == currentVersionDesc.minor &&
            latestVersionDesc.patch != currentVersionDesc.patch &&
            currentVersion.startsWith('^');
    if (hasMinorPatchOnly) {
      isUpToDate = true;
    }
    if (!isUpToDate) {
      outdated.putIfAbsent(
        dependency,
        () => DependencyVersion(
          current: currentVersion,
          latest: lastVersion,
        ),
      );
    }
  }
  return OutdatedDependencies(
    dependencies: outdated,
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

String parseVersion(String version) {
  if (version.startsWith('^')) {
    return version.substring(1);
  }
  return version;
}

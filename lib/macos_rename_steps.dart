import 'dart:async';
import 'dart:io';

import './file_utils.dart';

class MacosRenameSteps {
  final String newPackageName;
  String? oldPackageName;
  static const String PATH_PROJECT_FILE =
      'macos/Runner.xcodeproj/project.pbxproj';

  static const String PATH_CONFIG_FILE =
      'macos/Runner/Configs/AppInfo.xcconfig';

  MacosRenameSteps(this.newPackageName);

  Future<void> process() async {
    print("Running for macos");
    if (!await File(PATH_PROJECT_FILE).exists() ||
        !await File(PATH_CONFIG_FILE).exists()) {
      print(
          'ERROR:: project.pbxproj or AppInfo.xcconfig file not found, Check if you have a correct macos directory present in your project'
          '\n\nrun " flutter create . " to regenerate missing files.');
      return;
    }
    String? contents = await readFileAsString(PATH_PROJECT_FILE);
    String? configContents = await readFileAsString(PATH_CONFIG_FILE);

    var reg = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER\s*=?\s*(.*);',
        caseSensitive: true, multiLine: false);
    var match = reg.firstMatch(contents!);
    var match_config = reg.firstMatch(configContents!);
    if (match == null || match_config == null) {
      print(
          'ERROR:: Bundle Identifier not found in project.pbxproj or AppInfo.xcconfig file, Please file an issue on github with $PATH_PROJECT_FILE or $PATH_CONFIG_FILE file attached.');
      return;
    }
    var name = match.group(1);
    oldPackageName = name;

    print("Old Package Name: $oldPackageName");

    print('Updating project.pbxproj File');
    await _replace(PATH_PROJECT_FILE);
    print('Finished updating macos bundle identifier');

    print('Updating AppInfo.xcconfig File');
    await _replace(PATH_CONFIG_FILE);
    print('Finished updating macos bundle identifier');
  }

  Future<void> _replace(String path) async {
    await replaceInFile(path, oldPackageName, newPackageName);
  }
}

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  Storage._();

  static final i = Storage._();

  late final SharedPreferences sp;

  late final String docDirPath;

  late final String docStartPath = '$docDirPath${Platform.pathSeparator}';

  late final String draftPath = '$docStartPath草稿.json';

  static const String recentDocPathsKey = 'recentDocPaths';

  Future<void> init() async {
    docDirPath = (await getApplicationDocumentsDirectory()).path;
    sp = await SharedPreferences.getInstance();
  }
}

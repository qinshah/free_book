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

  Future<String?> checkDocNameError(String value) async {
    if (value.isEmpty) {
      return '';
    } else if (value.startsWith(' ')) {
      return '不能以空格开头';
    }
    final file = File('${Storage.i.docStartPath}$value.json');
    try {
      if (await file.exists()) {
        return '已存在同名文件';
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

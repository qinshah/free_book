import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  Storage._();

  static final i = Storage._();

  late final SharedPreferences sp;

  late final String docDirPath;

  late final String docStartPath =
      '${Storage.i.docDirPath}${Platform.pathSeparator}';

  static const String recentDocPathsKey = 'recentDocPaths';

  Future<void> init() async {
    try {
      docDirPath = (await getApplicationDocumentsDirectory()).path;
      sp = await SharedPreferences.getInstance();
    } catch (e) {
      // TODO 应用存储功能加载失败UI
      debugPrint('应用存储功能加载失败: $e');
    }
  }
}

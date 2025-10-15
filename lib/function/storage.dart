import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Storage {
  Storage._();

  static final i = Storage._();

  late final String docDirPath;

  Future<void> init() async {
    try {
      docDirPath = (await getApplicationDocumentsDirectory()).path;
    } catch (e) {
      // TODO 应用存储功能加载失败UI
      debugPrint('应用存储功能加载失败: $e');
    }
  }
}

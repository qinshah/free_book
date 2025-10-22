import 'package:flutter/material.dart';
import 'package:free_book/app.dart';
import 'package:free_book/function/storage.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化存储功能
  await Storage.i.init();
  // 获取持久化主题设置
  late final AdaptiveThemeMode? savedThemeMode;
  try {
    // TODO 鸿蒙不支持持久化此主题设置
    savedThemeMode = await AdaptiveTheme.getThemeMode();
  } catch (e) {
    debugPrint('保存的app主题获取失败: $e');
    savedThemeMode = AdaptiveThemeMode.system;
  }
  // 运行
  runApp(App(savedThemeMode: savedThemeMode));
}

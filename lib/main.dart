import 'package:flutter/material.dart';
import 'package:free_book/app.dart';
import 'package:free_book/function/storage.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Storage.i.init();
  } catch (e) {
    // context.showToast('应用存储功能加载失败: $e', ToastType.error);
    // TODO: 想办法在UI上提示
    debugPrint('应用存储功能加载失败: $e');
  }
  // 初始化存储功能

  late final AdaptiveThemeMode? savedThemeMode;
  try {
    // TODO 鸿蒙不支持持久化此主题设置
    savedThemeMode = await AdaptiveTheme.getThemeMode();
  } catch (e) {
    debugPrint('保存的app主题获取失败: $e');
    savedThemeMode = AdaptiveThemeMode.system;
  }

  runApp(App(savedThemeMode: savedThemeMode));
}

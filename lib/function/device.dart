import 'package:flutter/foundation.dart';

abstract class Device {
  static final _os = defaultTargetPlatform;

  /// TODO 还需要判断鸿蒙手机
  ///
  /// 是否为安卓或ios移动操作系统
  static final isMobile =
      _os == TargetPlatform.android || _os == TargetPlatform.iOS;

  /// 是否为鸿蒙系统，此代码兼容非鸿蒙flutter运行
  static final isOhos = _os.toString() == 'TargetPlatform.ohos';
}

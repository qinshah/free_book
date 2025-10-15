import 'package:flutter/services.dart';

abstract class Screen {
  static void setFullUiMode() =>
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  static void setNormalUiMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }
}

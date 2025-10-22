import 'package:flutter/services.dart';

abstract class Screen {
  static void setFullUIMode() =>
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  static void setNormalUIMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }
}

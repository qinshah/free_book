import 'package:flutter/widgets.dart';

import '../../function/state_management.dart';

class RootState extends ViewState {
  final pageViewCntlr = PageController();
  GlobalKey? pageViewKey = GlobalKey();

  int pageIndex = 0;
}

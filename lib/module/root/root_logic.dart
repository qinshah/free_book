import 'package:flutter/material.dart';

import '../../function/state_management.dart';
import 'root_state.dart';

class RootLogic extends ViewLogic<RootState> {
  RootLogic(super.curState);

  Future<void> changePage(int value, PageController pageCntlr) async {
    pageCntlr.animateToPage(
      value,
      duration: Durations.medium1,
      curve: Curves.ease,
    );
    rebuildState(curState..pageIndex = value);
  }

  @override
  void rememberDispose() {}
}

import 'package:flutter/material.dart';

import '../../function/state_management.dart';
import 'root_state.dart';

class RootLogic extends ViewLogic<RootState> {
  RootLogic(super.curState);

  Future<void> changePage(int value) async {
    curState.pageViewCntlr.animateToPage(
      value,
      duration: Durations.medium1,
      curve: Curves.ease,
    );
    rebuild(curState..pageIndex = value);
  }
  
  
  @override
  void rememberDispose() {
    curState.pageViewKey = null;
  }
}

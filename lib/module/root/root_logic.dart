import 'package:flutter/material.dart';

import '../../function/state_management.dart';
import 'root_state.dart';

class RootLogic extends Logic1<RootState> {
  RootLogic(super.state);

  Future<void> changePage(int value) async {
    state.pageViewCntlr.animateToPage(
      value,
      duration: Durations.medium1,
      curve: Curves.ease,
    );
    rebuild(state..pageIndex = value);
  }

  @override
  void dispose() {
    state.pageKey = null;
  }
}

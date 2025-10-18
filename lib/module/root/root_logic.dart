import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

import '../../function/state_management.dart';
import 'root_state.dart';

class RootLogic extends ViewLogic<RootState> {
  RootLogic(super.curState);

  void changePage(int index, PageController pageCntlr) {
    final curIndex = curState.pageIndex;
    if (curIndex != 1 && index == 1) {
      _focusDraftEditor(); // 切到草稿页，聚焦
    } else if (curIndex == 1 && index != 1) {
      _unFocusDraftEditor(); // 切出草稿页，取消聚焦
    }
    pageCntlr.animateToPage(
      index,
      duration: Durations.medium1,
      curve: Curves.ease,
    );
    rebuildState(curState..pageIndex = index);
  }

  void _focusDraftEditor() {
    final editorState = curState.draftEditorState;
    if (editorState == null) return;
    editorState.updateSelectionWithReason(
      curState.draftSelection,
      reason: SelectionUpdateReason.uiEvent, // 切换页面UI改变
    );
  }

  void _unFocusDraftEditor() {
    final editorState = curState.draftEditorState;
    if (editorState == null) return;
    curState.draftSelection = editorState.selection;
    editorState.updateSelectionWithReason(
      null, // 直接设为空防止键盘弹起
      reason: SelectionUpdateReason.uiEvent, // 切换页面UI改变
    );
  }

  @override
  void rememberDispose() {}
}

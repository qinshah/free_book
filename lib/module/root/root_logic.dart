import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

import '../../function/state_management.dart';
import 'root_state.dart';

class RootLogic extends ViewLogic<RootState> {
  RootLogic(super.curState);

  void changePage(int value, PageController pageCntlr) {
    // 如果切换到非草稿页，则取消草稿编辑器的焦点
    if (value != 1) _unFocusDraftEditor();
    pageCntlr.animateToPage(
      value,
      duration: Durations.medium1,
      curve: Curves.ease,
    );
    rebuildState(curState..pageIndex = value);
  }

  void _unFocusDraftEditor() {
    final editorState = curState.draftEditorState;
    if (editorState == null) return;
    final selection = editorState.selection;
    final newSelection = selection?.copyWith(
      start: selection.start,
      end: selection.start, // 将选中片段设为0
    );
    editorState.updateSelectionWithReason(
      newSelection,
      reason: SelectionUpdateReason.uiEvent, // 切换页面UI改变
    );
  }

  @override
  void rememberDispose() {}
}

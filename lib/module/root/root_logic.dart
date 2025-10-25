import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:free_book/function/context_extension.dart';
import 'package:free_book/function/storage.dart';

import '../../function/state_management.dart';
import 'root_state.dart';

class RootLogic extends ViewLogic<RootState> {
  RootLogic(super.curState);

  Future<void> changePage(
    int index,
    PageController pageCntlr,
    BuildContext context,
  ) async {
    final curIndex = curState.pageIndex;
    final leaveDraft = curIndex == 1 && index != 1;
    if (leaveDraft && !curState.draftLogic!.curState.saved) {
      final draftPath = Storage.i.draftPath;
      await curState.draftLogic!.saveToFile(
        draftPath,
        curState.draftState!.document,
      );
      // ignore: use_build_context_synchronously
      context.showToast('草稿更改已自动保存');
    }
    await pageCntlr.animateToPage(
      index,
      duration: Durations.medium1,
      curve: Curves.ease,
    );
    if (leaveDraft) {
      _focusDraftEditor(); // 切到草稿页，聚焦
    } else if (curIndex == 1 && index != 1) {
      _unFocusDraftEditor(); // 切出草稿页，取消聚焦
    }
    rebuildState(curState..pageIndex = index);
  }

  void _focusDraftEditor() {
    final draftState = curState.draftState;
    if (draftState == null) return;
    draftState.updateSelectionWithReason(
      curState.draftSelection,
      reason: SelectionUpdateReason.uiEvent, // 切换页面UI改变
    );
  }

  void _unFocusDraftEditor() {
    final editorState = curState.draftState;
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

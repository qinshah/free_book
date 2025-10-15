import 'dart:convert';
import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:free_book/function/state_management.dart';

import 'editor_state.dart';

class EditorLogic extends ViewLogic<MyEditorState> {
  EditorLogic(super.curState);

  Future<void> initEditor(String? docPath) async {
    final EditorState editorState;
    if (docPath == null) {
      editorState = EditorState(document: Document.blank());
    } else if (docPath.startsWith('assets')) {
      final json = jsonDecode(await rootBundle.loadString(docPath));
      editorState = EditorState(document: Document.fromJson(json));
    } else {
      final json = jsonDecode(await File(docPath).readAsString());
      editorState = EditorState(document: Document.fromJson(json));
    }
    // 日志
    editorState.logConfiguration.level = AppFlowyEditorLogLevel.off;
    curState.editorScrollController = EditorScrollController(
      editorState: editorState,
      shrinkWrap: false,
    );
    rebuild(curState..editorState = editorState);
  }

  // 获取快捷键功能，上下文用于查找本地翻译
  List<CommandShortcutEvent> getCommandShortcuts(BuildContext context) {
    return [
      // 什么的高亮色
      customToggleHighlightCommand(style: ToggleColorsStyle()),
      ...[
        ...standardCommandShortcutEvents
          ..removeWhere((el) => el == toggleHighlightCommand),
      ],
      // 查找和替换,可以配置localizations指定翻译
      ...findAndReplaceCommands(context: context),
    ];
  }

  @override
  void rememberDispose() {
    curState.editorScrollController.dispose();
    curState.editorState?.dispose();
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:free_book/function/context_extension.dart';
import 'package:free_book/function/state_management.dart';
import 'package:free_book/module/root/root_logic.dart';
import 'package:provider/provider.dart';

import 'editor_state.dart';

class EditorLogic extends ViewLogic<MyEditorState> {
  EditorLogic(super.curState);

  Future<void> loadDoc(
    String? docPath,
    BuildContext context,
    bool isDraft,
  ) async {
    EditorState editorState = await _loadEditor(docPath, context);
    // editorState.ad
    // 日志
    editorState.logConfiguration
      ..handler = debugPrint
      ..level = AppFlowyEditorLogLevel.off;
    curState.editorScrollController = EditorScrollController(
      editorState: editorState,
    );
    if (isDraft) {
      // 更新草稿编辑器对象
      // ignore: use_build_context_synchronously
      final rootLogic = context.read<RootLogic>();
      rootLogic.curState.draftEditorState = editorState;
    }
    rebuildState(curState..editorState = editorState);
  }

  Future<EditorState> _loadEditor(String? docPath, BuildContext context) async {
    if (docPath == null) return EditorState(document: Document.blank());
    try {
      if (docPath.startsWith('assets')) {
        final json = jsonDecode(await rootBundle.loadString(docPath));
        return EditorState(document: Document.fromJson(json));
      } else {
        final json = jsonDecode(await File(docPath).readAsString());
        return EditorState(document: Document.fromJson(json));
      }
    } catch (e) {
      context.showToast('文档打开失败，路径\n：$docPath:\n$e', ToastType.warn);
      return EditorState(document: Document.blank());
    }
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
    // curState.editorScrollController.dispose();
    // curState.editorState?.dispose();
  }
}

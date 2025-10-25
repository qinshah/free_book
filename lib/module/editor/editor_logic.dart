import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:free_book/function/context_extension.dart';
import 'package:free_book/function/state_management.dart';
import 'package:free_book/module/book/book_logic.dart';
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
    final editPageLogic = context.read<BookLogic>();
    final editorState = await _loadEditorState(docPath, context);
    // 日志
    editorState.logConfiguration
      ..handler = debugPrint
      ..level = AppFlowyEditorLogLevel.off;
    Future.delayed(Duration(seconds: 1), () {
      // 延迟1秒监听文档改变，解决误监听到一开始加载时的更改
      curState.transactionSubscription?.cancel();
      curState.transactionSubscription = editorState.transactionStream.listen(
        editPageLogic.onDocChange,
      );
    });
    curState.editorScrollController = EditorScrollController(
      editorState: editorState,
    );
    if (isDraft) {
      // 更新草稿编辑器对象
      // ignore: use_build_context_synchronously
      final rootLogic = context.read<RootLogic>();
      rootLogic.curState.draftState = editorState;
    }
    rebuildState(curState..editorState = editorState);
  }

  Future<EditorState> _loadEditorState(
    String? docPath,
    BuildContext context,
  ) async {
    if (docPath == null) return await _loadEmptyEditorState();
    try {
      if (docPath.startsWith('assets')) {
        final json = jsonDecode(await rootBundle.loadString(docPath));
        return EditorState(document: Document.fromJson(json));
      } else {
        final json = jsonDecode(await File(docPath).readAsString());
        return EditorState(document: Document.fromJson(json));
      }
    } catch (e) {
      context.showWarningToast('文档打开失败，自动创建空文档\n$e');
      return await _loadEmptyEditorState();
    }
  }

  Future<EditorState> _loadEmptyEditorState() async {
    final editorState = EditorState(document: Document.blank());
    final transaction = editorState.transaction;
    transaction.insertNode([0], paragraphNode(text: '这是新建的空白文档'));
    await editorState.apply(transaction);
    return editorState;
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
    curState.transactionSubscription?.cancel();
  }
}

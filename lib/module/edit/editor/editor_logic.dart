import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:free_book/function/state_management.dart';

import 'editor_state.dart';

class EditorLogic extends ViewLogic<MyEditorState> {
  EditorLogic(super.state);

  void setCentent(String? jsonString) {
    final EditorState editorState;
    if (jsonString == null) {
      editorState = EditorState(document: Document.blank());
    } else {
      final json = jsonDecode(jsonString);
      editorState = EditorState(document: Document.fromJson(json));
    }
    editorState.logConfiguration
      ..handler = debugPrint
      ..level = AppFlowyEditorLogLevel.all;

    rebuild(state..editorState = editorState);
  }

  @override
  void rememberDispose() {
    // TODO: implement rememberDispose
  }
}

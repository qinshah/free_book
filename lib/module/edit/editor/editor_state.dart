import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:free_book/function/state_management.dart';

class MyEditorState extends ViewState {
  EditorState? editorState;
  late final EditorScrollController editorScrollController;

  static bool showFloatingToolbar = false;

  static Timer? floatingToolbarTimer;

  static double toolBarHeight = 100;
}

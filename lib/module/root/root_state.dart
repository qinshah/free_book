import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/widgets.dart';

import '../../function/state_management.dart';

class RootState extends ViewState {
  EditorState? draftEditorState;
  Selection? draftSelection;

  int pageIndex = 0;
  ScrollController scrollCntlr = ScrollController();
}

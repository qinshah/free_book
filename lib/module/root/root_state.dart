import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/widgets.dart';
import 'package:free_book/module/edit/edit_page_logic.dart';

import '../../function/state_management.dart';

class RootState extends ViewState {
  EditPageLogic? draftLogic;
  EditorState? draftState;
  Selection? draftSelection;

  int pageIndex = 0;
  ScrollController scrollCntlr = ScrollController();
}

import 'package:free_book/function/state_management.dart';
import 'package:free_book/module/edit/editor/editor_logic.dart';
import 'package:free_book/module/edit/editor/editor_state.dart';

class EditPageState extends ViewState {
  final editorLogic = EditorLogic(MyEditorState());
  String? docPath;
  EditPageState();
}

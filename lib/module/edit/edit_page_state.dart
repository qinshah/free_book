import 'package:free_book/function/state_management.dart';
import 'package:free_book/module/edit/editor/editor_logic.dart';

class EditPageState extends ViewState {
  String? docPath;
  String docName = '新建';
  late EditorLogic editorLogic;
  EditPageState();
}

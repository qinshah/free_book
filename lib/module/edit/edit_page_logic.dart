import 'package:free_book/function/state_management.dart';

import 'edit_page_state.dart';

class EditPageLogic extends ViewLogic<EditPageState> {
  EditPageLogic(super.curState);

  @override
  void rememberDispose() {
    // TODO: implement rememberDispose
  }

  void setDoc(String? docPath) {
    final name = docPath?.split('/').last.split('.').first;
    if (name == null || name.isEmpty) {
      rebuild(curState..docPath = docPath);
    } else {
      rebuild(
        curState
          ..docPath = docPath
          ..docName = name,
      );
    }
  }
}

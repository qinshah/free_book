import 'dart:io';

import 'package:flutter/services.dart';
import 'package:free_book/function/state_management.dart';

import 'edit_page_state.dart';

class EditPageLogic extends ViewLogic<EditPageState> {
  EditPageLogic(super.state);

  Future<void> loadDoc(String? docPath) async {
    final editorLogic = state.editorLogic;
    if (docPath == null) {
      editorLogic.setCentent(null);
    } else if (docPath.startsWith('assets')) {
      final content = await rootBundle.loadString(docPath);
      editorLogic.setCentent(content);
    } else {
      final content = await File(docPath).readAsString();
      editorLogic.setCentent(content);
    }
    rebuild(state..docPath = docPath);
  }

  @override
  void rememberDispose() {
    // TODO: implement rememberDispose
  }
}

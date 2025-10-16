import 'dart:convert';
import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:free_book/function/state_management.dart';
import 'package:free_book/function/storage.dart';

import 'edit_page_state.dart';

class EditPageLogic extends ViewLogic<EditPageState> {
  EditPageLogic(super.curState);

  @override
  void rememberDispose() {
    curState.saveAsNameCntlr.dispose();
  }

  void setDoc(String? docPath, [bool isDraft = false]) {
    if (isDraft) {
      _setDraftDoc();
      return;
    }
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

  void _setDraftDoc() {
    // TODO 配置草稿路径
    final draftPath = '${Storage.i.docDirPath}${Platform.pathSeparator}草稿.json';
    if (!File(draftPath).existsSync()) {
      final emptyDocString = jsonEncode(Document.blank().toJson());
      File(draftPath).writeAsStringSync(emptyDocString);
    }
    rebuild(
      curState
        ..docPath = draftPath
        ..docName = '草稿',
    );
  }

  Future<void> saveDoc(String path, Document doc) async {
    await File(path).writeAsString(jsonEncode(doc.toJson()));
  }

  void _reSetDoc(String path) {
    rebuild(
      curState
        ..docPath = path
        ..docName = path.split('/').last.split('.').first,
    );
  }
}

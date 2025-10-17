import 'dart:convert';
import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:free_book/function/state_management.dart';
import 'package:free_book/function/storage.dart';
import 'package:free_book/module/home/home_page_logic.dart';
import 'package:provider/provider.dart';

import 'edit_page_state.dart';

class EditPageLogic extends ViewLogic<EditPageState> {
  EditPageLogic(super.curState);

  @override
  void rememberDispose() {
    curState.saveAsNameCntlr.dispose();
  }

  void loadDocInfo(String? docPath, bool isDraft) {
    if (isDraft) {
      _setDraftDoc();
      return;
    }
    final name = docPath?.split('/').last.split('.').first;
    if (name == null || name.isEmpty) {
      rebuildState(curState..docPath = docPath);
    } else {
      rebuildState(
        curState
          ..docPath = docPath
          ..docName = name,
      );
    }
  }

  void _setDraftDoc() {
    final draftPath = Storage.i.draftPath;
    if (!File(draftPath).existsSync()) {
      final emptyDocString = jsonEncode(Document.blank().toJson());
      File(draftPath).writeAsStringSync(emptyDocString);
    }
    rebuildState(
      curState
        ..docPath = draftPath
        ..docName = '草稿',
    );
  }

  Future<void> saveDoc(String path, Document doc) async {
    await File(path).writeAsString(jsonEncode(doc.toJson()));
  }

  void addToRecDoc(String? path, bool isDraft, BuildContext context) {
    // 草稿、示例和新建都不添加
    if (isDraft || path == null || path.startsWith('assets')) return;
    final homePageLogic = context.read<HomePageLogic>();
    homePageLogic.addDocToRecent(path);
  }
}

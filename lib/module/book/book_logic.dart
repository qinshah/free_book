import 'dart:convert';
import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:free_book/function/state_management.dart';
import 'package:free_book/function/storage.dart';
import 'package:free_book/module/home/home_page_logic.dart';
import 'package:provider/provider.dart';

import 'book_state.dart';

class BookLogic extends ViewLogic<BookState> {
  BookLogic(super.curState);

  @override
  void rememberDispose() {
    curState.saveAsNameCntlr.dispose();
  }

  void loadDocInfo(String? docPath, bool isDraft) {
    if (isDraft) {
      final draftPath = Storage.i.draftPath;
      if (!File(draftPath).existsSync()) {
        final emptyDocString = '''
{"document":{"type":"page","children":[{"type":"paragraph","data":{"delta":[{"insert":"这是草稿，离开此页面自动保存"}]}}]}}
''';
        File(draftPath).writeAsStringSync(emptyDocString);
      }
      rebuildState(
        curState
          ..filePath = draftPath
          ..name = '草稿',
      );
      return;
    }
    final name = docPath?.split('/').last.split('.').first;
    if (name == null || name.isEmpty) {
      rebuildState(curState..filePath = docPath);
    } else {
      rebuildState(
        curState
          ..filePath = docPath
          ..name = name,
      );
    }
  }

  Future<void> saveToFile(String path, Document doc) async {
    await File(path).writeAsString(jsonEncode(doc.toJson()));
    rebuildState(curState..saved = true);
  }

  void addToRecDoc(String? path, bool isDraft, BuildContext context) {
    // 草稿、示例和新建都不添加
    if (isDraft || path == null || path.startsWith('assets')) return;
    final homePageLogic = context.read<HomePageLogic>();
    homePageLogic.addDocToRecent(path);
  }

  void onDocChange(_) {
    if (curState.saved) rebuildState(curState..saved = false);
  }
}

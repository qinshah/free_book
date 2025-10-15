import 'dart:convert';
import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:free_book/function/state_management.dart';
import 'package:free_book/function/storage.dart';

import 'edit_page_state.dart';

class EditPageLogic extends ViewLogic<EditPageState> {
  EditPageLogic(super.curState);

  @override
  void rememberDispose() {
    // TODO: implement rememberDispose
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

  Future<void> saveDoc(String path) async {
    final doc = curState.editorLogic.curState.editorState?.document;
    if (doc == null) {
      // TODO 提示这种情况
      return;
    }
    try {
      await File(path).writeAsString(jsonEncode(doc.toJson()));
      rebuild(
        curState
          ..docPath = path
          ..docName = path.split('/').last.split('.').first,
      );
      debugPrint('内容已保存到$path'); // TODO 提示保存成功
    } catch (e) {
      debugPrint('保存文件失败: $e'); // TODO 提示保存失败
    }
  }
}

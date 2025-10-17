import 'dart:io';

import 'package:free_book/function/state_management.dart';
import 'package:free_book/function/storage.dart';

import 'home_page_state.dart';

class HomePageLogic extends ViewLogic<HomePageState> {
  HomePageLogic(super.curState);

  @override
  void rememberDispose() {}

  Future<void> loadDocList() async {
    final docDir = Directory(Storage.i.docDirPath);
    List<String> docPaths = [];
    await for (final entity in docDir.list()) {
      if (entity is File &&
          entity.path.endsWith('.json') &&
          entity.path != Storage.i.draftPath) {
        docPaths.add(entity.path);
      }
    }
    final recentDocPaths =
        Storage.i.sp.getStringList(Storage.recentDocPathsKey) ?? [];
    rebuildState(
      curState
        ..docPaths = docPaths
        ..recentDocPaths = recentDocPaths,
    );
  }

  void addDocToRecent(String docPath) {
    final curRecentDocPaths = curState.recentDocPaths;
    if (docPath == curRecentDocPaths.firstOrNull) return; // 已经是第一个
    final recentPaths = [...curRecentDocPaths];
    recentPaths.remove(docPath);
    recentPaths.insert(0, docPath);
    Storage.i.sp.setStringList(Storage.recentDocPathsKey, recentPaths);
    // 这里不能调用rebuild刷新，因为可能在其它页面
  }

  Future<void> clearRec() async {
    await Storage.i.sp.remove(Storage.recentDocPathsKey);
    rebuildState(curState..recentDocPaths = []);
  }
}

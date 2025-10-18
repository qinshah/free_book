import 'dart:io';

import 'package:flutter/material.dart';
import 'package:free_book/function/context_extension.dart';
import 'package:free_book/function/storage.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({super.key});

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('回收站')),
      body: FutureBuilder(
        future: _getTrashFiles(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return Center(child: Text('加载失败: ${asyncSnapshot.error}'));
          }
          if (asyncSnapshot.hasData) {
            final files = asyncSnapshot.data!;
            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      title: Text(
                        file.path
                            .split(Platform.pathSeparator)
                            .last
                            .split('.')
                            .first,
                      ),
                      trailing: TextButton(
                        onPressed: () => _restoreFile(file, context),
                        child: Text('还原'),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<List<File>> _getTrashFiles() async {
    List<File> files = [];
    await for (var e in Directory(Storage.i.docDirPath).list()) {
      if (e is File && e.path.endsWith('.trash')) files.add(e);
    }
    return files;
  }

  Future<void> _restoreFile(File file, BuildContext context) async {
    final newPath = file.path.substring(0, file.path.length - '.trash'.length);
    if (File(newPath).existsSync()) {
      context.showToast('原位置已存在改文件', ToastType.warn);
    } else {
      try {
        setState(() {
          file.renameSync(newPath);
        });
        context.showToast('还原成功');
      } catch (e) {
        context.showToast('还原失败: $e', ToastType.error);
      }
    }
  }
}

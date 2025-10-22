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
                    onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return _buildRestoreDialog(context, file);
                      },
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      title: Text(
                        file.path
                            .split(Platform.pathSeparator)
                            .last
                            .split('.')
                            .first,
                      ),
                      trailing: IconButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) {
                            return _buildDeleteDialog(context, file);
                          },
                        ),
                        icon: Icon(Icons.delete, color: Colors.red),
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
      context.showWarningToast('原位置已存在该文件');
    } else {
      try {
        setState(() {
          file.renameSync(newPath);
        });
        context.showSuccessToast('还原成功');
      } catch (e) {
        context.showErrorToast('还原失败: $e');
      }
    }
  }

  Widget _buildRestoreDialog(BuildContext context, File file) => AlertDialog(
    title: Text('还原'),
    content: Text('确定要还原该文件吗？'),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('取消'),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          _restoreFile(file, context);
        },
        child: Text('确定'),
      ),
    ],
  );

  Widget _buildDeleteDialog(BuildContext context, File file) => AlertDialog(
    title: Text('永久删除'),
    content: Text('确定要永久删除该文件吗？'),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text('取消'),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          _deleteFile(file);
        },
        child: Text('确定', style: TextStyle(color: Colors.red)),
      ),
    ],
  );

  Future<void> _deleteFile(File file) async {
    try {
      await file.delete();
      // ignore: use_build_context_synchronously
      context.showSuccessToast('删除成功');
      setState(() {
        // 刷新列表
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      context.showErrorToast('删除失败: $e');
    }
  }
}

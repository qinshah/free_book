import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:free_book/function/context_extension.dart';
import 'package:free_book/function/storage.dart';
import 'package:free_book/module/root/root_logic.dart';
import 'package:free_book/module/trash/trash_page.dart';
import 'package:free_book/widget/ink_button.dart';
import 'package:provider/provider.dart';

import '../edit/edit_page_view.dart';
import 'home_page_logic.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  late final _logic = context.read<HomePageLogic>();

  @override
  void initState() {
    super.initState();
    _logic.loadDocList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('自由记')),
      // 悬浮按钮会在鸿蒙上导致崩溃，搞不懂，先去掉
      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     FloatingActionButton(
      //       onPressed: () async {
      //         await Navigator.of(context).push(
      //           MaterialPageRoute(
      //             builder: (BuildContext context) => EditPageView.newDoc(),
      //           ),
      //         );
      //         _logic.loadDocList();
      //       },
      //       child: Icon(Icons.add),
      //     ),
      //     SizedBox(height: 56),
      //   ],
      // ),
      body: Builder(
        builder: (context) {
          final curState = context.watch<HomePageLogic>().curState;
          return ListView(
            key: PageStorageKey('HomePageStorageKey'),
            controller: context.read<RootLogic>().curState.scrollCntlr,
            padding: const EdgeInsets.all(16),
            children: [
              Text('示例', style: TextStyle(fontSize: 20)),
              SizedBox(height: 6),
              _ExampleDocItem('assets/示例文档.json'),
              // ————————————
              SizedBox(height: 22),
              Row(
                children: [
                  Text('最近', style: TextStyle(fontSize: 20)),
                  Spacer(),
                  if (curState.recentDocPaths.isNotEmpty)
                    TextButton(onPressed: _logic.clearRec, child: Text('清空记录')),
                ],
              ),
              SizedBox(height: 6),
              _buildDocList(curState.recentDocPaths),
              // ————————————
              SizedBox(height: 22),
              Row(
                children: [
                  Text('全部', style: TextStyle(fontSize: 20)),
                  Spacer(),
                  TextButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              EditPageView.newDoc(),
                        ),
                      );
                      _logic.loadDocList();
                    },
                    child: Text('新建空白'),
                  ),
                ],
              ),
              SizedBox(height: 6),
              _buildDocList(curState.docPaths),
              SizedBox(height: 22),
              Text('回收站', style: TextStyle(fontSize: 20)),
              SizedBox(height: 6),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    leading: Icon(Icons.delete_outlined, color: Colors.brown),
                    title: Text('${_logic.getTrashDocCount()}'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => const TrashPage(),
                      ),
                    );
                    _logic.loadDocList();
                  },
                ),
              ),
              SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDocList(List<String> filePaths) {
    if (filePaths.isEmpty) {
      return Card(
        child: SizedBox(
          height: 100,
          child: Center(child: Text('什么也没有', style: TextStyle(fontSize: 20))),
        ),
      );
    }
    return _buldItems(filePaths);
  }

  Column _buldItems(List<String> filePaths) {
    return Column(
      children: List.generate(filePaths.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: _DocItem(filePaths[index], key: Key(filePaths[index])),
        );
      }),
    );
  }
}

class _ExampleDocItem extends StatelessWidget {
  const _ExampleDocItem(this.assetPath);

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _openDoc(context),
        child: ListTile(
          title: Text(
            assetPath.split('/').last.split('.').first,
            style: TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(Icons.file_open_outlined),
        ),
      ),
    );
  }

  Future<void> _openDoc(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => EditPageView(assetPath)));
    if (context.mounted) {
      // 刷新列表
      context.read<HomePageLogic>().loadDocList();
    }
  }
}

class _DocItem extends StatefulWidget {
  const _DocItem(this.docPath, {required super.key});

  final String docPath;

  @override
  State<_DocItem> createState() => _DocItemState();
}

class _DocItemState extends State<_DocItem> {
  late final _logic = context.read<HomePageLogic>();
  late final _menuEntries = <ContextMenuEntry>[
    MenuItem(
      label: '重命名',
      icon: Icons.edit_outlined,
      onSelected: () => showDialog(
        context: context,
        builder: (BuildContext context) => _RenameDialog(widget.docPath),
      ),
    ),
    MenuItem(
      label: '移到回收站',
      icon: Icons.delete_outlined,
      onSelected: () async {
        try {
          await _logic.moveDocToTrash(widget.docPath);
          // ignore: use_build_context_synchronously
          context.showSuccessToast('已移到回收站');
        } catch (e) {
          // ignore: use_build_context_synchronously
          context.showErrorToast('移动失败：$e');
        }
      },
    ),
    MenuItem(
      label: '永久删除',
      icon: Icons.delete_outlined,
      color: Colors.red,
      onSelected: () => showDialog(
        context: context,
        builder: (_) => _DeleteDialog(widget.docPath),
      ),
    ),
  ];

  Offset _tapPosition = Offset.zero;
  late final _file = File(widget.docPath);
  late final _name = widget.docPath
      .split(Platform.pathSeparator)
      .last
      .split('.')
      .first;

  @override
  Widget build(BuildContext context) {
    final exists = _file.existsSync();
    return Card(
      child: !exists
          ? InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                context.showWarningToast('文档不存在，已自动移除');
                await _logic.removeRecentDoc(widget.docPath);
                _logic.loadDocList();
              },
              child: ListTile(
                title: Text(_name),
                subtitle: Text('文档源文件已丢失'),
                textColor: Colors.grey,
              ),
            )
          : InkWell(
              borderRadius: BorderRadius.circular(12),
              onTapDown: (details) => _tapPosition = details.globalPosition,
              onSecondaryTapDown: (details) =>
                  _tapPosition = details.globalPosition,
              onLongPress: () => _showMenu(context),
              onSecondaryTap: () => _showMenu(context),
              onTap: () => _openDoc(context),
              child: ListTile(
                title: Text(
                  widget.docPath.split('/').last.split('.').first,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(_file.lastModifiedSync().toString()),
                trailing: InkWell(
                  borderRadius: BorderRadius.circular(9999),
                  onTapDown: (details) => _tapPosition = details.globalPosition,
                  onTap: () => _showMenu(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.more_vert),
                  ),
                ),
              ),
            ),
    );
  }

  void _showMenu(BuildContext context) {
    final menu = ContextMenu(position: _tapPosition, entries: _menuEntries);
    menu.show(context);
  }

  Future<void> _openDoc(BuildContext context) async {
    // 还是再确认一下是否在打开前文件被删除了
    if (!_file.existsSync()) {
      context.showErrorToast('文档源文件已丢失，打开失败');
      _logic.loadDocList(); // 只需要重新加载列表，不存在的自动变灰
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditPageView(widget.docPath)),
    );
    if (context.mounted) {
      // 刷新列表
      context.read<HomePageLogic>().loadDocList();
    }
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog(this.path);

  final String path;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  String? _error = '';
  late final _logic = context.read<HomePageLogic>();
  String _name = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('重命名'),
      content: TextField(
        autofocus: true,
        onChanged: (value) async {
          _name = value;
          final error = await Storage.i.checkDocNameError(value);
          setState(() => _error = error);
        },
        onSubmitted: _error == null ? (_) => _rename() : null,
        decoration: InputDecoration(
          hintText: '输入新名称',
          errorText: _error == null || _error!.isEmpty ? null : _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消'),
        ),
        TextButton(
          onPressed: _error == null ? _rename : null,
          child: Text('确定'),
        ),
      ],
    );
  }

  void _rename() async {
    try {
      final error = await Storage.i.checkDocNameError(_name);
      if (error != null) throw Exception(error);
      if (mounted) Navigator.of(context).pop();
      await _logic.renameDoc(widget.path, _name);
      _logic.loadDocList();
      // ignore: use_build_context_synchronously
      context.showSuccessToast('重命名成功');
    } catch (e) {
      // ignore: use_build_context_synchronously
      context.showErrorToast('重命名失败$e');
    }
  }
}

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog(this.docPath);

  final String docPath;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('删除文档'),
      content: Text('确定要永久删除此文档吗？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            try {
              final logic = context.read<HomePageLogic>();
              await logic.deleteDoc(docPath);
              // ignore: use_build_context_synchronously
              context.showSuccessToast('删除成功');
            } catch (e) {
              // ignore: use_build_context_synchronously
              context.showErrorToast('删除失败：$e');
            }
          },
          child: Text('删除', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

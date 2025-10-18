import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:free_book/function/context_extension.dart';
import 'package:free_book/function/storage.dart';
import 'package:free_book/module/root/root_logic.dart';
import 'package:free_book/module/trash/trash_page.dart';
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
      body: Builder(
        builder: (context) {
          final curState = context.watch<HomePageLogic>().curState;
          return ListView(
            key: PageStorageKey('HomePageStorageKey'),
            controller: context.read<RootLogic>().curState.scrollCntlr,
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(height: 22),
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
              Text('全部', style: TextStyle(fontSize: 20)),
              SizedBox(height: 6),
              _buildDocList(curState.docPaths),
              SizedBox(height: 22),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    leading: Icon(Icons.delete_outlined),
                    title: Text('回收站'),
                    subtitle: Text('${_logic.getTrashDocCount()}个文档'),
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
      label: '移到回收站',
      icon: Icons.delete_outlined,
      onSelected: () async {
        try {
          await _logic.moveDocToTrash(widget.docPath);
          // ignore: use_build_context_synchronously
          context.showToast('已移到回收站', ToastType.success);
        } catch (e) {
          // ignore: use_build_context_synchronously
          context.showToast('移动失败：$e', ToastType.error);
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

  @override
  Widget build(BuildContext context) {
    final exists = _file.existsSync();
    final color = exists ? null : Colors.grey;
    return Ink(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTapDown: (details) => _tapPosition = details.globalPosition,
        onSecondaryTapDown: (details) => _tapPosition = details.globalPosition,
        onLongPress: () => _showMenu(context),
        onSecondaryTap: () => _showMenu(context),
        onTap: exists
            ? () => _openDoc(context)
            : () async {
                context.showToast('文档不存在', ToastType.warn);
                await _logic.removeRecentDoc(widget.docPath);
                _logic.loadDocList();
              },
        child: ListTile(
          textColor: color,
          title: Text(
            widget.docPath.split('/').last.split('.').first,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            exists ? _file.lastModifiedSync().toString() : '文档不存在',
          ),
          trailing: MouseRegion(
            onHover: (event) => _tapPosition = event.original!.position,
            child: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => _showMenu(context),
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
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditPageView(widget.docPath)),
    );
    if (context.mounted) {
      // 刷新列表
      context.read<HomePageLogic>().loadDocList();
    }
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
              context.showToast('删除成功', ToastType.success);
            } catch (e) {
              // ignore: use_build_context_synchronously
              context.showToast('删除失败：$e', ToastType.error);
            }
          },
          child: Text('删除', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

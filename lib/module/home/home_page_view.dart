import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:free_book/function/context_extension.dart';
import 'package:free_book/function/storage.dart';
import 'package:free_book/module/root/root_logic.dart';
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
              _DocItem('assets/示例文档.json', isAsset: true),
              SizedBox(height: 22),
              Row(
                children: [
                  Text('全部', style: TextStyle(fontSize: 20)),
                  Spacer(),
                  if (kDebugMode)
                    TextButton(
                      onPressed: () async {
                        await for (final entity in Directory(
                          Storage.i.docDirPath,
                        ).list()) {
                          if (entity is File &&
                              entity.path.endsWith('.json') &&
                              !entity.path.endsWith('草稿.json')) {
                            entity.delete();
                          }
                        }
                        _logic.loadDocList();
                      },
                      child: Text('全部删除'),
                    ),
                ],
              ),
              SizedBox(height: 6),
              _buildDocList(curState.docPaths),
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
          child: _DocItem(filePaths[index]),
        );
      }),
    );
  }
}

class _DocItem extends StatelessWidget {
  const _DocItem(this.docPath, {this.isAsset = false});

  final String docPath;

  final bool isAsset;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surface;
    if (isAsset) {
      return _buildTile(
        color: color,
        context: context,
        trailing: Icon(Icons.file_open_outlined),
      );
    }
    final file = File(docPath);
    final deleted = !file.existsSync();
    return _buildTile(
      color: color,
      context: context,
      deleted: deleted,
      trailing: deleted
          ? Icon(Icons.delete_forever_rounded, color: Colors.grey)
          : Text(file.lastModifiedSync().toString().substring(0, 16)),
    );
  }

  Ink _buildTile({
    required Color color,
    required BuildContext context,
    required Widget trailing,
    bool deleted = false,
  }) {
    return Ink(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: deleted
            ? () {
                context.read<HomePageLogic>().removeDoc(docPath);
                context.showToast('文档不存在', ToastType.warn);
              }
            : () => _openDoc(context),
        child: ListTile(
          title: Text(
            docPath.split('/').last.split('.').first,
            style: TextStyle(fontSize: 16, color: deleted ? Colors.grey : null),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: trailing,
        ),
      ),
    );
  }

  Future<void> _openDoc(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => EditPageView(docPath)));
    if (context.mounted) {
      // 刷新列表
      context.read<HomePageLogic>().loadDocList();
    }
  }
}

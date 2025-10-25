import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:forui/assets.dart';
import 'package:free_book/function/context_extension.dart';
import 'package:free_book/function/storage.dart';
import 'package:free_book/module/book/book_state.dart';
import 'package:free_book/module/editor/editor_logic.dart';
import 'package:free_book/module/editor/editor_state.dart';
import 'package:free_book/module/home/home_page_logic.dart';
import 'package:free_book/module/root/root_logic.dart';
import 'package:free_book/widget/ink_button.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'book_logic.dart';
import '../editor/view/editor_view.dart';

class BookView extends StatefulWidget {
  const BookView(this.initDocPath, {super.key}) : isDraft = false;

  const BookView.newDoc({super.key}) : initDocPath = null, isDraft = false;

  const BookView.draft({super.key}) : initDocPath = null, isDraft = true;

  final String? initDocPath;

  final bool isDraft;

  @override
  State<BookView> createState() => _BookViewState();
}

class _BookViewState extends State<BookView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _logic = BookLogic(BookState());

  @override
  void initState() {
    super.initState();
    // 添加到最近文档列表
    if (widget.isDraft) {
      final rootLogic = context.read<RootLogic>();
      rootLogic.curState.draftLogic = _logic;
    }
    _logic.addToRecDoc(widget.initDocPath, widget.isDraft, context);
    _logic.loadDocInfo(widget.initDocPath, widget.isDraft);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider.value(
      value: _logic,
      builder: (context, _) {
        return ChangeNotifierProvider(
          create: (_) => EditorLogic(MyEditorState()),
          child: Builder(
            builder: (context) {
              final curState = context.watch<BookLogic>().curState;
              return PopScope(
                canPop: curState.saved || widget.isDraft,
                onPopInvokedWithResult: (didPop, _) {
                  if (didPop || widget.isDraft) return;
                  _showConfirmPopDialog(context);
                },
                child: Scaffold(
                  appBar: AppBar(
                    leadingWidth: 88,
                    // 重写返回按钮
                    leading: Row(
                      children: [
                        SizedBox(width: 8),
                        if (ModalRoute.of(context)?.canPop == true)
                          InkButton(
                            onTap: () => curState.saved
                                ? Navigator.of(context).pop()
                                : _showConfirmPopDialog(context),
                            child: Icon(Icons.arrow_back),
                          ),
                      ],
                    ),
                    toolbarHeight: 36,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SelectableText(curState.name, maxLines: 1),
                        if (!curState.saved)
                          Text(
                            '-已修改',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                      ],
                    ),
                    // TODO 重构UI
                    actions: [_ToolButtons()],
                  ),
                  body: EditorView(curState.filePath, isDraft: widget.isDraft),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showConfirmPopDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确定不保存退出？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ToolButtons extends StatelessWidget {
  const _ToolButtons();
  @override
  Widget build(BuildContext context) {
    final logic = context.watch<BookLogic>();
    final path = logic.curState.filePath;
    final doc = context.watch<EditorLogic>().curState.editorState?.document;
    if (doc == null) return const SizedBox();
    return Row(
      children: [
        Tooltip(
          message: '保存',
          child: InkButton(
            onTap: path == null
                ? () => showDialog(
                    context: context,
                    builder: (_) => ChangeNotifierProvider.value(
                      value: logic,
                      child: _SaveToDialog(doc),
                    ),
                  )
                : path.startsWith('asset')
                ? null
                : () async {
                    try {
                      await logic.saveToFile(path, doc);
                      // ignore: use_build_context_synchronously
                      context.showSuccessToast('保存成功');
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      context.showErrorToast('保存失败：$e');
                    }
                  },
            child: Icon(Icons.save_rounded),
          ),
        ),
        Tooltip(
          message: '另存为',
          child: InkButton(
            onTap: () => showDialog(
              context: context,
              builder: (_) => ChangeNotifierProvider.value(
                value: logic,
                child: _SaveAsDialog(doc),
              ),
            ),
            child: Icon(Icons.save_as),
          ),
        ),
        Tooltip(
          message: '分享或导出',
          child: InkButton(
            onTap: () {
              Share.shareXFiles(
                [XFile.fromData(utf8.encode(jsonEncode(doc.toJson())))],
                fileNameOverrides: ['${logic.curState.name}.json'],
              );
            },
            child: Icon(FIcons.externalLink),
          ),
        ),
        SizedBox(width: 8),
      ],
    );
  }
}

class _SaveToDialog extends StatefulWidget {
  const _SaveToDialog(this.doc);

  final Document doc;

  @override
  State<_SaveToDialog> createState() => __SaveToDialogState();
}

class __SaveToDialogState extends State<_SaveToDialog> {
  late final _logic = context.read<BookLogic>();
  String? _error = '';
  String _name = '';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('保存到'),
      content: TextField(
        autofocus: true,
        onChanged: (value) async {
          _name = value;
          final error = await Storage.i.checkDocNameError(value);
          setState(() => _error = error);
        },
        onSubmitted: _error == null ? (_) => _saveTo() : null,
        decoration: InputDecoration(
          hintText: '输入文档名称',
          errorText: _error == null || _error!.isEmpty ? null : _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消'),
        ),
        TextButton(
          onPressed: _error == null ? _saveTo : null,
          child: Text('确定'),
        ),
      ],
    );
  }

  Future<void> _saveTo() async {
    try {
      final error = await Storage.i.checkDocNameError(_name);
      if (error != null) throw Exception(error);
      if (mounted) Navigator.of(context).pop();
      final path = '${Storage.i.docStartPath}$_name.json';
      await _logic.saveToFile(path, widget.doc);
      _logic.loadDocInfo(path, false);
      // ignore: use_build_context_synchronously
      final homeLogic = context.read<HomePageLogic>();
      homeLogic.addDocToRecent(path); // 添加到最近文档列表
      // ignore: use_build_context_synchronously
      context.showSuccessToast('保存成功');
    } catch (e) {
      // ignore: use_build_context_synchronously
      context.showErrorToast('保存失败$e');
    }
  }
}

class _SaveAsDialog extends StatefulWidget {
  final Document doc;
  const _SaveAsDialog(this.doc);

  @override
  State<_SaveAsDialog> createState() => _SaveAsDialogState();
}

class _SaveAsDialogState extends State<_SaveAsDialog> {
  late final _logic = context.read<BookLogic>();
  String? _error = '';
  @override
  void initState() {
    super.initState();
    Storage.i.checkDocNameError(_logic.curState.saveAsNameCntlr.text).then((
      error,
    ) {
      setState(() => _error = error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('另存为'),
      content: TextField(
        autofocus: true,
        controller: _logic.curState.saveAsNameCntlr,
        onChanged: (value) async {
          final error = await Storage.i.checkDocNameError(value);
          setState(() => _error = error);
        },
        onSubmitted: _error == null ? (_) => _saveAs() : null,
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
          onPressed: _error == null ? _saveAs : null,
          child: Text('确定'),
        ),
      ],
    );
  }

  void _saveAs() async {
    try {
      final error = await Storage.i.checkDocNameError(
        _logic.curState.saveAsNameCntlr.text,
      );
      if (error != null) throw Exception(error);
      final name = _logic.curState.saveAsNameCntlr.text;
      final path = '${Storage.i.docStartPath}$name.json';
      await _logic.saveToFile(path, widget.doc);
      // ignore: use_build_context_synchronously
      final homeLogic = context.read<HomePageLogic>();
      homeLogic.addDocToRecent(path); // 添加到最近文档列表
      if (!mounted) return;
      Navigator.of(context).pop();
      showDialog(context: context, builder: _buildOpenNewPageDialog);
    } catch (e) {
      setState(() => _error = '保存失败：$e');
    }
  }

  Widget _buildOpenNewPageDialog(BuildContext context) {
    final theme = Theme.of(context);
    final fileName = _logic.curState.saveAsNameCntlr.text;
    final path = '${Storage.i.docStartPath}$fileName.json';
    return AlertDialog(
      title: Text('已另存，是否打开？'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('文件已另存为"$fileName"'),
          SizedBox(height: 20),
          Text('继续编辑当前文档还是打开"$fileName"？'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text('不打开', style: theme.textTheme.bodyMedium),
        ),
        TextButton(
          child: Text('打开'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => BookView(path)));
          },
        ),
      ],
    );
  }
}

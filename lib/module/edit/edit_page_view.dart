import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:free_book/function/context_extension.dart';
import 'package:free_book/function/storage.dart';
import 'package:free_book/module/edit/edit_page_state.dart';
import 'package:free_book/module/edit/editor/editor_logic.dart';
import 'package:free_book/module/edit/editor/editor_state.dart';
import 'package:provider/provider.dart';

import 'edit_page_logic.dart';
import 'editor/editor_view.dart';

class EditPageView extends StatefulWidget {
  const EditPageView(this.initDocPath, {super.key}) : isDraft = false;

  const EditPageView.newDoc({super.key}) : initDocPath = null, isDraft = false;

  const EditPageView.draft({super.key}) : initDocPath = null, isDraft = true;

  final String? initDocPath;

  final bool isDraft;

  @override
  State<EditPageView> createState() => _EditPageViewState();
}

class _EditPageViewState extends State<EditPageView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _logic = EditPageLogic(EditPageState());

  @override
  void initState() {
    super.initState();
    // 添加到最近文档列表
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
              final curState = context.watch<EditPageLogic>().curState;
              return Scaffold(
                appBar: AppBar(
                  title: SelectableText(curState.docName),
                  // TODO 重构UI
                  actions: [_ToolBar()],
                ),
                body: EditorView(curState.docPath, isDraft: widget.isDraft),
              );
            },
          ),
        );
      },
    );
  }
}

class _ToolBar extends StatelessWidget {
  const _ToolBar();
  @override
  Widget build(BuildContext context) {
    final logic = context.watch<EditPageLogic>();
    final curState = logic.curState;
    final doc = context.watch<EditorLogic>().curState.editorState?.document;
    final path = curState.docPath;
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.save_rounded),
          onPressed: path == null || path.startsWith('assets') || doc == null
              ? null
              : () async {
                  try {
                    await logic.saveDoc(path, doc);
                    // ignore: use_build_context_synchronously
                    context.showToast('保存成功');
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    context.showToast('保存失败：$e', ToastType.error);
                  }
                },
        ),
        IconButton(
          icon: Icon(Icons.save_as),
          onPressed: doc == null
              ? null
              : () => showAdaptiveDialog(
                  context: context,
                  builder: (_) {
                    return ChangeNotifierProvider.value(
                      value: logic,
                      child: _SaveAsDialog(doc),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SaveAsDialog extends StatefulWidget {
  final Document doc;
  const _SaveAsDialog(this.doc);

  @override
  State<_SaveAsDialog> createState() => _SaveAsDialogState();
}

class _SaveAsDialogState extends State<_SaveAsDialog> {
  late final _logic = context.read<EditPageLogic>();
  String? _error = '';
  late File _targetFile;

  @override
  void initState() {
    super.initState();
    _checkNameError(_logic.curState.saveAsNameCntlr.text).then((error) {
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
          final error = await _checkNameError(value);
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
      await _logic.saveDoc((await _targetFile.create()).path, widget.doc);
      if (!mounted) return;
      Navigator.of(context).pop();
      showAdaptiveDialog(context: context, builder: _buildOpenNewPageDialog);
    } catch (e) {
      setState(() => _error = '保存失败：$e');
    }
  }

  Future<String?> _checkNameError(String value) async {
    if (value.isEmpty) {
      return '';
    } else if (value.startsWith(' ')) {
      return '不能以空格开头';
    }
    final file = File('${Storage.i.docStartPath}$value.json');
    try {
      if (await file.exists()) {
        return '已存在同名文件';
      }
      _targetFile = file;
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Widget _buildOpenNewPageDialog(BuildContext context) {
    final theme = Theme.of(context);
    final fileName = _logic.curState.saveAsNameCntlr.text;
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditPageView(_targetFile.path),
              ),
            );
          },
        ),
      ],
    );
  }
}

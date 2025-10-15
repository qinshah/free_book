import 'package:flutter/material.dart';
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
    _logic.setDoc(widget.initDocPath, widget.isDraft);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider.value(
      value: _logic,
      builder: (context, _) {
        return Builder(
          builder: (context) {
            final curState = context.watch<EditPageLogic>().curState;
            return Scaffold(
              appBar: AppBar(
                title: SelectableText(curState.docName),
                // TODO 重构UI
                actions: _buildToolBar(curState),
              ),
              body: ChangeNotifierProvider(
                create: (_) {
                  final editorLogic = EditorLogic(MyEditorState());
                  curState.editorLogic = editorLogic;
                  return editorLogic;
                },
                child: EditorView(curState.docPath),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildToolBar(EditPageState curState) {
    return [
      IconButton(
        icon: Icon(Icons.save),
        onPressed:
            curState.docPath != null && !curState.docPath!.startsWith('assets')
            ? () => _logic.saveDoc(curState.docPath!)
            : null,
      ),
    ];
  }
}

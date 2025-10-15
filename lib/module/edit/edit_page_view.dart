import 'package:flutter/material.dart';
import 'package:free_book/module/edit/edit_page_state.dart';
import 'package:provider/provider.dart';

import 'edit_page_logic.dart';
import 'editor/editor_view.dart';

class EditPageView extends StatefulWidget {
  const EditPageView(this.initDocPath, {super.key});

  const EditPageView.empty({super.key}) : initDocPath = null;

  final String? initDocPath;

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
    _logic.setDoc(widget.initDocPath);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider.value(
      value: _logic,
      builder: (context, _) {
        return Builder(
          builder: (context) {
          final state = context.watch<EditPageLogic>().curState;
            return Scaffold(
              appBar: AppBar(title: SelectableText(state.docName)),
              body: EditorView(state.docPath),
            );
          },
        );
      },
    );
  }
}

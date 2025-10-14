import 'package:flutter/material.dart';

import '../../function/logic_builder.dart';
import 'edit_page_logic.dart';
import 'edit_page_state.dart';
import 'editor/editor_view.dart';

class EditPageView extends StatelessWidget {
  const EditPageView({super.key, required this.editPageState});
  const EditPageView.empty({super.key}) : editPageState = const EditPageState();

  final EditPageState editPageState;

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      logic: EditPageLogic(editPageState),
      builder: (context, state, logic) {
        return Scaffold(
          appBar: AppBar(title: Text('编辑器')),
          body: EditorView(textDirection: TextDirection.ltr),
        );
      },
    );
  }
}

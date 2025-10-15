import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'desktop_editor.dart';
import 'editor_logic.dart';

class EditorView extends StatelessWidget {
  const EditorView({super.key, this.textDirection = TextDirection.ltr});

  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    final logic = context.watch<EditorLogic>();
    final state = logic.state;
    return ColoredBox(
      color: Colors.white,
      child: Builder(
        builder: (context) {
          if (state.editorState == null) {
            return Center(child: CircularProgressIndicator());
          }
          return DesktopEditor(
            editorState: state.editorState!,
            textDirection: textDirection,
          );
        },
      ),
    );
  }
}

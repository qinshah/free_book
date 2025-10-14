import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

import 'desktop_editor.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key, this.textDirection = TextDirection.ltr});

  final TextDirection textDirection;

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isInitialized = false;

  EditorState? _editorState;
  WordCountService? _wordCountService;

  int wordCount = 0;
  int charCount = 0;

  int selectedWordCount = 0;
  int selectedCharCount = 0;

  void registerWordCounter() {
    _wordCountService?.removeListener(onWordCountUpdate);
    _wordCountService?.dispose();

    _wordCountService = WordCountService(editorState: _editorState!)
      ..register();
    _wordCountService!.addListener(onWordCountUpdate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onWordCountUpdate();
    });
  }

  void onWordCountUpdate() {
    setState(() {
      wordCount = _wordCountService!.documentCounters.wordCount;
      charCount = _wordCountService!.documentCounters.charCount;
      selectedWordCount = _wordCountService!.selectionCounters.wordCount;
      selectedCharCount = _wordCountService!.selectionCounters.charCount;
    });
  }

  @override
  void dispose() {
    _editorState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        ColoredBox(
          color: Colors.white,
          child: Builder(
            builder: (context) {
              if (!_isInitialized || _editorState == null) {
                _isInitialized = true;
                EditorState editorState = EditorState(
                  document: Document.blank(),
                );

                editorState.logConfiguration
                  ..handler = debugPrint
                  ..level = AppFlowyEditorLogLevel.all;

                _editorState = editorState;
                registerWordCounter();
              }

              return DesktopEditor(
                editorState: _editorState!,
                textDirection: widget.textDirection,
              );
            },
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(8),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Word Count: $wordCount  |  Character Count: $charCount',
                  style: const TextStyle(fontSize: 11),
                ),
                if (!(_editorState?.selection?.isCollapsed ?? true))
                  Text(
                    '(In-selection) Word Count: $selectedWordCount  |  Character Count: $selectedCharCount',
                    style: const TextStyle(fontSize: 11),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

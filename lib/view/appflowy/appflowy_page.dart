import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';

import 'desktop_editor.dart';

part 'data.appflowy.dart';

class AppflowyPage extends StatefulWidget {
  const AppflowyPage({super.key});

  @override
  State<AppflowyPage> createState() => _AppflowyPageState();
}

class _AppflowyPageState extends State<AppflowyPage> {
  OverlayEntry? overlayEntry;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Appflowy编辑器')),
      body: _Editor(
        jsonString: _jsonString,
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

class _Editor extends StatefulWidget {
  const _Editor({
    required this.jsonString,
    this.textDirection = TextDirection.ltr,
  });

  final String jsonString;

  final TextDirection textDirection;

  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  bool _isInitialized = false;

  EditorState? _editorState;
  WordCountService? _wordCountService;

  @override
  void didUpdateWidget(covariant _Editor oldWidget) {
    if (oldWidget.jsonString != widget.jsonString) {
      _editorState = null;
      _isInitialized = false;
    }
    super.didUpdateWidget(oldWidget);
  }

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
    return Stack(
      children: [
        ColoredBox(
          color: Colors.white,
          child: Builder(
            builder: (context) {
              if (!_isInitialized || _editorState == null) {
                _isInitialized = true;
                EditorState editorState = EditorState(
                  document: Document.fromJson(
                    Map<String, Object>.from(json.decode(widget.jsonString)),
                  ),
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

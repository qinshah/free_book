import 'package:flutter/material.dart';
import 'package:free_book/module/edit/editor/drag_to_reorder_editor.dart';
import 'package:provider/provider.dart';

import 'editor_logic.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

class EditorView extends StatefulWidget {
  const EditorView(
    this.docPath, {
    super.key,
    this.textDirection = TextDirection.ltr,
  });

  final TextDirection textDirection;

  final String? docPath;

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  late final EditorLogic _logic;
  @override
  void initState() {
    super.initState();
    _logic = context.read<EditorLogic>();
    _logic.loadDoc(widget.docPath, context);
  }

  @override
  void dispose() {
    super.dispose();
    _logic.rememberDispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final curState = context.watch<EditorLogic>().curState;
    final editorState = curState.editorState;
    if (editorState == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ColoredBox(
          color: theme.cardColor,
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                // 工具条
                child: MobileToolbar(
                  editorState: editorState,
                  toolbarHeight: 38,
                  backgroundColor:
                      theme.bottomNavigationBarTheme.backgroundColor!,
                  foregroundColor: theme.textTheme.bodyMedium!.color!,
                  tabbarSelectedForegroundColor: theme.cardColor,
                  tabbarSelectedBackgroundColor: theme.primaryColor,
                  itemOutlineColor:
                      theme.bottomNavigationBarTheme.backgroundColor!,
                  toolbarItems: [
                    textDecorationMobileToolbarItem,
                    buildTextAndBackgroundColorMobileToolbarItem(),
                    blocksMobileToolbarItem,
                    linkMobileToolbarItem,
                    dividerMobileToolbarItem,
                  ],
                ),
              ),
              // 选中内容时的浮动工具条
              SliverFillRemaining(
                child: FloatingToolbar(
                  items: [
                    paragraphItem,
                    ...headingItems,
                    ...markdownFormatItems,
                    quoteItem,
                    bulletedListItem,
                    numberedListItem,
                    linkItem,
                    buildTextColorItem(),
                    buildHighlightColorItem(),
                    ...textDirectionItems,
                    ...alignmentItems,
                  ],
                  tooltipBuilder: (context, _, message, child) {
                    return Tooltip(
                      message: message,
                      preferBelow: false,
                      child: child,
                    );
                  },
                  editorState: editorState,
                  textDirection: widget.textDirection,
                  editorScrollController: curState.editorScrollController,
                  child: Directionality(
                    textDirection: widget.textDirection,
                    child: AppFlowyEditor(
                      showMagnifier: true, //显示放大镜，only works on iOS or Android.
                      editorState: editorState,
                      editorScrollController: curState.editorScrollController,
                      blockComponentBuilders: _buildBlockComponentBuilders(),
                      commandShortcutEvents: _logic.getCommandShortcuts(
                        context,
                      ),
                      editorStyle: _buildEditorStyle(),
                      enableAutoComplete: true, // 自动完成，类似ai代码提示
                      autoCompleteTextProvider: _buildAutoCompleteTextProvider,
                      dropTargetStyle: const AppFlowyDropTargetStyle(
                        color: Colors.red,
                      ),
                      footer: _buildFooter(editorState), // 页脚
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 编辑器样式 TODO 放别地方管理
  EditorStyle _buildEditorStyle() {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyLarge!;
    return EditorStyle(
      cursorWidth: 2.0, //光标宽度
      cursorColor: theme.primaryColor,
      selectionColor: theme.primaryColor.withAlpha(166),
      textStyleConfiguration: TextStyleConfiguration(
        text: textStyle, //普通
        bold: textStyle.copyWith(fontWeight: FontWeight.w800), //加粗
      ),
      padding: EdgeInsets.only(left: 6, right: 16),
      //最大宽度，导致换行的宽度，如果某行超过父约束依旧会换行
      maxWidth: double.infinity,
      // 每一行输入框前面的组件
      textSpanOverlayBuilder: (_, __, ___) => [],
      // 手机上光标下面手柄的颜色
      dragHandleColor: theme.primaryColor,
      textSpanDecorator: defaultTextSpanDecoratorForAttribute,
    );
  }

  Widget _buildFooter(EditorState editorState) {
    return SizedBox(
      height: 100,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          // check if the document is empty, if so, add a new paragraph block.
          if (editorState.document.root.children.isEmpty) {
            final transaction = editorState.transaction;
            transaction.insertNode([0], paragraphNode());
            await editorState.apply(transaction);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              editorState.selection = Selection.collapsed(Position(path: [0]));
            });
          }
        },
      ),
    );
  }

  String? _buildAutoCompleteTextProvider(
    BuildContext context,
    Node node,
    TextSpan? textSpan,
  ) {
    final editorState = context.read<EditorState>();
    final selection = editorState.selection;
    final delta = node.delta;
    if (selection == null ||
        delta == null ||
        !selection.isCollapsed ||
        selection.endIndex != delta.length ||
        !node.path.equals(selection.start.path)) {
      return null;
    }
    final text = delta.toPlainText();
    // An example, if the text ends with 'hello', then show the autocomplete.
    if (text.endsWith('hello')) {
      return ' world';
    }
    return null;
  }

  /// 编辑器块 TODO 放别的地方管理
  Map<String, BlockComponentBuilder> _buildBlockComponentBuilders() {
    final map = {
      ...standardBlockComponentBuilderMap,
      // columns block
      ColumnBlockKeys.type: ColumnBlockComponentBuilder(),
      ColumnsBlockKeys.type: ColumnsBlockComponentBuilder(),
    };
    // customize the heading block component
    final levelToFontSize = [30.0, 26.0, 22.0, 18.0, 16.0, 14.0];
    map[HeadingBlockKeys.type] = HeadingBlockComponentBuilder(
      textStyleBuilder: (level) => TextStyle(
        fontSize: levelToFontSize.elementAtOrNull(level - 1) ?? 14.0,
        fontWeight: FontWeight.w600,
      ),
    );
    // customize the padding
    map.forEach((key, value) {
      value.configuration = value.configuration.copyWith(
        padding: (node) {
          if (node.type == ColumnsBlockKeys.type ||
              node.type == ColumnBlockKeys.type) {
            return EdgeInsets.zero;
          }
          return const EdgeInsets.symmetric(vertical: 8.0);
        },
        blockSelectionAreaMargin: (_) =>
            const EdgeInsets.symmetric(vertical: 1.0),
      );

      if (key != PageBlockKeys.type) {
        // 每行前面的拖动块
        value.showActions = (_) => true;
        value.actionBuilder = (context, actionState) {
          return DragToReorderAction(
            blockComponentContext: context,
            builder: value,
          );
        };
      }
    });
    return map;
  }
}

class HoverMenu extends StatefulWidget {
  final Widget child;
  final WidgetBuilder itemBuilder;

  const HoverMenu({super.key, required this.child, required this.itemBuilder});

  @override
  HoverMenuState createState() => HoverMenuState();
}

class HoverMenuState extends State<HoverMenu> {
  OverlayEntry? overlayEntry;

  bool canCancelHover = true;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (details) {
        overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(overlayEntry!);
      },
      onExit: (details) {
        // delay the removal of the overlay entry to avoid flickering.
        Future.delayed(const Duration(milliseconds: 100), () {
          if (canCancelHover) {
            overlayEntry?.remove();
          }
        });
      },
      child: widget.child,
    );
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        child: MouseRegion(
          cursor: SystemMouseCursors.text,
          hitTestBehavior: HitTestBehavior.opaque,
          onEnter: (details) {
            canCancelHover = false;
          },
          onExit: (details) {
            canCancelHover = true;
          },
          child: widget.itemBuilder(context),
        ),
      ),
    );
  }
}

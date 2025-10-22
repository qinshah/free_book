import 'package:flutter/material.dart';
import 'package:free_book/function/device.dart';
import 'package:free_book/module/edit/editor/drag_to_reorder_editor.dart';
import 'package:free_book/module/edit/editor/editor_state.dart';
import 'package:free_book/module/edit/editor/view/tool_bar.dart';
import 'package:provider/provider.dart';

import '../editor_logic.dart';
import 'package:appflowy_editor/appflowy_editor.dart' hide ContextMenu;

class EditorView extends StatefulWidget {
  const EditorView(
    this.docPath, {
    super.key,
    this.isDraft = false,
    this.textDirection = TextDirection.ltr,
  });

  final bool isDraft;

  final TextDirection textDirection;

  final String? docPath;

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  late final _logic = context.read<EditorLogic>();

  // final _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _logic.loadDoc(widget.docPath, context, widget.isDraft);
  }

  @override
  void dispose() {
    super.dispose();
    _logic.rememberDispose();
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final curState = context.watch<EditorLogic>().curState;
    final editorState = curState.editorState;
    if (editorState == null) {
      return Center(child: CircularProgressIndicator());
    }
    return CustomScrollView(
      scrollBehavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false),
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        // if (kDebugMode)
        //   SliverToBoxAdapter(
        //     child: TextButton(
        //       onPressed: () {
        //         // editorState.selectionService.onPanUpdate(details, mode)
        //         // SelectionMenu(
        //         //   context: context,
        //         //   editorState: editorState,
        //         //   selectionMenuItems: standardSelectionMenuItems,
        //         //   deleteSlashByDefault: false,
        //         //   singleColumn: true,
        //         // ).show();
        //       },
        //       child: Text('测试'),
        //     ),
        //   ),
        // 工具栏
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ToolBar(),
            ),
          ),
        ),
        // SliverToBoxAdapter(
        //   // 工具条
        //   child: MobileToolbar(
        //     editorState: editorState,
        //     toolbarHeight: 38,
        //     backgroundColor:
        //         theme.bottomNavigationBarTheme.backgroundColor!,
        //     foregroundColor: theme.textTheme.bodyMedium!.color!,
        //     tabbarSelectedForegroundColor: theme.cardColor,
        //     tabbarSelectedBackgroundColor: theme.primaryColor,
        //     itemOutlineColor:
        //         theme.bottomNavigationBarTheme.backgroundColor!,
        //     toolbarItems: [
        //       textDecorationMobileToolbarItem,
        //       buildTextAndBackgroundColorMobileToolbarItem(),
        //       blocksMobileToolbarItem,
        //       linkMobileToolbarItem,
        //       dividerMobileToolbarItem,
        //     ],
        //   ),
        // ),
        SliverFillRemaining(
          child: Device.isMobile || Device.isOhos
              ? // 手机和鸿蒙暂时不显示浮动工具条
                _buildEditor(editorState, curState, context)
              : // 选中内容时的浮动工具条
                FloatingToolbar(
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
                  // 浮动条的构建
                  // toolbarBuilder: MyEditorState.showFloatingToolbar
                  //     ? null
                  //     : (_, _, _, _) => SizedBox(),
                  // 每项的构建
                  tooltipBuilder: (context, _, message, child) {
                    return Tooltip(
                      message: message,
                      preferBelow: true,
                      child: child,
                    );
                  },
                  editorState: editorState,
                  textDirection: widget.textDirection,
                  editorScrollController: curState.editorScrollController,
                  child: _buildEditor(editorState, curState, context),
                ),
        ),
      ],
    );
  }

  Directionality _buildEditor(
    EditorState editorState,
    MyEditorState curState,
    BuildContext context,
  ) {
    return Directionality(
      textDirection: widget.textDirection,
      child: AppFlowyEditor(
        // focusNode: _focusNode,
        autoFocus: widget.docPath == null,
        showMagnifier: true, //显示放大镜，only works on iOS or Android.
        editorState: editorState,
        editorScrollController: curState.editorScrollController,
        blockComponentBuilders: _buildBlockComponentBuilders(),
        characterShortcutEvents: null, // [], // 输入斜杠后弹出的功能
        commandShortcutEvents: _logic.getCommandShortcuts(context),
        editorStyle: _buildEditorStyle(),
        enableAutoComplete: true, // 自动完成，类似ai代码提示
        autoCompleteTextProvider: _buildAutoCompleteTextProvider,
        dropTargetStyle: const AppFlowyDropTargetStyle(color: Colors.red),
        // footer: _buildFooter(editorState), // 编辑器底部
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

  // Widget _buildFooter(EditorState editorState) {
  //   return SizedBox(
  //     height: MediaQuery.of(context).size.height / 1.5,
  //     child: GestureDetector(
  //       behavior: HitTestBehavior.opaque,
  //       onTap: () {
  //         final document = editorState.document;
  //         final lastNode = document.root.children.last; // 最后一个节点
  //         final end = lastNode.delta?.length ?? 0; // 节点文本长度
  //         final newSel = Selection.collapsed(
  //           Position(path: lastNode.path, offset: end),
  //         );
  //         editorState.updateSelectionWithReason(newSel);
  //       },
  //     ),
  //   );
  // }

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
      // 鸿蒙拖动块有问题暂不显示
      if (key != PageBlockKeys.type && !Device.isOhos) {
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

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/assets.dart';
import 'package:free_book/module/editor/editor_logic.dart';
import 'package:free_book/module/editor/editor_state.dart';
import 'package:provider/provider.dart';

class ToolBar extends StatefulWidget {
  const ToolBar({super.key});

  @override
  State<ToolBar> createState() => _ToolBarState();
}

class _ToolBarState extends State<ToolBar> with TickerProviderStateMixin {
  late final _maxBodyHeight = 0.4 * MediaQuery.of(context).size.height;
  late final _tabCntlr = TabController(
    length: _Tools.values.length,
    vsync: this,
  );
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => MyEditorState.expansibleCntlr.expand(),
      onExit: kDebugMode
          ? null
          : (_) => MyEditorState.expansibleCntlr.collapse(),
      child: ExpansionTile(
        initiallyExpanded: true,
        showTrailingIcon: false,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        collapsedBackgroundColor:
            theme.bottomNavigationBarTheme.backgroundColor,
        collapsedShape: const Border(),
        shape: const Border(),
        controller: MyEditorState.expansibleCntlr,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: ColoredBox(
          color: theme.bottomNavigationBarTheme.backgroundColor!,
          child: TabBar(
            dividerHeight: 0,
            isScrollable: true,
            controller: _tabCntlr,
            tabAlignment: TabAlignment.start,
            tabs: _Tools.values.map((tools) => Tab(text: tools.name)).toList(),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            onTap: (_) {
              if (_tabCntlr.offset == 0) {
                MyEditorState.expansibleCntlr.isExpanded
                    ? MyEditorState.expansibleCntlr.collapse()
                    : MyEditorState.expansibleCntlr.expand();
              } else {
                MyEditorState.expansibleCntlr.expand();
              }
            },
          ),
        ),
        children: [
          Column(
            children: [
              SizedBox(
                height: MyEditorState.toolBarHeight,
                child: TabBarView(
                  controller: _tabCntlr,
                  children: _Tools.values.map((tools) {
                    return tools.view;
                  }).toList(),
                ),
              ),
              GestureDetector(
                onVerticalDragUpdate: (details) {
                  final newHight =
                      MyEditorState.toolBarHeight + details.delta.dy;
                  setState(() {
                    MyEditorState.toolBarHeight = newHight.clamp(
                      50,
                      _maxBodyHeight,
                    );
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown,
                  child: ColoredBox(
                    color: theme.bottomNavigationBarTheme.backgroundColor!,
                    child: Center(child: Icon(Icons.drag_handle, size: 16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tools {
  final String name;
  final Widget view;
  const _Tools(this.name, this.view);

  static const values = [
    _Tools('内容类型', _ContentTypeView()),
    _Tools('文字样式', _TextStyleView()),
  ];
}

class _ContentTypeView extends StatefulWidget {
  const _ContentTypeView();

  @override
  State<_ContentTypeView> createState() => _ContentTypeViewState();
}

class _TypeItem {
  final IconData iconData;
  final String name;
  final String type;
  final int? level;

  _TypeItem(this.name, this.type, this.iconData, [this.level]);
}

class _ContentTypeViewState extends State<_ContentTypeView> {
  final _items = [
    _TypeItem('标题1', HeadingBlockKeys.type, FIcons.heading1, 1),
    _TypeItem('标题2', HeadingBlockKeys.type, FIcons.heading2, 2),
    _TypeItem('标题3', HeadingBlockKeys.type, FIcons.heading3, 3),
    _TypeItem('无序列表', BulletedListBlockKeys.type, FIcons.list),
    _TypeItem('有序列表', NumberedListBlockKeys.type, FIcons.listOrdered),
    _TypeItem('复选框', TodoListBlockKeys.type, Icons.check_box_outlined),
    _TypeItem('引用', QuoteBlockKeys.type, FIcons.quote),
  ];
  late ThemeData _theme;

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    final editorLigic = context.read<EditorLogic>();
    final editorState = editorLigic.curState.editorState!;
    return ValueListenableBuilder<Selection?>(
      valueListenable: editorState.selectionNotifier,
      builder: (context, selection, child) {
        final node = editorState.getNodeAtPath(selection?.start.path ?? [])!;
        return SingleChildScrollView(
          child: Center(
            child: Wrap(
              spacing: 2,
              runSpacing: 2,
              children: _items.map((item) {
                final isSelected =
                    node.type == item.type &&
                    (item.level == null ||
                        node.attributes[HeadingBlockKeys.level] == item.level);
                return _buildItem(item, isSelected, editorState);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItem(_TypeItem item, bool isSelected, EditorState? editorState) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        setState(() {
          editorState?.formatNode(
            editorState.selection,
            (node) => node.copyWith(
              type: isSelected ? ParagraphBlockKeys.type : item.type,
              attributes: {
                ParagraphBlockKeys.delta: (node.delta ?? Delta()).toJson(),
                blockComponentBackgroundColor:
                    node.attributes[blockComponentBackgroundColor],
                if (!isSelected && item.type == TodoListBlockKeys.type)
                  TodoListBlockKeys.checked: false,
                if (!isSelected && item.type == HeadingBlockKeys.type)
                  HeadingBlockKeys.level: item.level,
              },
            ),
            selectionExtraInfo: {
              selectionExtraInfoDoNotAttachTextService: true,
            },
          );
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? _theme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        width: 55,
        height: 55,
        // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.iconData),
            Text(item.name, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _TextStyleView extends StatefulWidget {
  const _TextStyleView();

  @override
  State<_TextStyleView> createState() => _TextStyleViewState();
}

class _Decoration {
  final IconData iconData;
  final String name;
  final String type;

  _Decoration(this.name, this.type, this.iconData);
}

class _TextStyleViewState extends State<_TextStyleView> {
  final _decorations = [
    _Decoration(
      AppFlowyEditorL10n.current.bold, // 粗体
      AppFlowyRichTextKeys.bold,
      Icons.format_bold_outlined,
    ),
    _Decoration(
      AppFlowyEditorL10n.current.italic, // 斜体
      AppFlowyRichTextKeys.italic,
      Icons.format_italic_outlined,
    ),
    _Decoration(
      AppFlowyEditorL10n.current.underline, // 下划线
      AppFlowyRichTextKeys.underline,
      Icons.format_underline_outlined,
    ),
    _Decoration(
      AppFlowyEditorL10n.current.strikethrough, // 删除线
      AppFlowyRichTextKeys.strikethrough,
      Icons.format_strikethrough_outlined,
    ),
  ];

  late ThemeData _theme = Theme.of(context);
  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    final editorLigic = context.read<EditorLogic>();
    final editorState = editorLigic.curState.editorState;
    return ListView(
      children: [
        Center(
          child: ValueListenableBuilder<Selection?>(
            valueListenable: editorState!.selectionNotifier,
            builder: (context, selection, child) {
              return Wrap(
                spacing: 2,
                runSpacing: 2,
                children: _decorations.map((decoration) {
                  final bool isSelected;
                  final selection = editorState.selection;
                  if (selection == null) {
                    isSelected = false;
                  } else if (selection.isCollapsed) {
                    isSelected = editorState.toggledStyle.containsKey(
                      decoration.type,
                    );
                  } else {
                    final nodes = editorState.getNodesInSelection(selection);
                    isSelected = nodes.allSatisfyInSelection(selection, (
                      delta,
                    ) {
                      return delta.everyAttributes(
                        (attributes) => attributes[decoration.type] == true,
                      );
                    });
                  }
                  return _buildDecorationBtn(
                    decoration,
                    isSelected,
                    editorState,
                  );
                }).toList(),
              );
            },
          ),
        ),
        // 颜色
        _TextColorView(editorState),
      ],
    );
  }

  Widget _buildDecorationBtn(
    _Decoration decoration,
    bool isSelected,
    EditorState editorState,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () async {
        await editorState.toggleAttribute(decoration.type);
        setState(() {
          // 刷新
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? _theme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        width: 55,
        height: 55,
        // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(decoration.iconData),
            Text(decoration.name, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _TextColorView extends StatefulWidget {
  const _TextColorView(this.editorState);

  final EditorState editorState;

  @override
  State<_TextColorView> createState() => _TextColorViewState();
}

class _TextColorViewState extends State<_TextColorView> {
  final _colors = [
    (mColor: Colors.grey, name: AppFlowyEditorL10n.current.fontColorGray),
    (mColor: Colors.brown, name: AppFlowyEditorL10n.current.fontColorBrown),
    (mColor: Colors.yellow, name: AppFlowyEditorL10n.current.fontColorYellow),
    (mColor: Colors.green, name: AppFlowyEditorL10n.current.fontColorGreen),
    (mColor: Colors.blue, name: AppFlowyEditorL10n.current.fontColorBlue),
    (mColor: Colors.purple, name: AppFlowyEditorL10n.current.fontColorPurple),
    (mColor: Colors.pink, name: AppFlowyEditorL10n.current.fontColorPink),
    (mColor: Colors.red, name: AppFlowyEditorL10n.current.fontColorRed),
  ];
  late final _editorState = widget.editorState;
  ThemeData get _getTheme => Theme.of(context);
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final textColorView = _index == 0;
    return Column(
      children: [
        CupertinoSlidingSegmentedControl(
          groupValue: _index,
          children: {0: Text('文字颜色'), 1: Text('文字背景色')},
          onValueChanged: (int? value) => setState(() => _index = value!),
        ),
        const SizedBox(height: 5),
        ValueListenableBuilder<Selection?>(
          valueListenable: _editorState.selectionNotifier,
          builder: (context, selection, child) {
            return Wrap(
              spacing: 5,
              runSpacing: 5,
              children: _colors.map((e) {
                final bool isSelected;
                if (selection == null) {
                  isSelected = false;
                } else {
                  final nodes = _editorState.getNodesInSelection(selection);
                  isSelected = nodes.allSatisfyInSelection(selection, (delta) {
                    return delta.everyAttributes((attributes) {
                      if (textColorView) {
                        return attributes[AppFlowyRichTextKeys.textColor] ==
                            e.mColor.toHex();
                      }
                      return attributes[AppFlowyRichTextKeys.backgroundColor] ==
                          e.mColor.withAlpha(666).toHex();
                    });
                  });
                }
                return _buildColorBtn(
                  e.mColor,
                  e.name,
                  isSelected,
                  textColorView,
                  selection,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildColorBtn(
    MaterialColor mColor,
    String name,
    bool isSelected,
    bool textColorView,
    Selection? selection,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        if (isSelected) {
          setState(() {
            _editorState.formatDelta(selection, {
              textColorView
                      ? AppFlowyRichTextKeys.textColor
                      : AppFlowyRichTextKeys.backgroundColor:
                  null,
            });
          });
        } else {
          setState(() {
            if (textColorView) {
              formatFontColor(
                _editorState,
                _editorState.selection,
                mColor.toHex(),
              );
            } else {
              formatHighlightColor(
                _editorState,
                _editorState.selection,
                mColor.withAlpha(666).toHex(),
              );
            }
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: textColorView ? _getTheme.cardColor : mColor.withAlpha(666),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? _getTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        width: 50,
        height: 50,
        child: Center(
          child: Text(
            name,
            style: TextStyle(color: textColorView ? mColor : null),
          ),
        ),
      ),
    );
  }
}

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/assets.dart';
import 'package:free_book/module/edit/editor/editor_logic.dart';
import 'package:free_book/module/edit/editor/editor_state.dart';
import 'package:provider/provider.dart';

class ToolBar extends StatefulWidget {
  const ToolBar({super.key});

  @override
  State<ToolBar> createState() => _ToolBarState();
}

class _ToolBarState extends State<ToolBar> with TickerProviderStateMixin {
  final _expansibleCntlr = ExpansibleController();
  late final _maxBodyHeight = 0.4 * MediaQuery.of(context).size.height;
  late final _tabCntlr = TabController(
    length: _Tools.values.length,
    vsync: this,
  );
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => _expansibleCntlr.expand(),
      onExit: kDebugMode ? null : (_) => _expansibleCntlr.collapse(),
      child: ExpansionTile(
        showTrailingIcon: false,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        collapsedBackgroundColor:
            theme.bottomNavigationBarTheme.backgroundColor,
        collapsedShape: const Border(),
        shape: const Border(),
        controller: _expansibleCntlr,
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
                _expansibleCntlr.isExpanded
                    ? _expansibleCntlr.collapse()
                    : _expansibleCntlr.expand();
              } else {
                _expansibleCntlr.expand();
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
    _Tools('内容类型', _ContentType()),
    _Tools('文字样式', Text('文字样式')),
  ];
}

class _ContentType extends StatefulWidget {
  const _ContentType();

  @override
  State<_ContentType> createState() => _ContentTypeState();
}

class _TypeItem {
  final IconData iconData;
  final String name;
  final String type;
  final int? level;

  _TypeItem(this.name, this.type, this.iconData, [this.level]);
}

class _ContentTypeState extends State<_ContentType> {
  final _items = [
    _TypeItem('标题1', 'heading', FIcons.heading1, 1),
    _TypeItem('标题2', 'heading', FIcons.heading2, 2),
    _TypeItem('标题3', 'heading', FIcons.heading3, 3),
  ];

  @override
  Widget build(BuildContext context) {
    final editorLigic = context.read<EditorLogic>();
    final editorState = editorLigic.curState.editorState!;
    return ValueListenableBuilder<Selection?>(
      valueListenable: editorState.selectionNotifier,
      builder: (context, selection, child) {
        final node = editorState.getNodeAtPath(selection?.start.path ?? [])!;
        return Padding(
          padding: const EdgeInsets.all(6),
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 2,
              runSpacing: 2,
              children: _items.map((item) {
                final isSelected =
                    node.type == item.type &&
                    (item.level == null ||
                        node.attributes['level'] == item.level);
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
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Column(
          children: [
            Icon(item.iconData),
            Text(item.name, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

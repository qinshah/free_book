import 'package:flutter/material.dart';

import '../../data_model/page.dart';
import '../../function/state_management.dart';
import '../edit/edit_page_view.dart';
import '../settings/settings_page.dart';
import 'root_logic.dart';
import 'root_state.dart';

class RootView extends StatefulWidget {
  const RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView>
    with LogicMix<RootView, RootLogic> {
  final _pages = const {
    AppPage(
      name: '首页',
      icon: Icon(Icons.home),
      view: Center(child: Text('首页')),
    ),
    AppPage(
      name: '快速新建',
      icon: Icon(Icons.create_outlined),
      view: EditPageView.empty(),
    ),
    AppPage(name: '设置', icon: Icon(Icons.settings), view: SettingsPage()),
  };

  @override
  Widget build(BuildContext context) {
    final state = logic.state;
    final pageIndex = state.pageIndex;
    return OrientationBuilder(
      builder: (context, orientation) {
        final vertical = orientation == Orientation.portrait;
        if (vertical) {
          return Scaffold(
            appBar: AppBar(toolbarHeight: 0),
            body: _buildPage(pageIndex, Axis.horizontal),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: pageIndex,
              onTap: logic.changePage,
              items: _pages.map((page) {
                return BottomNavigationBarItem(
                  icon: page.icon,
                  label: page.name,
                );
              }).toList(),
            ),
          );
        }
        return Material(
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: pageIndex,
                labelType: NavigationRailLabelType.all,
                onDestinationSelected: logic.changePage,
                destinations: _pages.map((item) {
                  return NavigationRailDestination(
                    icon: item.icon,
                    label: Text(item.name),
                  );
                }).toList(),
              ),
              Expanded(child: _buildPage(pageIndex, Axis.vertical)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPage(int index, Axis direction) {
    return PageView.builder(
      key: logic.state.pageKey,
      controller: logic.state.pageViewCntlr,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _pages.length,
      itemBuilder: (BuildContext context, int index) {
        return _pages.toList()[index].view;
      },
    );
  }

  @override
  RootLogic createLogic() => RootLogic(RootState());
}

import 'package:flutter/material.dart';
import 'package:free_book/function/screen.dart';
import 'package:provider/provider.dart';

import '../../data_model/page.dart';
import '../edit/edit_page_view.dart';
import '../home/home_page_view.dart';
import '../settings/settings_page.dart';
import 'root_logic.dart';

class RootView extends StatelessWidget {
  const RootView({super.key});

  final _pages = const {
    AppPage(
      name: '首页',
      icon: Icon(Icons.home),
      view: Center(child: HomePageView()),
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
    return OrientationBuilder(
      builder: (context, orientation) {
        final vertical = orientation == Orientation.portrait;
        if (vertical) {
          Screen.setNormalUiMode();
          return _buildVertical(context);
        }
        // else横屏，设为全屏
        Screen.setFullUiMode();
        return _buildHorizontal(context);
      },
    );
  }

  SafeArea _buildHorizontal(BuildContext context) {
    final logic = context.watch<RootLogic>();
    final pageIndex = logic.state.pageIndex;
    return SafeArea(
      left: false,
      right: false,
      bottom: false,
      top: false,
      child: Material(
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
            Expanded(child: _buildPage(pageIndex, Axis.vertical, logic)),
          ],
        ),
      ),
    );
  }

  Scaffold _buildVertical(BuildContext context) {
    final logic = context.watch<RootLogic>();
    final pageIndex = logic.state.pageIndex;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _buildPage(pageIndex, Axis.horizontal, logic),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: logic.changePage,
        items: _pages.map((page) {
          return BottomNavigationBarItem(icon: page.icon, label: page.name);
        }).toList(),
      ),
    );
  }

  Widget _buildPage(int index, Axis direction, logic) {
    return PageView.builder(
      scrollDirection: direction,
      key: logic.state.pageViewKey,
      controller: logic.state.pageViewCntlr,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _pages.length,
      itemBuilder: (BuildContext context, int index3) {
        return _pages.toList()[index].view;
      },
    );
  }
}

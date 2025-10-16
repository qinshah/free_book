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
      name: '草稿',
      icon: Icon(Icons.draw_outlined),
      view: EditPageView.draft(),
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
    final pageIndex = logic.curState.pageIndex;
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
            Expanded(child: _buildPage(Axis.vertical, logic)),
          ],
        ),
      ),
    );
  }

  Scaffold _buildVertical(BuildContext context) {
    final logic = context.watch<RootLogic>();
    final pageIndex = logic.curState.pageIndex;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _buildPage(Axis.horizontal, logic),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: logic.changePage,
        items: _pages.map((page) {
          return BottomNavigationBarItem(icon: page.icon, label: page.name);
        }).toList(),
      ),
    );
  }

  Widget _buildPage(Axis direction, RootLogic logic) {
    return PageView.builder(
      key: logic.curState.pageViewKey,
      controller: logic.curState.pageViewCntlr,
      scrollDirection: direction,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _pages.length,
      itemBuilder: (BuildContext context, int index) {
        return _pages.toList()[index].view;
      },
    );
  }
}

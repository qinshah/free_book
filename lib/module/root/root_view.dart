import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:free_book/function/screen.dart';
import 'package:provider/provider.dart';

import '../../data_model/page.dart';
import '../edit/edit_page_view.dart';
import '../home/home_page_view.dart';
import '../settings/settings_page.dart';
import 'root_logic.dart';

class RootView extends StatefulWidget {
  const RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  late final _logic = context.read<RootLogic>();
  final _pageViewCntlr = PageController();
  final _pageViewKey = GlobalKey();

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
    var curPageIndex = context.watch<RootLogic>().curState.pageIndex;
    return SafeArea(
      left: false,
      right: false,
      bottom: false,
      top: false,
      child: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: curPageIndex,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (index) =>
                  _logic.changePage(index, _pageViewCntlr),
              destinations: _pages.map((item) {
                return NavigationRailDestination(
                  icon: item.icon,
                  label: Text(item.name),
                );
              }).toList(),
            ),
            Expanded(child: _buildPage(Axis.vertical)),
          ],
        ),
      ),
    );
  }

  Widget _buildVertical(BuildContext context) {
    // final theme = Theme.of(context);
    var curPageIndex = context.watch<RootLogic>().curState.pageIndex;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _buildPage(Axis.horizontal),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: BottomNavigationBar(
            currentIndex: curPageIndex,
            onTap: (index) => _logic.changePage(index, _pageViewCntlr),
            items: _pages.map((page) {
              return BottomNavigationBarItem(icon: page.icon, label: page.name);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(Axis direction) {
    return PageView.builder(
      key: _pageViewKey,
      controller: _pageViewCntlr,
      scrollDirection: direction,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _pages.length,
      itemBuilder: (BuildContext context, int index) {
        return _pages.toList()[index].view;
      },
    );
  }
}

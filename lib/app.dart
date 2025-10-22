import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:free_book/function/screen.dart';
import 'package:free_book/module/home/home_page_logic.dart';
import 'package:free_book/module/home/home_page_state.dart';
import 'package:free_book/module/root/root_logic.dart';
import 'package:free_book/module/root/root_state.dart';
import 'package:free_book/module/root/root_view.dart';
import 'package:provider/provider.dart';


part 'data/theme.dart';

class App extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const App({super.key, this.savedThemeMode});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    // 根据屏幕方向设置屏幕UI模式
    MediaQuery.of(context).orientation == Orientation.portrait
        ? Screen.setNormalUIMode()
        : Screen.setFullUIMode();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RootLogic(RootState())),
        ChangeNotifierProvider(create: (_) => HomePageLogic(HomePageState())),
      ],
      child: AdaptiveTheme(
        light: _getThemeData(),
        dark: _getDarkThemeData(),
        initial: widget.savedThemeMode ?? AdaptiveThemeMode.system,
        builder: (theme, darkTheme) => MaterialApp(
          home: RootView(),
          builder: FToastBuilder(),
          theme: theme,
          darkTheme: darkTheme,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            AppFlowyEditorLocalizations.delegate,
          ],
          // AppFlowy supportedLocales含中文
          supportedLocales:
              AppFlowyEditorLocalizations.delegate.supportedLocales,
        ),
      ),
    );
  }
}

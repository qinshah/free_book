import 'package:flutter/material.dart';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:free_book/function/storage.dart';
import 'package:free_book/module/home/home_page_logic.dart';
import 'package:free_book/module/home/home_page_state.dart';
import 'package:free_book/module/root/root_logic.dart';
import 'package:free_book/module/root/root_state.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'module/root/root_view.dart';

part 'data/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.i.init(); // 初始化存储功能

  // 初始化app主题模式
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(App(savedThemeMode: savedThemeMode));
}

class App extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const App({super.key, this.savedThemeMode});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
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

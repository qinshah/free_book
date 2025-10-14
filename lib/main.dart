import 'package:flutter/material.dart';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'module/root/root_view.dart';

part 'data/theme.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RootView(),
      theme: _getThemeData(),
      darkTheme: _getDarkThemeData(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        AppFlowyEditorLocalizations.delegate,
      ],
      // AppFlowy supportedLocales含中文
      supportedLocales: AppFlowyEditorLocalizations.delegate.supportedLocales,
    );
  }
}

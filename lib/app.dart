import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

part 'data/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _AppRoot(),
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

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isVertical = orientation == Orientation.portrait;
        return isVertical ? _VerticalRoot() : _HorizontalRoot();
      },
    );
  }
}

class _VerticalRoot extends StatelessWidget {
  const _VerticalRoot();

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(toolbarHeight: 0),
      // b
    );
  }
}

class _HorizontalRoot extends StatelessWidget {
  const _HorizontalRoot();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

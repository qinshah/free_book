import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:free_book/function/context_extension.dart';
import 'package:free_book/function/screen.dart';
import 'package:free_book/function/storage.dart';
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
  DateTime _lastBackPressed = DateTime(0);
  final _backDifference = const Duration(milliseconds: 1666);

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
          home: Builder(
            builder: (context) {
              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (_, __) async {
                  final now = DateTime.now();
                  if (now.difference(_lastBackPressed) < _backDifference) {
                    final rootLogic = context.read<RootLogic>();
                    final curDraftState =
                        rootLogic.curState.draftLogic?.curState;
                    if (curDraftState?.saved == false) {
                      final draftPath = Storage.i.draftPath;
                      rootLogic.curState.draftLogic?.saveToFile(
                        draftPath,
                        rootLogic.curState.draftState!.document,
                      );
                      await context.showToast('正在保存草稿更改');
                      // ignore: use_build_context_synchronously
                      await context.showSuccessToast('草稿更改已保存，即将推出');
                    }
                    kDebugMode
                        // ignore: use_build_context_synchronously
                        ? context.showToast('模拟退出应用')
                        : SystemNavigator.pop();
                  } else {
                    _lastBackPressed = now;
                    context.showToast('再按一次返回退出', duration: _backDifference);
                  }
                },
                child: RootView(),
              );
            },
          ),
        ),
      ),
    );
  }
}

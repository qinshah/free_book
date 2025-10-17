part of '../main.dart';

final _primaryMColor = Colors.teal;

ThemeData _getThemeData() {
  final backgroundColor = Colors.grey.shade200;
  return ThemeData(
    primaryColor: _primaryMColor,
    primarySwatch: _primaryMColor,
    // 禁用滑动内容后appbar变色
    appBarTheme: AppBarTheme(
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor, //沉浸式
    ),
    scaffoldBackgroundColor: backgroundColor,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 227, 228, 219),
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: _primaryMColor),
  );
}

ThemeData _getDarkThemeData() {
  final backgroundColor = Colors.grey.shade700;
  return ThemeData(
    primaryColor: _primaryMColor,
    primarySwatch: _primaryMColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor, //沉浸式
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 79, 82, 86),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: _primaryMColor,
      brightness: Brightness.dark,
    ),
  );
}

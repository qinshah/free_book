part of '../main.dart';

final _primaryMColor = Colors.teal;

ThemeData _getThemeData() {
  return ThemeData(
    primaryColor: _primaryMColor,
    primarySwatch: _primaryMColor,
    appBarTheme: AppBarTheme(
      // 禁用滑动内容后appbar变色
      scrolledUnderElevation: 0,
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: _primaryMColor),
    // bottomNavigationBarTheme: BottomNavigationBarThemeData(
    // ),
  );
}

ThemeData _getDarkThemeData() {
  return ThemeData(
    primaryColor: _primaryMColor,
    primarySwatch: _primaryMColor,
    appBarTheme: AppBarTheme(
      // 禁用滑动内容后appbar变色
      scrolledUnderElevation: 0,
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: _primaryMColor,
      brightness: Brightness.dark,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey.shade700,
    ),
  );
}

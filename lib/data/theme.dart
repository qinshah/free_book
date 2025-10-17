part of '../main.dart';

final _primaryMColor =  Colors.teal;

ThemeData _getThemeData() {
  return ThemeData(
    primaryColor: _primaryMColor,
    primarySwatch: _primaryMColor,
    scaffoldBackgroundColor: Colors.grey.shade200,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 227, 228, 219),
    ),
    // 禁用滑动内容后appbar变色
    appBarTheme: AppBarTheme(scrolledUnderElevation: 0),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: _primaryMColor),
  );
}

ThemeData _getDarkThemeData() {
  return ThemeData(
    primaryColor: _primaryMColor,
    primarySwatch: _primaryMColor,
    scaffoldBackgroundColor: Colors.grey.shade700,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 79, 82, 86),
    ),
    appBarTheme: AppBarTheme(scrolledUnderElevation: 0),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: _primaryMColor,
      brightness: Brightness.dark,
    ),
  );
}

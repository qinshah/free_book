part of '../main.dart';

final _primaryMColor = Colors.teal;

ThemeData _getThemeData() {
  return ThemeData(
    primaryColor: _primaryMColor,
    primarySwatch: _primaryMColor,
    scaffoldBackgroundColor: Colors.grey.shade100,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: _primaryMColor),
    // bottomNavigationBarTheme: BottomNavigationBarThemeData(
    // ),
  );
}

ThemeData _getDarkThemeData() {
  return ThemeData(
    primaryColor: _primaryMColor,
    primarySwatch: _primaryMColor,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: _primaryMColor,
      brightness: Brightness.dark,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey.shade700,
    ),
  );
}

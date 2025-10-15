part of '../main.dart';

final _primarySwatch = Colors.teal;

ThemeData _getThemeData() {
  return ThemeData(
    primaryColor: _primarySwatch,
    primarySwatch: _primarySwatch,
    scaffoldBackgroundColor: Colors.grey.shade100,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: _primarySwatch),
  );
}

ThemeData _getDarkThemeData() {
  return ThemeData(
    primaryColor: _primarySwatch,
    primarySwatch: _primarySwatch,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: _primarySwatch,
      brightness: Brightness.dark,
    ),
  );
}

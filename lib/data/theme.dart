part of '../main.dart';

final _primarySwatch = Colors.teal;

ThemeData _getThemeData() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade100,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: _primarySwatch),
  );
}

ThemeData _getDarkThemeData() {
  return ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: _primarySwatch,
      brightness: Brightness.dark,
    ),
  );
}

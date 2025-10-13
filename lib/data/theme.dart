part of '../app.dart';

final _primarySwatch = Colors.teal;

ThemeData _getThemeData() {
  return ThemeData(
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

import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness b) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0E9F8E),
    brightness: b,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    appBarTheme: const AppBarTheme(centerTitle: false),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
  );
}

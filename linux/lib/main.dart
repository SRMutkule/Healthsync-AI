import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/health_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/main_shell.dart';
import 'utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final profile = ProfileProvider();
  await profile.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: profile),
        ChangeNotifierProvider(create: (_) => HealthProvider()..start()),
      ],
      child: const HealthSyncApp(),
    ),
  );
}

class HealthSyncApp extends StatelessWidget {
  const HealthSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.select<ProfileProvider, bool>((p) => p.darkMode);
    return MaterialApp(
      title: 'HealthSync AI',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: const MainShell(),
    );
  }
}

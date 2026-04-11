import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/tasks/presentation/screens/home_screen.dart';


class SmartRemindApp extends ConsumerWidget {
  const SmartRemindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'SmartRemind',
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

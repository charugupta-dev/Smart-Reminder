import 'package:flutter/material.dart';
import '../widgets/task_list.dart';
import '../widgets/task_input.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

/// Desktop-optimized home screen: used as the content pane in a wide two-pane layout.
/// Features more spacious padding and layout for larger screens.
class DesktopHomeScreen extends StatelessWidget {
  const DesktopHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'My Tasks',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded),
                      color: AppColors.textPrimary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // ── Task List ──
              const Expanded(child: TaskList()),
              // ── Bottom Input ──
              const TaskInput(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/task_list.dart';
import '../widgets/task_input.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

/// Tablet-optimized home screen: used as the main content pane in a two-pane layout.
/// The sidebar is handled by the parent shell, this is just the content area.
class TabletHomeScreen extends StatelessWidget {
  const TabletHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: Column(
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 16, 8),
            child: Row(
              children: [
                Text(
                  'My Tasks',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
    );
  }
}

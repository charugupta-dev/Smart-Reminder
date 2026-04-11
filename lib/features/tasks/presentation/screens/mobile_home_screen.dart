import 'package:flutter/material.dart';
import '../widgets/task_list.dart';
import '../widgets/task_input.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

/// Mobile-optimized home screen: full-screen list with bottom input bar.
class MobileHomeScreen extends StatelessWidget {
  const MobileHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── App Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'SmartRemind',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
    );
  }
}

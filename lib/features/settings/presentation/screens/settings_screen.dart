import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/shortcut_provider.dart';
import '../widgets/shortcut_form_dialog.dart';
import '../widgets/app_usage_alerts_section.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../tasks/presentation/widgets/task_tile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_icons.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortcutsAsync = ref.watch(shortcutListProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Shortcuts section
          Text('Shortcuts', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          shortcutsAsync.when(
            data: (shortcuts) {
              if (shortcuts.isEmpty) {
                return const Text('No shortcuts configured.');
              }
              return Material(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: shortcuts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final shortcut = entry.value;
                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            AppIcons.getIcon(shortcut.iconKey),
                            color: Color(shortcut.colorValue),
                            size: 24,
                          ),
                          title: Text(
                            shortcut.categoryName,
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Prefix: "${shortcut.prefix} -"',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: AppColors.error.withOpacity(0.8)),
                            onPressed: () {
                              ref.read(shortcutListProvider.notifier).delete(shortcut.id);
                            },
                          ),
                        ),
                        if (index < shortcuts.length - 1)
                          const Divider(color: AppColors.borderGlass, height: 1),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Text('Error: $err'),
          ),

          const SizedBox(height: 32),
          // App Usage Alerts section
          const AppUsageAlertsSection(),
          const SizedBox(height: 32),

          // Completed Tasks section
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text('Completed Tasks', style: Theme.of(context).textTheme.titleLarge),
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final completedAsync = ref.watch(completedTasksProvider);
                    return completedAsync.when(
                      data: (tasks) {
                        if (tasks.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No completed tasks.'),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return TaskTile(
                              task: task,
                              categoryColor: AppColors.textTertiary,
                              showCategory: true,
                              onToggle: () {
                                ref.read(pendingTasksProvider.notifier).toggleComplete(task.id);
                              },
                              onDelete: () {
                                ref.read(pendingTasksProvider.notifier).deleteTask(task.id);
                              },
                            );
                          },
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (err, st) => Text('Error: $err'),
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const ShortcutFormDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Shortcut'),
      ),
    );
  }
}

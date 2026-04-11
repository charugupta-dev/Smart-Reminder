import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../../../settings/presentation/providers/shortcut_provider.dart';
import '../../../../core/constants/defaults.dart';
import '../../../../core/theme/app_colors.dart';
import 'category_header.dart';
import 'task_tile.dart';

/// Displays all pending tasks grouped by category with drag-to-reorder support.
class TaskList extends ConsumerWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(groupedPendingTasksProvider);
    final shortcuts = ref.watch(shortcutListProvider).valueOrNull ?? [];

    if (grouped.isEmpty) {
      return _buildEmptyState(context);
    }

    // Build category order: "Inbox" first, then alphabetical.
    final categoryNames =
        grouped.keys.toList()..sort((a, b) {
          if (a == Defaults.inboxCategoryName) return 1;
          if (b == Defaults.inboxCategoryName) return -1;
          return a.compareTo(b);
        });

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120, top: 8),
      itemCount: categoryNames.length,
      itemBuilder: (context, sectionIndex) {
        final categoryName = categoryNames[sectionIndex];
        final tasks = grouped[categoryName]!;

        // Find the shortcut for color/icon.
        final shortcut = shortcuts.where((s) => s.categoryName == categoryName);
        final colorValue =
            shortcut.isNotEmpty
                ? shortcut.first.colorValue
                : AppColors.textSecondary.value;
        final iconKey = shortcut.isNotEmpty ? shortcut.first.iconKey : 'inbox';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryHeader(
              categoryName: categoryName,
              colorValue: colorValue,
              iconKey: iconKey,
              taskCount: tasks.length,
            ),
            // Reorderable list within this category.
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: tasks.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;
                ref
                    .read(pendingTasksProvider.notifier)
                    .reorderTasks(categoryName, oldIndex, newIndex);
              },
              itemBuilder: (context, taskIndex) {
                final task = tasks[taskIndex];
                return ReorderableDelayedDragStartListener(
                  key: ValueKey(task.id),
                  index: taskIndex,
                  child: TaskTile(
                    task: task,
                    categoryColor: Color(colorValue),
                    onToggle: () {
                      ref
                          .read(pendingTasksProvider.notifier)
                          .toggleComplete(task.id);
                    },
                    onDelete: () {
                      ref
                          .read(pendingTasksProvider.notifier)
                          .deleteTask(task.id);
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No tasks yet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Type a task below to get started.\nUse shortcuts like "K - Buy milk" to auto-categorize!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

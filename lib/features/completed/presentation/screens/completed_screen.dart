import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../tasks/presentation/widgets/task_tile.dart';
import '../../../../core/theme/app_colors.dart';

class CompletedScreen extends ConsumerWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedAsync = ref.watch(completedTasksProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: const Text('Completed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: () {
              ref.read(pendingTasksProvider.notifier).clearCompleted();
            },
            tooltip: 'Clear completed',
          ),
        ],
      ),
      body: completedAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Text('No completed tasks.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

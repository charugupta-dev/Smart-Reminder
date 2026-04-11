import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import '../../../../core/theme/app_colors.dart';

class TaskEditDialog extends ConsumerStatefulWidget {
  final TaskEntity task;

  const TaskEditDialog({super.key, required this.task});

  @override
  ConsumerState<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends ConsumerState<TaskEditDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.title);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      title: const Text('Edit Task'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Task Title'),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('Save', style: TextStyle(color: AppColors.accentPrimary)),
        ),
      ],
    );
  }

  void _save() {
    final newTitle = _controller.text.trim();
    if (newTitle.isNotEmpty && newTitle != widget.task.title) {
      ref.read(pendingTasksProvider.notifier).updateTaskTitle(widget.task.id, newTitle);
    }
    Navigator.pop(context);
  }
}

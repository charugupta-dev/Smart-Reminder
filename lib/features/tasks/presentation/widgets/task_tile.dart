import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// A single task row with checkbox, swipe-to-complete (right), and swipe-to-delete (left).
/// Supports inline editing when tapped.
class TaskTile extends ConsumerStatefulWidget {
  final TaskEntity task;
  final Color categoryColor;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final bool showCategory;

  const TaskTile({
    super.key,
    required this.task,
    required this.categoryColor,
    required this.onToggle,
    required this.onDelete,
    this.showCategory = false,
  });

  @override
  ConsumerState<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends ConsumerState<TaskTile> {
  bool _isEditing = false;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.title);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _saveEdit();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    if (widget.task.isCompleted) return; // Don't edit completed tasks
    setState(() {
      _isEditing = true;
      _controller.text = widget.task.title;
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _saveEdit() {
    if (!mounted) return;
    final newTitle = _controller.text.trim();
    if (newTitle.isNotEmpty && newTitle != widget.task.title) {
      ref.read(pendingTasksProvider.notifier).updateTaskTitle(widget.task.id, newTitle);
    } else {
      // Revert if empty
      _controller.text = widget.task.title;
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.task.id),
      direction: widget.task.isCompleted ? DismissDirection.endToStart : DismissDirection.horizontal,
      background: widget.task.isCompleted ? const SizedBox() : _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        color: AppColors.success,
        icon: Icons.check_rounded,
        label: 'Complete',
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        color: AppColors.error,
        icon: Icons.delete_outline_rounded,
        label: 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (!widget.task.isCompleted) {
            widget.onToggle();
          }
          return false;
        } else {
          return true;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          widget.onDelete();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: _isEditing 
            ? Border.all(color: AppColors.accentPrimary, width: 1.0) 
            : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (widget.task.isCompleted) {
                widget.onToggle();
              } else {
                _startEditing();
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  _buildCheckbox(context),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isEditing
                            ? TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                style: Theme.of(context).textTheme.bodyLarge,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _saveEdit(),
                              )
                            : Text(
                                widget.task.title,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      decoration: widget.task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: widget.task.isCompleted
                                          ? AppColors.textTertiary
                                          : AppColors.textPrimary,
                                    ),
                              ),
                        if (widget.showCategory && !_isEditing) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.task.categoryName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: widget.categoryColor,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return GestureDetector(
      onTap: widget.onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: widget.task.isCompleted ? widget.categoryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: widget.task.isCompleted ? widget.categoryColor : AppColors.textTertiary,
            width: 1.5,
          ),
        ),
        child: widget.task.isCompleted
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerRight) ...[
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(icon, color: color, size: 22),
          if (alignment == Alignment.centerLeft) ...[
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

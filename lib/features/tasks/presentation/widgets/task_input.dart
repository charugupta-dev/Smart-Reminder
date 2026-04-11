import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../../../settings/presentation/providers/shortcut_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/liquid_glass.dart';

/// Persistent input bar fixed at the bottom of the screen.
/// Parses shortcuts on submit and adds tasks.
class TaskInput extends ConsumerStatefulWidget {
  const TaskInput({super.key});

  @override
  ConsumerState<TaskInput> createState() => _TaskInputState();
}

class _TaskInputState extends ConsumerState<TaskInput>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _animController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Trigger press animation.
    _animController.forward().then((_) => _animController.reverse());

    ref.read(pendingTasksProvider.notifier).addTask(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = ref.watch(shortcutListProvider).valueOrNull ?? [];
    final hintPrefixes = shortcuts
        .take(3)
        .map((s) => '"${s.prefix} -"')
        .join(', ');
    final hintText =
        shortcuts.isNotEmpty
            ? 'Add a task... (try $hintPrefixes)'
            : 'Add a task...';

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
              top: BorderSide(color: AppColors.borderGlass, width: 0.5),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12 + MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            children: [
              // Text input field.
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onSubmitted: (_) => _submit(),
                    textInputAction: TextInputAction.send,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 14, right: 4),
                        child: Icon(
                          Icons.add_rounded,
                          color: AppColors.textTertiary,
                          size: 22,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Send button.
              ScaleTransition(
                scale: _scaleAnim,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: _hasText ? AppColors.accentGradient : null,
                    color: _hasText ? null : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _hasText ? _submit : null,
                      borderRadius: BorderRadius.circular(14),
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        color: _hasText ? Colors.white : AppColors.textTertiary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

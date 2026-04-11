import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_icons.dart';

/// Section header for a category group in the task list.
class CategoryHeader extends StatelessWidget {
  final String categoryName;
  final int colorValue;
  final String iconKey;
  final int taskCount;

  const CategoryHeader({
    super.key,
    required this.categoryName,
    required this.colorValue,
    required this.iconKey,
    required this.taskCount,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          // Category icon.
          Icon(
            AppIcons.getIcon(iconKey),
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          // Category name.
          Text(
            categoryName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
          ),
        ],
      ),
    );
  }
}

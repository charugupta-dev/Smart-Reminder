import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shortcut_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_icons.dart';

class ShortcutFormDialog extends ConsumerStatefulWidget {
  const ShortcutFormDialog({super.key});

  @override
  ConsumerState<ShortcutFormDialog> createState() => _ShortcutFormDialogState();
}

class _ShortcutFormDialogState extends ConsumerState<ShortcutFormDialog> {
  final _prefixController = TextEditingController();
  final _titleController = TextEditingController();
  String _selectedIconKey = AppIcons.iconKeys.first;
  Color? _selectedColor;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _prefixController.addListener(() {
      if (_errorMessage != null) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _save() async {
    final prefix = _prefixController.text.trim();
    final title = _titleController.text.trim();

    if (prefix.isNotEmpty && title.isNotEmpty) {
      final color = _selectedColor?.value ?? AppColors.categoryPresets.first.value;

      final success = await ref.read(shortcutListProvider.notifier).add(
            prefix: prefix,
            categoryName: title,
            colorValue: color,
            iconKey: _selectedIconKey,
          );

      if (mounted) {
        if (!success) {
          setState(() {
            _errorMessage = 'Prefix is already taken. Try another.';
          });
        } else {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      title: const Text('Add Shortcut'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Category Title (e.g., Kitchen)',
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Text('Prefix', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _prefixController,
              decoration: InputDecoration(
                hintText: 'Prefix (e.g., K)',
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            const SizedBox(height: 24),
            Text('Color', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppColors.categoryPresets.map((color) {
                final isSelected = _selectedColor == null 
                    ? color.value == AppColors.categoryPresets.first.value
                    : color.value == _selectedColor!.value;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 2.5) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Icon', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppIcons.iconKeys.map((key) {
                final isSelected = key == _selectedIconKey;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIconKey = key;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      border: Border.all(
                        color: isSelected ? AppColors.accentPrimary : Colors.transparent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      AppIcons.getIcon(key),
                      color: isSelected ? AppColors.accentPrimary : AppColors.textTertiary,
                      size: 24,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('Add', style: TextStyle(color: AppColors.accentPrimary)),
        ),
      ],
    );
  }
}

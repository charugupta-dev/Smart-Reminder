import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/liquid_glass.dart';

/// Navigation item for the sidebar.
class SidebarItem {
  final IconData icon;
  final String label;
  final int index;

  const SidebarItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}

/// Liquid Glass sidebar for desktop and tablet layouts.
class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isCompact;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCompact = false,
  });

  static const List<SidebarItem> items = [
    SidebarItem(icon: Icons.inbox_rounded, label: 'Tasks', index: 0),
    SidebarItem(icon: Icons.check_circle_outline_rounded, label: 'Completed', index: 1),
    SidebarItem(icon: Icons.tune_rounded, label: 'Settings', index: 2),
  ];

  @override
  Widget build(BuildContext context) {
    final width = isCompact ? 72.0 : 240.0;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withOpacity(0.7),
            border: Border(
              right: BorderSide(
                color: AppColors.borderGlass,
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // ── App Title ──
              if (!isCompact) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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
                    ],
                  ),
                ),
                const Divider(indent: 20, endIndent: 20),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
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
                ),
                const Divider(indent: 12, endIndent: 12),
              ],
              const SizedBox(height: 8),
              // ── Navigation Items ──
              ...items.map((item) => _buildNavItem(context, item)),
              const Spacer(),
              // ── Version ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  isCompact ? 'v1' : 'v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, SidebarItem item) {
    final isSelected = selectedIndex == item.index;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemSelected(item.index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 0 : 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentPrimary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: AppColors.accentPrimary.withOpacity(0.3),
                      width: 0.5,
                    )
                  : null,
            ),
            child: isCompact
                ? Center(
                    child: Icon(
                      item.icon,
                      color: isSelected
                          ? AppColors.accentPrimary
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        item.icon,
                        color: isSelected
                            ? AppColors.accentPrimary
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isSelected
                                  ? AppColors.accentPrimary
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

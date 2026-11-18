import 'package:material_ui/material_ui.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class CategoryBadge extends StatelessWidget {
  final String categoryName;
  final String? iconName;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryBadge({
    super.key,
    required this.categoryName,
    this.iconName,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = iconName != null
        ? AppConstants.getCategoryIcon(iconName!)
        : AppConstants.getCategoryIcon(categoryName);

    final backgroundColor = isSelected
        ? AppColors.primary
        : AppColors.primaryContainer.withValues(alpha: 0.6);
    final foregroundColor = isSelected ? Colors.white : AppColors.primary;

    final badgeWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            categoryName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: badgeWidget,
      );
    }

    return badgeWidget;
  }
}

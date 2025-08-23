import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';

// Helper function for building premium notification tiles
Widget buildNotificationTile({
  required BuildContext context,
  required WidgetRef ref,
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  required bool isEnabled,
  required Function(bool) onChanged,
  required selectedCampus,
}) {
  final theme = Theme.of(context);
  
  return Container(
    decoration: const BoxDecoration(
      color: Colors.transparent,
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.3,
          ),
        ),
      ),
      trailing: Transform.scale(
        scale: 0.85,
        child: Switch.adaptive(
          value: isEnabled,
          onChanged: onChanged,
          activeColor: getCampusColorHelper(selectedCampus.id),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return getCampusColorHelper(selectedCampus.id).withValues(alpha: 0.3);
            }
            return AppColors.gray300;
          }),
        ),
      ),
    ),
  );
}

// Helper function for building premium dividers
Widget buildDivider() {
  return Container(
    margin: const EdgeInsets.only(left: 88),
    height: 1,
    color: AppColors.outline.withValues(alpha: 0.2),
  );
}

// Helper function for campus colors
Color getCampusColorHelper(String campusId) {
  switch (campusId) {
    case 'oslo':
      return AppColors.defaultBlue;
    case 'bergen':
      return AppColors.green9;
    case 'trondheim':
      return AppColors.purple9;
    case 'stavanger':
      return AppColors.orange9;
    default:
      return AppColors.gray400;
  }
}

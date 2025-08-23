import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../generated/l10n/app_localizations.dart';

class PrivacyPromptDialog extends StatelessWidget {
  final VoidCallback onAcceptPublic;
  final VoidCallback onChoosePrivate;

  const PrivacyPromptDialog({
    super.key,
    required this.onAcceptPublic,
    required this.onChoosePrivate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: AppColors.defaultBlue,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.chatPrivacy,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.privacyInformation,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 20),

          // Public Option
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.subtleBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.defaultBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.public, color: AppColors.defaultBlue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.publicProfile,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.defaultBlue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.publicProfileBullets,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurface,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Private Option
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: AppColors.gray600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.privateProfile,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.privateProfileBullets,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            l10n.notificationPreferences,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onChoosePrivate,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.gray400),
                  foregroundColor: AppColors.gray600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(l10n.keepPrivate),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onAcceptPublic,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.defaultBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(l10n.makePublic),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

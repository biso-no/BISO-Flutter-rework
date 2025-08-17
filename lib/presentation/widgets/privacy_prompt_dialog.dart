import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

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
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: AppColors.defaultBlue,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Chat Privacy Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose how others can find and contact you:',
            style: TextStyle(
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
              border: Border.all(color: AppColors.defaultBlue.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.public,
                      color: AppColors.defaultBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Public Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.defaultBlue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Others can find you in search\n'
                  '• Students can start conversations with you\n'
                  '• You appear in recent contacts',
                  style: TextStyle(
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
                    const Text(
                      'Private Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Others cannot find you in search\n'
                  '• You can still message others\n'
                  '• Only you can start conversations',
                  style: TextStyle(
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
            'You can change this setting anytime in your profile.',
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
                child: const Text('Keep Private'),
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
                child: const Text('Make Public'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/campus/campus_provider.dart';
import '../../../providers/notification/notification_provider.dart';
import 'settings_screen.dart';
import '../../../generated/l10n/app_localizations.dart';

class ChatSettingsTab extends ConsumerWidget {
  const ChatSettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final settingsState = ref.watch(appSettingsProvider);
    final selectedCampus = ref.watch(selectedCampusProvider);
    final notificationPrefs = ref.watch(notificationPreferencesProvider);
    final notificationStatus = ref.watch(notificationStatusProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.chat,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.strongBlue,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                // Chat notifications with permission status
                notificationPrefs.when(
                  data: (prefs) => SwitchListTile(
                    secondary: const Icon(
                      Icons.notifications,
                      color: AppColors.onSurfaceVariant,
                    ),
                    title: Text(l10n.chatNotifications),
                    subtitle: notificationStatus.when(
                      data: (enabled) => Text(
                        enabled
                            ? l10n.receiveMessageNotifications
                            : l10n.error,
                      ),
                      loading: () => Text(l10n.checkingPermissions),
                      error: (_, _) => Text(l10n.receiveMessageNotifications),
                    ),
                    value: prefs['chat_notifications'] ?? true,
                    onChanged: notificationStatus.when(
                      data: (systemEnabled) => systemEnabled
                          ? (value) async {
                              try {
                                await ref
                                    .read(
                                      notificationPreferencesProvider.notifier,
                                    )
                                    .updateChatNotifications(value);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.somethingWentWrong),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            }
                          : (value) async {
                              // Request permissions first
                              final service = ref.read(
                                notificationServiceProvider,
                              );
                              final granted = await service.requestPermission();
                              if (granted && value) {
                                await ref
                                    .read(
                                      notificationPreferencesProvider.notifier,
                                    )
                                    .updateChatNotifications(true);
                                // Refresh permission status
                                ref.invalidate(notificationStatusProvider);
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.error),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            },
                      loading: () => null,
                      error: (_, _) => null,
                    ),
                    activeColor: _getCampusColor(selectedCampus.id),
                  ),
                  loading: () => ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text(l10n.loadingNotificationSettings),
                  ),
                  error: (error, _) => ListTile(
                    leading: const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                    ),
                    title: Text(l10n.errorLoadingNotificationSettings),
                    subtitle: Text(error.toString()),
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.vibration,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(l10n.vibration),
                  subtitle: Text(l10n.vibrationDescription),
                  value: settingsState.notifications['chat_vibration'] ?? true,
                  onChanged: (value) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setNotification('chat_vibration', value);
                  },
                  activeColor: _getCampusColor(selectedCampus.id),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.volume_up,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(l10n.sound),
                  subtitle: Text(l10n.soundDescription),
                  value: settingsState.notifications['chat_sound'] ?? true,
                  onChanged: (value) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setNotification('chat_sound', value);
                  },
                  activeColor: _getCampusColor(selectedCampus.id),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            l10n.chat,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.strongBlue,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(
                    Icons.visibility,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(l10n.readReceipts),
                  subtitle: Text(l10n.readReceipts),
                  value: settingsState.notifications['read_receipts'] ?? true,
                  onChanged: (value) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setNotification('read_receipts', value);
                  },
                  activeColor: _getCampusColor(selectedCampus.id),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.edit,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(l10n.typingIndicators),
                  subtitle: Text(l10n.typingIndicators),
                  value:
                      settingsState.notifications['typing_indicators'] ?? true,
                  onChanged: (value) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setNotification('typing_indicators', value);
                  },
                  activeColor: _getCampusColor(selectedCampus.id),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.access_time,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(l10n.lastSeen),
                  subtitle: Text(l10n.lastSeenDescription),
                  value: settingsState.notifications['last_seen'] ?? true,
                  onChanged: (value) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setNotification('last_seen', value);
                  },
                  activeColor: _getCampusColor(selectedCampus.id),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            l10n.chat,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.strongBlue,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.auto_delete,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(l10n.autoDeleteMessages),
                  subtitle: Text(l10n.autoDeleteMessagesDescription),
                  trailing: Text(l10n.never),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.autoDeleteOptionsComingSoon)),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.download,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(l10n.autoDownloadMedia),
                  subtitle: Text(l10n.autoDownloadMedia),
                  trailing: Text(l10n.wifiOnly),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.autoDownloadOptionsComingSoon)),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.subtleBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.defaultBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.chat,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.defaultBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCampusColor(String campusId) {
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
}

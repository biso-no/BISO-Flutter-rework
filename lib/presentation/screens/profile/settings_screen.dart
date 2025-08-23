import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../providers/campus/campus_provider.dart';
import '../../../providers/privacy/privacy_provider.dart';
import '../../../data/services/validator_service.dart';
import 'settings_screen_chat_tab.dart';
import '../../../generated/l10n/app_localizations.dart';

// Settings providers
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>((ref) {
      return AppSettingsNotifier();
    });

// Controller permissions provider
final controllerPermissionsProvider = FutureProvider<bool>((ref) async {
  final validatorService = ValidatorService();
  return await validatorService.hasControllerPermissions();
});

class AppSettingsState {
  final bool darkMode;
  final String language;
  final Map<String, bool> notifications;
  final bool isLoading;

  const AppSettingsState({
    this.darkMode = false,
    this.language = 'en',
    this.notifications = const {
      'events': true,
      'products': true,
      'jobs': true,
      'expenses': false,
      'chat': true,
    },
    this.isLoading = false,
  });

  AppSettingsState copyWith({
    bool? darkMode,
    String? language,
    Map<String, bool>? notifications,
    bool? isLoading,
  }) {
    return AppSettingsState(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  AppSettingsNotifier() : super(const AppSettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();

      final darkMode = prefs.getBool('dark_mode') ?? false;
      final language = prefs.getString('language') ?? 'en';

      // Load notification preferences
      final notifications = Map<String, bool>.from(state.notifications);
      for (final key in notifications.keys) {
        notifications[key] =
            prefs.getBool('notification_$key') ?? notifications[key]!;
      }

      state = state.copyWith(
        darkMode: darkMode,
        language: language,
        notifications: notifications,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', enabled);
    state = state.copyWith(darkMode: enabled);
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    state = state.copyWith(language: language);
  }

  Future<void> setNotification(String key, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_$key', enabled);

    final updatedNotifications = Map<String, bool>.from(state.notifications);
    updatedNotifications[key] = enabled;
    state = state.copyWith(notifications: updatedNotifications);
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const SettingsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5, // Added Privacy and Chat tabs
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCampus = ref.watch(selectedCampusProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _getCampusColor(selectedCampus.id),
          labelColor: _getCampusColor(selectedCampus.id),
          unselectedLabelColor: AppColors.onSurfaceVariant,
          tabs: [
            Tab(text: l10n.general),
            Tab(text: l10n.notifications),
            Tab(text: l10n.privacy),
            Tab(text: l10n.chat),
            Tab(text: l10n.language),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GeneralSettingsTab(),
          _NotificationSettingsTab(),
          _PrivacySettingsTab(),
          ChatSettingsTab(),
          _LanguageSettingsTab(),
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

class _GeneralSettingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(appSettingsProvider);
    final authState = ref.watch(authStateProvider);
    final selectedCampus = ref.watch(selectedCampusProvider);
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Section
          Text(
            l10n.account,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.strongBlue,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCampusColor(
                      selectedCampus.id,
                    ).withValues(alpha: 0.1),
                    child: Text(
                      authState.user?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        color: _getCampusColor(selectedCampus.id),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(authState.user?.name ?? l10n.unknownUser),
                  subtitle: Text(authState.user?.email ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate back to profile
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: Text(l10n.darkMode),
                  subtitle: Text(l10n.darkModeDescription),
                  value: settingsState.darkMode,
                  onChanged: (value) {
                    ref.read(appSettingsProvider.notifier).setDarkMode(value);
                  },
                  activeColor: _getCampusColor(selectedCampus.id),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Campus Section
          Text(
            l10n.campus,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.strongBlue,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCampusColor(selectedCampus.id),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.location_city, color: Colors.white),
              ),
              title: Text(l10n.currentCampus),
              subtitle: Text('BI ${selectedCampus.name}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.useCampusSwitcherHint)),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Controller Mode Section (only show if user has permissions)
          ref
              .watch(controllerPermissionsProvider)
              .when(
                data: (hasPermissions) => hasPermissions
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.validatorMode,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.strongBlue,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getCampusColor(selectedCampus.id),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.qr_code_scanner,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(l10n.openValidatorMode),
                              subtitle: Text(l10n.scanStudentQRCodes),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                context.push('/controller-mode');
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),

          // Data Section
          Text(
            l10n.dataAndStorage,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                    Icons.cached,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(l10n.clearCache),
                  subtitle: Text(l10n.clearCacheDescription),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showClearCacheDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.download,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(l10n.offlineData),
                  subtitle: Text(l10n.offlineDataDescription),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.offlineComingSoon)),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          Text(
            l10n.about,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                    Icons.info_outline,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(l10n.appVersion),
                  subtitle: const Text('1.0.0 (Build 1)'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(l10n.privacyPolicy),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    launchUrl(Uri.parse('https://biso.no/privacy'));
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.description_outlined,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(l10n.termsOfService),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    launchUrl(Uri.parse('https://biso.no/terms'));
                  },
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

  void _showClearCacheDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCache),
        content: Text(l10n.clearCacheDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.cacheClearedSuccessfully)),
              );
            },
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }
}

class _NotificationSettingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsState = ref.watch(appSettingsProvider);
    final selectedCampus = ref.watch(selectedCampusProvider);
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pushNotifications,
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
                    Icons.event,
                    color: AppColors.accentBlue,
                  ),
                  title: Text(l10n.eventsNotifications),
                  subtitle: Text(l10n.eventsNotificationsDescription),
                  value: settingsState.notifications['events'] ?? true,
                  onChanged: (value) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setNotification('events', value);
                  },
                  activeColor: _getCampusColor(selectedCampus.id),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.shopping_bag,
                    color: AppColors.green9,
                  ),
                  title: Text(l10n.marketplaceNotifications),
                  subtitle: Text(l10n.marketplaceNewItemsDeals),
                  value: settingsState.notifications['products'] ?? true,
                  onChanged: (value) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setNotification('products', value);
                  },
                  activeColor: _getCampusColor(selectedCampus.id),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.work, color: AppColors.purple9),
                  title: Text(l10n.jobOpportunities),
                  subtitle: Text(l10n.jobOpportunitiesDescription),
                  value: settingsState.notifications['jobs'] ?? true,
                  onChanged: (value) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setNotification('jobs', value);
                  },
                  activeColor: _getCampusColor(selectedCampus.id),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.receipt,
                    color: AppColors.orange9,
                  ),
                  title: Text(l10n.expensesNotifications),
                  subtitle: Text(l10n.expensesNotificationsDescription),
                  value: settingsState.notifications['expenses'] ?? false,
                  onChanged: (value) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setNotification('expenses', value);
                  },
                  activeColor: _getCampusColor(selectedCampus.id),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.chat,
                    color: AppColors.defaultBlue,
                  ),
                  title: Text(l10n.chatMessagesNotifications),
                  subtitle: Text(l10n.chatMessagesDescription),
                  value: settingsState.notifications['chat'] ?? true,
                  onChanged: (value) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setNotification('chat', value);
                  },
                  activeColor: _getCampusColor(selectedCampus.id),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            l10n.notificationSchedule,
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
                    Icons.schedule,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(l10n.quietHours),
                  subtitle: Text(l10n.muteNotificationsDuringSpecificHours),
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.quietHoursComingSoon)),
                      );
                    },
                    activeColor: _getCampusColor(selectedCampus.id),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.vibration,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(l10n.vibration),
                  subtitle: Text(l10n.vibrationDescription),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.vibrationSettingsComingSoon)),
                      );
                    },
                    activeColor: _getCampusColor(selectedCampus.id),
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

class _PrivacySettingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final selectedCampus = ref.watch(selectedCampusProvider);
    final l10n = AppLocalizations.of(context);

    if (authState.user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userId = authState.user!.id;
    final privacyStatusAsync = ref.watch(privacyStatusProvider(userId));
    final userPrivacyAsync = ref.watch(userPrivacyProvider(userId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.chatPrivacy,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.strongBlue,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                userPrivacyAsync.when(
                  data: (isPublic) => SwitchListTile(
                    secondary: Icon(
                      isPublic == true ? Icons.public : Icons.lock_outline,
                      color: isPublic == true
                          ? AppColors.green9
                          : AppColors.orange9,
                    ),
                    title: Text(l10n.publicProfile),
                    subtitle: Text(
                      isPublic == true
                          ? l10n.othersCanFindAndMessageYou
                          : l10n.othersCannotFindYouInSearch,
                    ),
                    value: isPublic == true,
                    onChanged: (value) async {
                      try {
                        final privacyNotifier = ref.read(
                          privacySettingProvider(userId).notifier,
                        );
                        await privacyNotifier.updatePrivacySetting(value);

                        // Refresh the privacy status
                        ref.invalidate(userPrivacyProvider(userId));
                        ref.invalidate(privacyStatusProvider(userId));

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(value
                                ? l10n.publicProfileCreated
                                : l10n.publicProfileRemoved),
                            backgroundColor: AppColors.defaultBlue,
                          ));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.failedToUpdatePrivacySetting(e.toString())),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    activeColor: _getCampusColor(selectedCampus.id),
                  ),
                  loading: () => const ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('Loading privacy settings...'),
                  ),
                  error: (error, stack) => ListTile(
                    leading: const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                    ),
                    title: Text(l10n.errorLoadingPrivacySettings),
                    subtitle: Text(error.toString()),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Privacy status display
          privacyStatusAsync.when(
            data: (status) => Container(
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
                      status,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.defaultBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),

          Text(
            l10n.privacyInformation,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.strongBlue,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.public, color: AppColors.green9, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.publicProfile,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.green9,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.publicProfileBullets, style: const TextStyle(height: 1.4)),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: AppColors.orange9,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.privateProfile,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.orange9,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.privateProfileBullets, style: const TextStyle(height: 1.4)),
                ],
              ),
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

class _LanguageSettingsTab extends ConsumerWidget {
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'no', 'name': 'Norwegian', 'nativeName': 'Norsk'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsState = ref.watch(appSettingsProvider);
    final selectedCampus = ref.watch(selectedCampusProvider);
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.appLanguage,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.strongBlue,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: _languages.map((language) {
                return RadioListTile<String>(
                  value: language['code']!,
                  groupValue: settingsState.language,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(appSettingsProvider.notifier).setLanguage(value);
                    }
                  },
                  title: Text(language['name']!),
                  subtitle: Text(language['nativeName']!),
                  activeColor: _getCampusColor(selectedCampus.id),
                );
              }).toList(),
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
                    l10n.languageChangeRestartNotice,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.defaultBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            l10n.regionalSettings,
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
                    Icons.schedule,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(l10n.dateFormat),
                  subtitle: Text(l10n.dateFormatValue),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.dateFormatOptionsComingSoon)),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.attach_money,
                    color: AppColors.onSurfaceVariant,
                  ),
                  title: Text(l10n.currency),
                  subtitle: Text(l10n.currencyValue),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.currencyAutoNokHint)),
                    );
                  },
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

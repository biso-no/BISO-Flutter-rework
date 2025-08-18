import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../providers/campus/campus_provider.dart';
import '../../../providers/privacy/privacy_provider.dart';
import '../../../data/services/validator_service.dart';
import 'settings_screen_chat_tab.dart';

// Settings providers
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettingsState>((ref) {
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
        notifications[key] = prefs.getBool('notification_$key') ?? notifications[key]!;
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

class _SettingsScreenState extends ConsumerState<SettingsScreen> with SingleTickerProviderStateMixin {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _getCampusColor(selectedCampus.id),
          labelColor: _getCampusColor(selectedCampus.id),
          unselectedLabelColor: AppColors.onSurfaceVariant,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Notifications'),
            Tab(text: 'Privacy'),
            Tab(text: 'Chat'),
            Tab(text: 'Language'),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Section
          Text(
            'Account',
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
                    backgroundColor: _getCampusColor(selectedCampus.id).withValues(alpha: 0.1),
                    child: Text(
                      authState.user?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        color: _getCampusColor(selectedCampus.id),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(authState.user?.name ?? 'User'),
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
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme throughout the app'),
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
            'Campus',
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
                child: Icon(
                  Icons.location_city,
                  color: Colors.white,
                ),
              ),
              title: Text('Current Campus'),
              subtitle: Text('BI ${selectedCampus.name}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Use the campus switcher on the home screen to change campus'),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Controller Mode Section (only show if user has permissions)
          ref.watch(controllerPermissionsProvider).when(
            data: (hasPermissions) => hasPermissions ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Validator Mode',
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
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                      ),
                    ),
                    title: const Text('Open Validator Mode'),
                    subtitle: const Text('Scan student QR codes to verify membership'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      context.push('/controller-mode');
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ) : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Data Section
          Text(
            'Data & Storage',
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
                  leading: const Icon(Icons.cached, color: AppColors.onSurfaceVariant),
                  title: const Text('Clear Cache'),
                  subtitle: const Text('Free up storage space'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showClearCacheDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download, color: AppColors.onSurfaceVariant),
                  title: const Text('Offline Data'),
                  subtitle: const Text('Manage downloaded content'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Offline data management coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          Text(
            'About',
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
                  leading: const Icon(Icons.info_outline, color: AppColors.onSurfaceVariant),
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0 (Build 1)'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.onSurfaceVariant),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Open privacy policy
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppColors.onSurfaceVariant),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Open terms of service
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached images and data. The app may take longer to load content after clearing cache.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Push Notifications',
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
                  secondary: const Icon(Icons.event, color: AppColors.accentBlue),
                  title: const Text('Events'),
                  subtitle: const Text('Get notified about new campus events'),
                  value: settingsState.notifications['events'] ?? true,
                  onChanged: (value) {
                    ref.read(appSettingsProvider.notifier).setNotification('events', value);
                  },
                  activeColor: _getCampusColor(selectedCampus.id),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.shopping_bag, color: AppColors.green9),
                  title: const Text('Marketplace'),
                  subtitle: const Text('New items and deals in the marketplace'),
                  value: settingsState.notifications['products'] ?? true,
                  onChanged: (value) {
                    ref.read(appSettingsProvider.notifier).setNotification('products', value);
                  },
                  activeColor: _getCampusColor(selectedCampus.id),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.work, color: AppColors.purple9),
                  title: const Text('Job Opportunities'),
                  subtitle: const Text('Volunteer and job opportunities'),
                  value: settingsState.notifications['jobs'] ?? true,
                  onChanged: (value) {
                    ref.read(appSettingsProvider.notifier).setNotification('jobs', value);
                  },
                  activeColor: _getCampusColor(selectedCampus.id),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.receipt, color: AppColors.orange9),
                  title: const Text('Expenses'),
                  subtitle: const Text('Expense reimbursement status updates'),
                  value: settingsState.notifications['expenses'] ?? false,
                  onChanged: (value) {
                    ref.read(appSettingsProvider.notifier).setNotification('expenses', value);
                  },
                  activeColor: _getCampusColor(selectedCampus.id),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.chat, color: AppColors.defaultBlue),
                  title: const Text('Chat Messages'),
                  subtitle: const Text('New messages in your chats'),
                  value: settingsState.notifications['chat'] ?? true,
                  onChanged: (value) {
                    ref.read(appSettingsProvider.notifier).setNotification('chat', value);
                  },
                  activeColor: _getCampusColor(selectedCampus.id),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Notification Schedule',
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
                  leading: const Icon(Icons.schedule, color: AppColors.onSurfaceVariant),
                  title: const Text('Quiet Hours'),
                  subtitle: const Text('Mute notifications during specific hours'),
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Quiet hours feature coming soon')),
                      );
                    },
                    activeColor: _getCampusColor(selectedCampus.id),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.vibration, color: AppColors.onSurfaceVariant),
                  title: const Text('Vibration'),
                  subtitle: const Text('Vibrate for notifications'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vibration settings coming soon')),
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
            'Chat Privacy',
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
                      color: isPublic == true ? AppColors.green9 : AppColors.orange9,
                    ),
                    title: const Text('Public Profile'),
                    subtitle: Text(
                      isPublic == true
                          ? 'Others can find and message you'
                          : 'Others cannot find you in search'
                    ),
                    value: isPublic == true,
                    onChanged: (value) async {
                      try {
                        final privacyNotifier = ref.read(privacySettingProvider(userId).notifier);
                        await privacyNotifier.updatePrivacySetting(value);
                        
                        // Refresh the privacy status
                        ref.invalidate(userPrivacyProvider(userId));
                        ref.invalidate(privacyStatusProvider(userId));
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value 
                                  ? 'Public profile created - others can find you in search'
                                  : 'Public profile removed - you won\'t appear in search',
                              ),
                              backgroundColor: AppColors.defaultBlue,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update privacy setting: $e'),
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
                    leading: const Icon(Icons.error_outline, color: AppColors.error),
                    title: const Text('Error loading privacy settings'),
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
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.defaultBlue,
                  ),
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
            'Privacy Information',
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
                      Icon(
                        Icons.public,
                        color: AppColors.green9,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Public Profile',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.green9,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Others can find you in user search\n'
                    '• Students can start conversations with you\n'
                    '• You appear in recent contacts\n'
                    '• You can still control who messages you',
                    style: TextStyle(height: 1.4),
                  ),
                  
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
                        'Private Profile',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.orange9,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Others cannot find you in search\n'
                    '• You can still message others\n'
                    '• Only you can start new conversations\n'
                    '• Existing conversations remain active',
                    style: TextStyle(height: 1.4),
                  ),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Language',
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
                const Icon(
                  Icons.info_outline,
                  color: AppColors.defaultBlue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Language changes will take effect after restarting the app.',
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
            'Regional Settings',
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
                  leading: const Icon(Icons.schedule, color: AppColors.onSurfaceVariant),
                  title: const Text('Date Format'),
                  subtitle: const Text('DD/MM/YYYY (Norwegian)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Date format options coming soon')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.attach_money, color: AppColors.onSurfaceVariant),
                  title: const Text('Currency'),
                  subtitle: const Text('NOK (Norwegian Krone)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Currency is automatically set to NOK for BI students')),
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
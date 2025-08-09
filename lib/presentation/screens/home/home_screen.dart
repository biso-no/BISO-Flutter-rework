import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../providers/campus/campus_provider.dart';
import '../../../presentation/widgets/campus_switcher.dart';
import '../explore/explore_screen.dart';
import '../chat/chat_list_screen.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  
  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authStateProvider);
    
    final pages = [
      _HomePage(navigateToTab: _navigateToTab),
      const ExploreScreen(),
      authState.isAuthenticated 
          ? const ChatListScreen()
          : _AuthRequiredPage(
              title: l10n.chat,
              description: 'Sign in to chat with students and organizations',
              icon: Icons.chat_bubble_outline,
            ),
      authState.isAuthenticated 
          ? const ProfileScreen()
          : _AuthRequiredPage(
              title: l10n.profile,
              description: 'Sign in to manage your profile and account',
              icon: Icons.person_outline,
              navigateToTab: _navigateToTab,
            ),
    ];
    
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.defaultBlue,
        unselectedItemColor: AppColors.onSurfaceVariant,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore_outlined),
            activeIcon: const Icon(Icons.explore),
            label: l10n.explore,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_outlined),
            activeIcon: const Icon(Icons.chat),
            label: l10n.chat,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outlined),
            activeIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}

class _HomePage extends ConsumerWidget {
  final Function(int) navigateToTab;
  
  const _HomePage({required this.navigateToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final campus = ref.watch(filterCampusProvider);
    final authState = ref.watch(authStateProvider);

    // Use a fallback approach for campus background images
    final campusBackgroundImage = _getCampusBackgroundImage(campus.id);

    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Campus Hero Section
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _getCampusColor(campus.id),
                      _getCampusColor(campus.id).withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getCampusColor(campus.id),
                              _getCampusColor(campus.id).withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                        child: ClipRRect(
                          child: Image.asset(
                            campusBackgroundImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to gradient background if image fails to load
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _getCampusColor(campus.id),
                                      _getCampusColor(campus.id).withValues(alpha: 0.6),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      bottom: 40,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'BISO ${campus.name}',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            campus.description,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              // Campus switcher in top right
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CampusSwitcher(onCampusChanged: () {
                  // Refresh campus-specific content
                }),
              ),
            ],
          ),

          // Campus stats and weather
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Weather
                      if (campus.weather != null) ...[
                        Column(
                          children: [
                            Text(
                              campus.weather!.icon,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${campus.weather!.temperature.toStringAsFixed(0)}°',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              campus.weather!.condition,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Container(
                          width: 1,
                          height: 60,
                          color: AppColors.outline,
                        ),
                        const SizedBox(width: 24),
                      ],
                      // Stats
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatColumn(
                              icon: Icons.people,
                              value: '${(campus.stats.studentCount / 1000).toStringAsFixed(1)}k',
                              label: 'Students',
                            ),
                            _StatColumn(
                              icon: Icons.event,
                              value: campus.stats.activeEvents.toString(),
                              label: 'Events',
                            ),
                            _StatColumn(
                              icon: Icons.work,
                              value: campus.stats.availableJobs.toString(),
                              label: 'Jobs',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore Campus',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _CategoryCard(
                          icon: Icons.event,
                          label: l10n.events,
                          color: AppColors.accentBlue,
                          onTap: () => context.go('/explore/events'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CategoryCard(
                          icon: Icons.shopping_bag,
                          label: l10n.marketplace,
                          color: AppColors.green9,
                          onTap: () => context.go('/explore/products'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _CategoryCard(
                          icon: Icons.work,
                          label: l10n.jobs,
                          color: AppColors.purple9,
                          onTap: () => context.go('/explore/volunteer'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CategoryCard(
                          icon: Icons.receipt,
                          label: l10n.expenses,
                          color: AppColors.orange9,
                          requiresAuth: true,
                          onTap: () {
                            if (!authState.isAuthenticated) {
                              _showAuthPrompt(context, 'Expenses');
                            } else {
                              context.go('/explore/expenses');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Recent Events Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Latest from ${campus.name}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => navigateToTab(1),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Sample events
                  Card(
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.subtleBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.event, color: AppColors.defaultBlue),
                      ),
                      title: const Text('New Student Welcome'),
                      subtitle: const Text('Today • 14:00 • Main Auditorium'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Card(
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.green9.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.shopping_bag, color: AppColors.green9),
                      ),
                      title: const Text('MacBook Pro 2021'),
                      subtitle: const Text('12,500 NOK • Posted 2 hours ago'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAuthPrompt(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign In Required'),
        content: Text('You need to sign in to access $feature functionality.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  String _getCampusBackgroundImage(String campusId) {
    // For debugging, let's try a hardcoded path first
    // Commented out debug print to avoid production warnings
    // print('Getting background image for campus: $campusId');
    
    // Map campus IDs to their corresponding image assets
    switch (campusId.toLowerCase()) {
      case 'oslo':
        return 'assets/images/campus/oslo.png';
      case 'bergen':
        return 'assets/images/campus/bergen.png';
      case 'trondheim':
        return 'assets/images/campus/trondheim.png';
      case 'stavanger':
        return 'assets/images/campus/stavanger.png';
      default:
        // Return a default image or the first available one
        return 'assets/images/campus/oslo.png';
    }
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

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool requiresAuth;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.requiresAuth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  if (requiresAuth)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.orange9,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.onSurfaceVariant,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AuthRequiredPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Function(int)? navigateToTab;

  const _AuthRequiredPage({
    required this.title,
    required this.description,
    required this.icon,
    this.navigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.subtleBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: AppColors.defaultBlue,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Sign In Required',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.defaultBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () {
                  // Navigate to explore tab to browse content
                  navigateToTab?.call(1);
                },
                child: const Text('Browse as Guest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
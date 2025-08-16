import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../providers/campus/campus_provider.dart';
import '../../../presentation/widgets/campus_switcher.dart';
import '../../../presentation/widgets/premium/wonderous_story_card.dart';
import '../../../presentation/widgets/premium/wonderous_campus_hero.dart';
import '../../../presentation/widgets/premium/large_event_hero.dart';
import '../../../providers/large_event/large_event_provider.dart';
import '../../../data/services/event_service.dart';
import '../../../data/services/job_service.dart';
import '../../../data/services/product_service.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/job_model.dart';
import '../../../data/models/product_model.dart';
import '../../../presentation/widgets/premium/wonderous_bottom_nav.dart';
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
      bottomNavigationBar: WonderousBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          WonderousNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: l10n.home,
          ),
          WonderousNavItem(
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore,
            label: l10n.explore,
          ),
          WonderousNavItem(
            icon: Icons.chat_outlined,
            activeIcon: Icons.chat,
            label: l10n.chat,
          ),
          WonderousNavItem(
            icon: Icons.person_outlined,
            activeIcon: Icons.person,
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

  // Local data providers
  static final _eventServiceProvider = Provider<EventService>((ref) => EventService());
  static final _productServiceProvider = Provider<ProductService>((ref) => ProductService());
  static final _jobServiceProvider = Provider<JobService>((ref) => JobService());

  static final _latestEventsProvider = FutureProvider.family<List<EventModel>, String>((ref, campusId) async {
    final service = ref.watch(_eventServiceProvider);
    return service.getWordPressEvents(campusId: campusId, limit: 10);
  });

  static final _latestProductsProvider = FutureProvider.family<List<ProductModel>, String>((ref, campusId) async {
    final service = ref.watch(_productServiceProvider);
    return service.getLatestProducts(campusId: campusId, limit: 10);
  });

  static final _latestJobsProvider = FutureProvider.family<List<JobModel>, String>((ref, campusId) async {
    final service = ref.watch(_jobServiceProvider);
    return service.getLatestJobs(campusId: campusId, limit: 10);
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final campus = ref.watch(filterCampusProvider);
    final authState = ref.watch(authStateProvider);

    final featuredEvent = ref.watch(featuredLargeEventProvider);
    final campusId = campus.id;

    final eventsAsync = ref.watch(_latestEventsProvider(campusId));
    final productsAsync = ref.watch(_latestProductsProvider(campusId));
    final jobsAsync = ref.watch(_latestJobsProvider(campusId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Override hero with Large Event if active for campus
          if (featuredEvent != null)
            LargeEventHero(event: featuredEvent, expandedHeight: 350)
          else
            WonderousCampusHero(
              campus: campus,
              expandedHeight: 350,
              onCampusTap: () {
                // Show campus switcher
              },
              trailing: CampusSwitcher(onCampusChanged: () {
                // Refresh campus-specific content
              }),
            ),

   /*
          // Quick Actions with Wonderous styling
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore Campus',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoalBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover events, marketplace, and opportunities at ${campus.name}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.stoneGray,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
               
                  // Premium action cards in grid
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      WonderousStoryCard(
                        title: l10n.events,
                        subtitle: 'Discover happenings',
                        icon: Icons.event,
                        gradientColors: AppColors.eventGradient,
                        onTap: () => context.go('/explore/events'),
                      ),
                      WonderousStoryCard(
                        title: l10n.marketplace,
                        subtitle: 'Buy & sell items',
                        icon: Icons.shopping_bag,
                        gradientColors: AppColors.marketplaceGradient,
                        onTap: () => context.go('/explore/products'),
                      ),
                      WonderousStoryCard(
                        title: l10n.jobs,
                        subtitle: 'Find opportunities',
                        icon: Icons.work,
                        gradientColors: AppColors.jobsGradient,
                        onTap: () => context.go('/explore/volunteer'),
                      ),
                      WonderousStoryCard(
                        title: l10n.expenses,
                        subtitle: 'Manage reimbursements',
                        icon: Icons.receipt_long,
                        gradientColors: AppColors.expenseGradient,
                        trailing: !authState.isAuthenticated
                            ? Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.lock,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                        onTap: () {
                          if (!authState.isAuthenticated) {
                            _showAuthPrompt(context, 'Expenses');
                          } else {
                            context.go('/explore/expenses');
                          }
                        },
                      ),
                    ],
                  ),
                  
                ],
              ),
            ),
          ),*/

          // Latest Content - dynamic horizontal carousels
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: _SectionHeader(
                title: 'Latest events at ${campus.name}',
                onViewAll: () => context.go('/explore/events'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
              child: eventsAsync.when(
                data: (items) => _HorizontalList(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final e = items[index];
                    return SizedBox(
                      width: 280,
                      child: WonderousEventCard(
                        title: e.title,
                        venue: e.venue,
                        date: e.startDate,
                        organizer: e.organizerName,
                        onTap: () => context.go('/explore/events'),
                      ),
                    );
                  },
                ),
                loading: () => const _LoadingRow(),
                error: (err, st) => _ErrorRow(onRetry: () => ref.invalidate(_latestEventsProvider(campusId))),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _SectionHeader(
                title: 'Fresh in marketplace',
                onViewAll: () => context.go('/explore/products'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: productsAsync.when(
                data: (items) => _HorizontalList(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final p = items[index];
                    return SizedBox(
                      width: 240,
                      child: WonderousProductCard(
                        title: p.name,
                        price: p.formattedPrice,
                        seller: p.sellerName,
                        onTap: () => context.go('/explore/products'),
                      ),
                    );
                  },
                ),
                loading: () => const _LoadingRow(),
                error: (err, st) => _ErrorRow(onRetry: () => ref.invalidate(_latestProductsProvider(campusId))),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _SectionHeader(
                title: 'Volunteer with BISO',
                onViewAll: () => context.go('/explore/volunteer'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: jobsAsync.when(
                data: (items) => _HorizontalList(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final j = items[index];
                    return SizedBox(
                      width: 240,
                      child: WonderousJobCard(
                        title: j.title,
                        department: j.department,
                        requirements: j.skills.isNotEmpty ? j.skills.take(2).join(', ') : null,
                        onTap: () => context.go('/explore/volunteer'),
                      ),
                    );
                  },
                ),
                loading: () => const _LoadingRow(),
                error: (err, st) => _ErrorRow(onRetry: () => ref.invalidate(_latestJobsProvider(campusId))),
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
        title: const Text('Sign In Required'),
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
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.charcoalBlack,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.crystalBlue,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('View all'),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.crystalBlue),
            ],
          ),
        ),
      ],
    );
  }
}

class _HorizontalList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const _HorizontalList({required this.itemCount, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return const _EmptyRow();
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: itemBuilder,
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => Container(
        width: 240,
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Text(
        'Nothing here yet. Check back soon.',
        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorRow({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Failed to load. Try again.',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
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
                  color: AppColors.iceBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: AppColors.crystalBlue,
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
                  backgroundColor: AppColors.crystalBlue,
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
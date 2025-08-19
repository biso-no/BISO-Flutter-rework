import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../providers/campus/campus_provider.dart';
import '../../../presentation/widgets/premium/premium_components.dart';
import '../../../presentation/widgets/premium/premium_layouts.dart';
import '../../../presentation/widgets/premium/premium_navigation.dart';
import '../../../presentation/widgets/premium/premium_html_renderer.dart';

import '../../../providers/large_event/large_event_provider.dart';
import '../../../data/services/event_service.dart';
import '../../../data/services/job_service.dart';
import '../../../data/services/product_service.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/job_model.dart';
import '../../../data/models/product_model.dart';
import '../explore/explore_screen.dart';
import '../chat/chat_list_screen.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';

/// Premium Home Screen
///
/// A sophisticated, luxury redesign that showcases BI's exclusive nature.
/// Features glass morphism, elegant animations, and premium visual hierarchy.
class PremiumHomeScreen extends ConsumerStatefulWidget {
  const PremiumHomeScreen({super.key});

  @override
  ConsumerState<PremiumHomeScreen> createState() => _PremiumHomeScreenState();
}

class _PremiumHomeScreenState extends ConsumerState<PremiumHomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _heroAnimationController;

  @override
  void initState() {
    super.initState();
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Start the hero animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _heroAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    super.dispose();
  }

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
      PremiumHomePage(navigateToTab: _navigateToTab),
      const ExploreScreen(),
      authState.isAuthenticated
          ? const ChatListScreen()
          : PremiumAuthRequiredPage(
              title: l10n.chat,
              description: 'Connect with students and organizations across BI',
              icon: Icons.forum_outlined,
            ),
      authState.isAuthenticated
          ? const ProfileScreen()
          : PremiumAuthRequiredPage(
              title: l10n.profile,
              description: 'Manage your account and preferences',
              icon: Icons.person_outline_rounded,
              navigateToTab: _navigateToTab,
            ),
    ];

    return PremiumScaffold(
      extendBodyBehindAppBar: true,
      hasGradientBackground: true,
      gradientColors: const [AppColors.pearl, Colors.white],
      body: Stack(
        children: [
          // Main content
          pages[_selectedIndex],

          // Floating bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: PremiumBottomNav(
              currentIndex: _selectedIndex,
              onTap: _navigateToTab,
              floating: true,
              items: [
                PremiumNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: l10n.home,
                ),
                PremiumNavItem(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore_rounded,
                  label: l10n.explore,
                ),
                PremiumNavItem(
                  icon: Icons.forum_outlined,
                  activeIcon: Icons.forum_rounded,
                  label: l10n.chat,
                  badge: authState.isAuthenticated
                      ? null
                      : const PremiumBadge(showDot: true),
                ),
                PremiumNavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: l10n.profile,
                ),
              ],
            ),
          ),
        ],
      ),
      //floatingActionButton: const AiAssistantFab(),
    );
  }
}

// === PREMIUM HOME PAGE ===

class PremiumHomePage extends ConsumerWidget {
  final Function(int) navigateToTab;

  const PremiumHomePage({super.key, required this.navigateToTab});

  // Data providers
  static final _eventServiceProvider = Provider<EventService>(
    (ref) => EventService(),
  );
  static final _productServiceProvider = Provider<ProductService>(
    (ref) => ProductService(),
  );
  static final _jobServiceProvider = Provider<JobService>(
    (ref) => JobService(),
  );

  static final _latestEventsProvider =
      FutureProvider.family<List<EventModel>, String>((ref, campusId) async {
        final service = ref.watch(_eventServiceProvider);
        return service.getWordPressEvents(campusId: campusId, limit: 6);
      });

  static final _latestProductsProvider =
      FutureProvider.family<List<ProductModel>, String>((ref, campusId) async {
        final service = ref.watch(_productServiceProvider);
        return service.getLatestProducts(campusId: campusId, limit: 6);
      });

  static final _latestJobsProvider =
      FutureProvider.family<List<JobModel>, String>((ref, campusId) async {
        final service = ref.watch(_jobServiceProvider);
        return service.getLatestJobs(campusId: campusId, limit: 6);
      });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campus = ref.watch(filterCampusProvider);
    ref.watch(authStateProvider);
    AppLocalizations.of(context);

    final featuredEvent = ref.watch(featuredLargeEventProvider);
    final campusId = campus.id;

    final eventsAsync = ref.watch(_latestEventsProvider(campusId));
    final productsAsync = ref.watch(_latestProductsProvider(campusId));
    final jobsAsync = ref.watch(_latestJobsProvider(campusId));

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Premium Hero Section
        SliverToBoxAdapter(
          child: _PremiumHeroSection(
            campus: campus,
            featuredEvent: featuredEvent,
            onCampusTap: () => _showCampusSwitcher(context, ref),
          ),
        ),

        /*
        // Quick Actions Grid
        SliverToBoxAdapter(
          child: _PremiumQuickActions(
            authState: authState,
            campus: campus,
            l10n: l10n,
          ),
        ),
*/
        // Latest Events Section
        _buildPremiumContentSection(
          title: 'Happening at ${campus.name}',
          subtitle: 'Discover events and opportunities',
          icon: Icons.event_rounded,
          onViewAll: () => context.go('/explore/events'),
          asyncData: eventsAsync,
          campusId: campusId,
          contentBuilder: (items) =>
              _PremiumEventCarousel(events: items.cast<EventModel>()),
          ref: ref,
          providerFamily: _latestEventsProvider,
        ),

        // Marketplace Section
        _buildPremiumContentSection(
          title: 'Student Marketplace',
          subtitle: 'Buy and sell with fellow students',
          icon: Icons.shopping_bag_rounded,
          onViewAll: () => context.go('/explore/products'),
          asyncData: productsAsync,
          campusId: campusId,
          contentBuilder: (items) =>
              _PremiumProductGrid(products: items.cast<ProductModel>()),
          ref: ref,
          providerFamily: _latestProductsProvider,
        ),

        // Volunteer Opportunities Section
        _buildPremiumContentSection(
          title: 'Open Positions',
          subtitle: 'Volunteer opportunities with BISO',
          icon: Icons.volunteer_activism_rounded,
          onViewAll: () => context.go('/explore/volunteer'),
          asyncData: jobsAsync,
          campusId: campusId,
          contentBuilder: (items) =>
              _PremiumJobList(jobs: items.cast<JobModel>()),
          ref: ref,
          providerFamily: _latestJobsProvider,
        ),

        // Bottom spacing for floating nav
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  SliverToBoxAdapter _buildPremiumContentSection<T>({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onViewAll,
    required AsyncValue<List<T>> asyncData,
    required String campusId,
    required Widget Function(List<T>) contentBuilder,
    required WidgetRef ref,
    required dynamic providerFamily,
  }) {
    return SliverToBoxAdapter(
      child: PremiumSection(
        title: title,
        subtitle: subtitle,
        icon: icon,
        actionText: 'View all',
        onActionTap: onViewAll,
        margin: const EdgeInsets.only(top: 32, bottom: 16),
        child: SizedBox(
          height: 320,
          child: asyncData.when(
            data: (items) => items.isEmpty
                ? _PremiumEmptyState(
                    message: 'Nothing here yet. Check back soon!',
                  )
                : contentBuilder(items),
            loading: () => _PremiumLoadingCarousel(),
            error: (error, stackTrace) => _PremiumErrorState(
              onRetry: () => ref.invalidate(providerFamily(campusId)),
            ),
          ),
        ),
      ),
    );
  }

  void _showCampusSwitcher(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final selectedCampus = ref.watch(filterCampusProvider);
          final allCampuses = ref.watch(allCampusesSyncProvider);

          return _CampusSwitcherModal(
            selectedCampus: selectedCampus,
            allCampuses: allCampuses,
            onCampusSelected: (campus) {
              ref
                  .read(filterCampusProvider.notifier)
                  .selectFilterCampus(campus);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}

// === PREMIUM HERO SECTION ===

class _PremiumHeroSection extends StatelessWidget {
  final dynamic campus;
  final dynamic featuredEvent;
  final VoidCallback onCampusTap;

  const _PremiumHeroSection({
    required this.campus,
    this.featuredEvent,
    required this.onCampusTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 400 + statusBarHeight,
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.biLightBlue,
                  AppColors.biNavy,
                  AppColors.charcoalBlack,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),

          // Floating decorative elements
          Positioned(
            top: statusBarHeight + 60,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 80,
            left: -80,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.biLightBlue.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          Positioned(
            top: statusBarHeight + 20,
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with campus switcher
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Welcome to BISO',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    _CampusButton(campus: campus, onTap: onCampusTap),
                  ],
                ),

                const SizedBox(height: 24),

                // Campus info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        campus.name,
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Connecting students across Norway\'s leading business school',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Campus stats
                      // _PremiumStatsRow(campus: campus),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// === CAMPUS BUTTON ===

class _CampusButton extends StatelessWidget {
  final dynamic campus;
  final VoidCallback onTap;

  const _CampusButton({required this.campus, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_rounded, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              campus.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 16,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}

// === CAMPUS SWITCHER MODAL ===

class _CampusSwitcherModal extends StatelessWidget {
  final dynamic selectedCampus;
  final List<dynamic> allCampuses;
  final Function(dynamic) onCampusSelected;

  const _CampusSwitcherModal({
    required this.selectedCampus,
    required this.allCampuses,
    required this.onCampusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Select Campus',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.gray100,
                    foregroundColor: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Campus List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: allCampuses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final campus = allCampuses[index];
                final isSelected = campus.id == selectedCampus.id;

                return _CampusModalCard(
                  campus: campus,
                  isSelected: isSelected,
                  onTap: () => onCampusSelected(campus),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// === CAMPUS MODAL CARD ===

class _CampusModalCard extends StatelessWidget {
  final dynamic campus;
  final bool isSelected;
  final VoidCallback onTap;

  const _CampusModalCard({
    required this.campus,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.subtleBlue : AppColors.gray50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.defaultBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getCampusColor(campus.id),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  campus.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campus.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.defaultBlue : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    campus.location,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${(campus.stats.studentCount / 1000).toStringAsFixed(1)}k students',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${campus.stats.activeEvents} events',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              children: [
                if (campus.weather != null) ...[
                  Text(
                    campus.weather!.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${campus.weather!.temperature.toStringAsFixed(0)}°',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.defaultBlue,
                    size: 24,
                  )
                else
                  const Icon(
                    Icons.radio_button_unchecked,
                    color: AppColors.onSurfaceVariant,
                    size: 24,
                  ),
              ],
            ),
          ],
        ),
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

// === PREMIUM STATS ROW ===
/*
class _PremiumStatsRow extends StatelessWidget {
  final dynamic campus;

  const _PremiumStatsRow({required this.campus});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 32),
        _PremiumStatItem(
          value: '${campus.eventCount ?? 15}',
          label: 'Events',
        ),
        const SizedBox(width: 32),
        _PremiumStatItem(
          value: '${campus.jobCount ?? 8}',
          label: 'Opportunities',
        ),
      ],
    );
  }
}

class _PremiumStatItem extends StatelessWidget {
  final String value;
  final String label;

  const _PremiumStatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha:0.8),
          ),
        ),
      ],
    );
  }
}
*/
// === PREMIUM QUICK ACTIONS ===

// ignore: unused_element
class _PremiumQuickActions extends StatelessWidget {
  final dynamic authState;
  final dynamic campus;
  final AppLocalizations l10n;

  const _PremiumQuickActions({
    required this.authState,
    required this.campus,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumSection(
      margin: const EdgeInsets.only(top: 24, bottom: 16),
      child: PremiumGrid(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          _PremiumActionCard(
            title: l10n.events,
            subtitle: 'Discover happenings',
            icon: Icons.event_rounded,
            gradientColors: AppColors.eventGradient,
            onTap: () => context.go('/explore/events'),
          ),
          _PremiumActionCard(
            title: l10n.marketplace,
            subtitle: 'Buy & sell items',
            icon: Icons.shopping_bag_rounded,
            gradientColors: AppColors.marketplaceGradient,
            onTap: () => context.go('/explore/products'),
          ),
          _PremiumActionCard(
            title: l10n.jobs,
            subtitle: 'Find opportunities',
            icon: Icons.volunteer_activism_rounded,
            gradientColors: AppColors.jobsGradient,
            onTap: () => context.go('/explore/volunteer'),
          ),
          _PremiumActionCard(
            title: l10n.expenses,
            subtitle: 'Manage reimbursements',
            icon: Icons.receipt_long_rounded,
            gradientColors: AppColors.expenseGradient,
            trailing: !authState.isAuthenticated
                ? Icon(
                    Icons.lock_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.8),
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
    );
  }

  void _showAuthPrompt(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => _PremiumAuthDialog(feature: feature),
    );
  }
}

// === PREMIUM ACTION CARD ===

class _PremiumActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final Widget? trailing;
  final VoidCallback onTap;

  const _PremiumActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    this.trailing,
    required this.onTap,
  });

  @override
  State<_PremiumActionCard> createState() => _PremiumActionCardState();
}

class _PremiumActionCardState extends State<_PremiumActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: PremiumTheme.mediumAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: PremiumTheme.premiumCurve),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.02).animate(
      CurvedAnimation(parent: _controller, curve: PremiumTheme.premiumCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradientColors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradientColors.first.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  ...PremiumTheme.mediumShadow,
                ],
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: CustomPaint(painter: _PatternPainter()),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),

                        const Spacer(),

                        // Text content
                        Text(
                          widget.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          widget.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),

                        // Trailing element
                        if (widget.trailing != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: widget.trailing!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// === PATTERN PAINTER ===

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    final spacing = 40.0;

    for (double i = -spacing; i < size.width + spacing; i += spacing) {
      for (double j = -spacing; j < size.height + spacing; j += spacing) {
        path.addOval(Rect.fromCircle(center: Offset(i, j), radius: 2));
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === CONTENT CAROUSELS AND GRIDS ===

class _PremiumEventCarousel extends StatelessWidget {
  final List<EventModel> events;

  const _PremiumEventCarousel({required this.events});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(width: 16),
      itemBuilder: (context, index) {
        final event = events[index];
        return SizedBox(width: 280, child: _PremiumEventCard(event: event));
      },
    );
  }
}

class _PremiumEventCard extends StatelessWidget {
  final EventModel event;

  const _PremiumEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumCard(
      padding: EdgeInsets.zero,
      onTap: () => context.go('/explore/events'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder with date overlay
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              gradient: LinearGradient(colors: AppColors.eventGradient),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${event.startDate.day}/${event.startDate.month}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoalBlack,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.stoneGray,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.venue,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.stoneGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                if (event.organizerName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'by ${event.organizerName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.biLightBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumProductGrid extends StatelessWidget {
  final List<ProductModel> products;

  const _PremiumProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _PremiumProductCard(product: product);
      },
    );
  }
}

class _PremiumProductCard extends StatelessWidget {
  final ProductModel product;

  const _PremiumProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.go('/explore/products/${product.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(colors: AppColors.marketplaceGradient),
              ),
              child: Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Product info
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              Text(
                product.formattedPrice,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.biLightBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),

              Text(
                'by ${product.sellerName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.stoneGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PremiumJobList extends StatelessWidget {
  final List<JobModel> jobs;

  const _PremiumJobList({required this.jobs});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: jobs.length,
      separatorBuilder: (_, _) => const SizedBox(width: 16),
      itemBuilder: (context, index) {
        final job = jobs[index];
        return SizedBox(width: 260, child: _PremiumJobCard(job: job));
      },
    );
  }
}

class _PremiumJobCard extends StatelessWidget {
  final JobModel job;

  const _PremiumJobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumCard(
      onTap: () => context.go('/explore/volunteer'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Department tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.biLightBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              job.department,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.biLightBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Job title with HTML rendering - flexible height
          Flexible(
            child: job.title.toCompactHtml(
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxLines: 3,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 8),

          // Job description preview with HTML - made more compact
          if (job.description.isNotEmpty)
            Flexible(
              child: job.description.toCompactHtml(
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.stoneGray,
                  height: 1.2,
                ),
                maxLines: 2,
                fontSize: 12,
              ),
            ),

          const SizedBox(height: 8),

          const SizedBox(height: 12),

          // Apply button - reduced padding
          PremiumButton(
            text: 'Learn More',
            isSecondary: true,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            onPressed: () => context.go('/explore/volunteer'),
          ),
        ],
      ),
    );
  }
}

// === LOADING AND ERROR STATES ===

class _PremiumLoadingCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(width: 16),
      itemBuilder: (_, _) => Container(
        width: 280,
        decoration: BoxDecoration(
          color: AppColors.cloud,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _PremiumEmptyState extends StatelessWidget {
  final String message;

  const _PremiumEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.mist),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.stoneGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PremiumErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _PremiumErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Failed to load content',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.stoneGray,
            ),
          ),
          const SizedBox(height: 16),
          PremiumButton(text: 'Retry', isSecondary: true, onPressed: onRetry),
        ],
      ),
    );
  }
}

// === AUTH REQUIRED PAGE ===

class PremiumAuthRequiredPage extends ConsumerWidget {
  final String title;
  final String description;
  final IconData icon;
  final Function(int)? navigateToTab;

  const PremiumAuthRequiredPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.navigateToTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return PremiumScaffold(
      hasGradientBackground: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PremiumContainer(
                width: 120,
                height: 120,
                isGlass: true,
                child: Icon(icon, size: 48, color: AppColors.biLightBlue),
              ),

              const SizedBox(height: 32),

              Text(
                'Sign In Required',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.stoneGray,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              PremiumButton(
                text: 'Sign In',
                icon: Icons.login_rounded,
                width: double.infinity,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              PremiumButton(
                text: 'Browse as Guest',
                isSecondary: true,
                width: double.infinity,
                onPressed: () => navigateToTab?.call(1),
              ),
              PremiumButton(
                text: 'Clear session',
                isSecondary: true,
                onPressed: () =>
                    ref.read(authStateProvider.notifier).clearSession(),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// === AUTH DIALOG ===

class _PremiumAuthDialog extends StatelessWidget {
  final String feature;

  const _PremiumAuthDialog({required this.feature});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_rounded, size: 48, color: AppColors.biLightBlue),

            const SizedBox(height: 16),

            Text(
              'Sign In Required',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Please sign in to access $feature and other personalized features.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.stoneGray,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: PremiumButton(
                    text: 'Cancel',
                    isSecondary: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PremiumButton(
                    text: 'Sign In',
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

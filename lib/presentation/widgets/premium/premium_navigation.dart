import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/premium_theme.dart';

/// Premium Navigation System
///
/// A sophisticated floating navigation bar that creates an exclusive,
/// iOS-inspired experience with glass morphism and elegant animations.

class PremiumBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PremiumNavItem> items;
  final bool floating;

  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.floating = true,
  });

  @override
  State<PremiumBottomNav> createState() => _PremiumBottomNavState();
}

class _PremiumBottomNavState extends State<PremiumBottomNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _bounceAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: PremiumTheme.mediumAnimation,
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers
        .map(
          (controller) => Tween<double>(begin: 1.0, end: 1.2).animate(
            CurvedAnimation(
              parent: controller,
              curve: PremiumTheme.premiumCurve,
            ),
          ),
        )
        .toList();

    _bounceAnimations = _controllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut),
          ),
        )
        .toList();

    // Animate the selected item on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controllers[widget.currentIndex].forward();
    });
  }

  @override
  void didUpdateWidget(PremiumBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _controllers[oldWidget.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    if (widget.floating) {
      return _buildFloatingNav(isDark, bottomPadding);
    } else {
      return _buildStandardNav(isDark, bottomPadding);
    }
  }

  Widget _buildFloatingNav(bool isDark, double bottomPadding) {
    return Positioned(
      bottom: bottomPadding + 16,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.charcoalBlack.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: _buildNavContent(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardNav(bool isDark, double bottomPadding) {
    return Container(
      height: 72 + bottomPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalBlack : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: _buildNavContent(isDark),
      ),
    );
  }

  Widget _buildNavContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final isSelected = index == widget.currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedBuilder(
                animation: _controllers[index],
                builder: (context, child) => Transform.scale(
                  scale: _scaleAnimations[index].value,
                  child: _PremiumNavButton(
                    item: item,
                    isSelected: isSelected,
                    isDark: isDark,
                    bounceAnimation: _bounceAnimations[index],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PremiumNavButton extends StatelessWidget {
  final PremiumNavItem item;
  final bool isSelected;
  final bool isDark;
  final Animation<double> bounceAnimation;

  const _PremiumNavButton({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.bounceAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon container with selection indicator
        AnimatedContainer(
          duration: PremiumTheme.mediumAnimation,
          curve: PremiumTheme.premiumCurve,
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.biLightBlue.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Selection background with pulse effect
              if (isSelected)
                AnimatedBuilder(
                  animation: bounceAnimation,
                  builder: (context, child) => Container(
                    width: 48 * (0.8 + 0.2 * bounceAnimation.value),
                    height: 48 * (0.8 + 0.2 * bounceAnimation.value),
                    decoration: BoxDecoration(
                      color: AppColors.biLightBlue.withValues(
                        alpha: 0.1 * bounceAnimation.value,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

              // Icon
              AnimatedSwitcher(
                duration: PremiumTheme.fastAnimation,
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  key: ValueKey(isSelected),
                  size: 24,
                  color: isSelected
                      ? AppColors.biLightBlue
                      : (isDark ? AppColors.mist : AppColors.stoneGray),
                ),
              ),

              // Badge if present
              if (item.badge != null)
                Positioned(top: 8, right: 8, child: item.badge!),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Label
        AnimatedDefaultTextStyle(
          duration: PremiumTheme.mediumAnimation,
          curve: PremiumTheme.premiumCurve,
          style:
              theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? AppColors.biLightBlue
                    : (isDark ? AppColors.mist : AppColors.stoneGray),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ) ??
              const TextStyle(),
          child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

// === PREMIUM BADGE ===

class PremiumBadge extends StatelessWidget {
  final String? text;
  final bool showDot;
  final Color? color;

  const PremiumBadge({super.key, this.text, this.showDot = false, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = color ?? AppColors.error;

    if (showDot && (text == null || text!.isEmpty)) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: badgeColor.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text ?? '',
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// === PREMIUM NAV ITEM ===

class PremiumNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget? badge;

  const PremiumNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });
}

// === PREMIUM TAB VIEW ===

class PremiumTabView extends StatefulWidget {
  final List<PremiumTab> tabs;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final bool isScrollable;

  const PremiumTabView({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onChanged,
    this.isScrollable = false,
  });

  @override
  State<PremiumTabView> createState() => _PremiumTabViewState();
}

class _PremiumTabViewState extends State<PremiumTabView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      initialIndex: widget.initialIndex,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        widget.onChanged?.call(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.smokeGray : AppColors.cloud,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: widget.isScrollable,
            indicator: BoxDecoration(
              color: isDark ? AppColors.stoneGray : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: PremiumTheme.softShadow,
            ),
            indicatorPadding: const EdgeInsets.all(4),
            labelColor: isDark ? AppColors.pearl : AppColors.charcoalBlack,
            unselectedLabelColor: isDark ? AppColors.mist : AppColors.stoneGray,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            dividerColor: Colors.transparent,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            tabs: widget.tabs
                .map(
                  (tab) => Tab(
                    text: tab.title,
                    icon: tab.icon != null ? Icon(tab.icon, size: 20) : null,
                  ),
                )
                .toList(),
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabs.map((tab) => tab.content).toList(),
          ),
        ),
      ],
    );
  }
}

class PremiumTab {
  final String title;
  final IconData? icon;
  final Widget content;

  const PremiumTab({required this.title, this.icon, required this.content});
}

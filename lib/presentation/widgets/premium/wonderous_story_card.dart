import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WonderousStoryCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? description;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isLarge;
  final String? imagePath;
  final Widget? heroWidget;

  const WonderousStoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.description,
    required this.icon,
    required this.gradientColors,
    this.onTap,
    this.trailing,
    this.isLarge = false,
    this.imagePath,
    this.heroWidget,
  });

  @override
  State<WonderousStoryCard> createState() => _WonderousStoryCardState();
}

class _WonderousStoryCardState extends State<WonderousStoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: widget.isLarge ? 240 : 160,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.gradientColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.gradientColors.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Background pattern/texture
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Hero illustration area
                  if (widget.heroWidget != null || widget.imagePath != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      width: widget.isLarge ? 140 : 100,
                      child:
                          widget.heroWidget ??
                          (widget.imagePath != null
                              ? Image.asset(
                                  widget.imagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildFallbackIllustration(),
                                )
                              : _buildFallbackIllustration()),
                    ),

                  // Content overlay
                  Positioned(
                    left: 20,
                    right: widget.heroWidget != null || widget.imagePath != null
                        ? (widget.isLarge ? 160 : 120)
                        : 20,
                    top: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Title
                        Text(
                          widget.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: widget.isLarge ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 1),

                        // Subtitle
                        Text(
                          widget.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Description (for large cards)
                        if (widget.isLarge && widget.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        // Trailing widget or arrow (using Expanded to take remaining space)
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child:
                                widget.trailing ??
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                          ),
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
    );
  }

  Widget _buildFallbackIllustration() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          widget.icon,
          size: 60,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

// Premium Event Card with Wonderous styling
class WonderousEventCard extends StatelessWidget {
  final String title;
  final String venue;
  final DateTime date;
  final String? organizer;
  final VoidCallback? onTap;

  const WonderousEventCard({
    super.key,
    required this.title,
    required this.venue,
    required this.date,
    this.organizer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WonderousStoryCard(
      title: title,
      subtitle: venue,
      description: organizer,
      icon: Icons.event,
      gradientColors: AppColors.eventGradient,
      isLarge: true,
      onTap: onTap,
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${date.day}/${date.month}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    );
  }
}

// Premium Product Card
class WonderousProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String seller;
  final VoidCallback? onTap;

  const WonderousProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.seller,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WonderousStoryCard(
      title: title,
      subtitle: price,
      description: 'by $seller',
      icon: Icons.shopping_bag,
      gradientColors: AppColors.marketplaceGradient,
      onTap: onTap,
    );
  }
}

// Premium Job Card
class WonderousJobCard extends StatelessWidget {
  final String title;
  final String department;
  final String? requirements;
  final VoidCallback? onTap;

  const WonderousJobCard({
    super.key,
    required this.title,
    required this.department,
    this.requirements,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WonderousStoryCard(
      title: title,
      subtitle: department,
      description: requirements,
      icon: Icons.work,
      gradientColors: AppColors.jobsGradient,
      onTap: onTap,
    );
  }
}

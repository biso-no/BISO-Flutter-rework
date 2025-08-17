import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/large_event_model.dart';

class LargeEventHero extends StatefulWidget {
  final LargeEventModel event;
  final double expandedHeight;
  const LargeEventHero({super.key, required this.event, this.expandedHeight = 350});

  @override
  State<LargeEventHero> createState() => _LargeEventHeroState();
}

class _LargeEventHeroState extends State<LargeEventHero> with TickerProviderStateMixin {
  late AnimationController _overlayController;

  @override
  void initState() {
    super.initState();
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.event.textColor;
    final gradient = widget.event.gradientColors;

    return SliverAppBar(
      expandedHeight: widget.expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double topPadding = MediaQuery.of(context).padding.top;
          final double maxExtent = widget.expandedHeight;
          final double minExtent = kToolbarHeight + topPadding;
          final double currentExtent = constraints.biggest.height;
          final double t = ((maxExtent - currentExtent) / (maxExtent - minExtent)).clamp(0.0, 1.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              // Background image or gradient
              if (widget.event.backgroundImageUrl != null && widget.event.backgroundImageUrl!.isNotEmpty)
                Positioned.fill(
                  child: Image.network(
                    widget.event.backgroundImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _gradientBackground(gradient),
                  ),
                )
              else
                _gradientBackground(gradient),

              // Overlay gradient for readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Content
              _buildContent(textColor),

              // Top bar background as it collapses
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(
                    height: topPadding + kToolbarHeight,
                    decoration: BoxDecoration(
                      color: Color.lerp(Colors.transparent, Colors.white, t),
                      boxShadow: t > 0.01
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06 * t),
                                blurRadius: 12 * t,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilledButton.icon(
            onPressed: () => context.push('/events/large/${widget.event.slug}', extra: widget.event),
            icon: const Icon(Icons.info_outline),
            label: const Text('Details'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.crystalBlue),
          ),
        )
      ],
    );
  }

  Widget _gradientBackground(List<Color> gradient) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    final theme = Theme.of(context);
    return Positioned(
      left: 20,
      right: 20,
      bottom: 24,
      child: FadeTransition(
        opacity: _overlayController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.event.logoUrl != null && widget.event.logoUrl!.isNotEmpty)
              SizedBox(
                height: 48,
                child: Image.network(widget.event.logoUrl!, fit: BoxFit.contain),
              ),
            if (widget.event.logoUrl != null && widget.event.logoUrl!.isNotEmpty)
              const SizedBox(height: 8),
            Text(
              widget.event.name,
              style: theme.textTheme.displaySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.event.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: textColor.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



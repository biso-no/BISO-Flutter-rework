import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';
import '../../../data/models/campus_model.dart';
// Removed weather provider usage in favor of CampusModel.weather

class WonderousCampusHero extends ConsumerStatefulWidget {
  final CampusModel campus;
  final double expandedHeight;
  final Widget? trailing;
  final VoidCallback? onCampusTap;

  const WonderousCampusHero({
    super.key,
    required this.campus,
    this.expandedHeight = 400,
    this.trailing,
    this.onCampusTap,
  });

  @override
  ConsumerState<WonderousCampusHero> createState() => _WonderousCampusHeroState();
}

class _WonderousCampusHeroState extends ConsumerState<WonderousCampusHero>
    with TickerProviderStateMixin {
  late AnimationController _parallaxController;
  late AnimationController _overlayController;
  late Animation<double> _parallaxAnimation;
  late Animation<double> _overlayAnimation;

  @override
  void initState() {
    super.initState();
    _parallaxController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _parallaxAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _parallaxController, curve: Curves.linear),
    );

    _overlayAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _overlayController, curve: Curves.easeInOut),
    );

    // Start overlay animation
    _overlayController.forward();
  }

  @override
  void dispose() {
    _parallaxController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradientColors = _getCampusGradient(widget.campus.id);

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
          final double t =
              ((maxExtent - currentExtent) / (maxExtent - minExtent)).clamp(
                0.0,
                1.0,
              );

          return Stack(
            children: [
              // Campus image as background (like Wonderous)
              _buildCampusBackground(),

              // Sophisticated gradient overlay
              _buildGradientOverlay(gradientColors),

              // Geometric pattern overlay
              _buildGeometricPattern(),

              // Content overlay
              _buildContentOverlay(theme),

              // Floating stats
              _buildFloatingStats(theme),

              // Top app bar background that transitions from transparent -> white as it collapses
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
                              ),
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
        if (widget.trailing != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: widget.trailing!,
          ),
      ],
    );
  }

  Widget _buildCampusBackground() {
    final imagePath = _getCampusImagePath(widget.campus.id);

    return Positioned.fill(
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to gradient background if image fails
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getCampusGradient(widget.campus.id),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlay(List<Color> colors) {
    return AnimatedBuilder(
      animation: _parallaxAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // Subtle top overlay
                colors.first.withValues(alpha: 0.3),
                // Transparent middle to show image
                Colors.transparent,
                Colors.transparent,
                // Strong bottom overlay for text readability
                colors.first.withValues(alpha: 0.8),
                colors.last.withValues(alpha: 0.9),
              ],
              stops: [0.0, 0.3, 0.5, 0.8, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeometricPattern() {
    return AnimatedBuilder(
      animation: _parallaxAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: WonderousPatternPainter(
              animation: _parallaxAnimation.value,
              campus: widget.campus,
            ),
          ),
        );
      },
    );
  }

  String _getCampusImagePath(String campusId) {
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
        return 'assets/images/campus/oslo.png';
    }
  }

  Widget _buildContentOverlay(ThemeData theme) {
    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _overlayAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - _overlayAnimation.value) * 50),
            child: Opacity(
              opacity: _overlayAnimation.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campus name with premium styling
                  Text(
                    'Welcome to',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: widget.onCampusTap,
                    child: Text(
                      'BISO ${widget.campus.name}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Campus description
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.campus.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingStats(ThemeData theme) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _overlayAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - _overlayAnimation.value) * 30),
            child: Opacity(
              opacity: _overlayAnimation.value * 0.9,
              child: Row(
                children: [
                  // Weather widget
                  if (widget.campus.weather != null)
                    Row(
                      children: [
                        _buildStatPill(
                          icon: widget.campus.weather!.icon,
                          value: '${widget.campus.weather!.temperature.round()}°',
                          label: widget.campus.weather!.condition,
                          theme: theme,
                          isWeather: true,
                        ),
                        const SizedBox(width: 12),
                      ],
                    )
                  else
                    const SizedBox.shrink(),

                  // Stats
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatPill(
                          icon: '👥',
                          value:
                              '${(widget.campus.stats.studentCount / 1000).toStringAsFixed(1)}k',
                          label: 'Students',
                          theme: theme,
                        ),
                        _buildStatPill(
                          icon: '🎉',
                          value: widget.campus.stats.activeEvents.toString(),
                          label: 'Events',
                          theme: theme,
                        ),
                        _buildStatPill(
                          icon: '💼',
                          value: widget.campus.stats.availableJobs.toString(),
                          label: 'Jobs',
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatPill({
    required String icon,
    required String value,
    required String label,
    required ThemeData theme,
    bool isWeather = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeather ? 16 : 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isWeather
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 10,
                    height: 1.0,
                  ),
                ),
              ],
            ),
    );
  }

  List<Color> _getCampusGradient(String campusId) {
    switch (campusId.toLowerCase()) {
      case 'oslo':
        return AppColors.osloGradient;
      case 'bergen':
        return AppColors.bergenGradient;
      case 'trondheim':
        return AppColors.trondheimGradient;
      case 'stavanger':
        return AppColors.stavangerGradient;
      default:
        return AppColors.osloGradient;
    }
  }
}

// Custom painter for geometric patterns
class WonderousPatternPainter extends CustomPainter {
  final double animation;
  final CampusModel campus;

  WonderousPatternPainter({required this.animation, required this.campus});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw animated geometric shapes based on campus
    switch (campus.id.toLowerCase()) {
      case 'oslo':
        _drawCityPattern(canvas, size, paint, strokePaint);
        break;
      case 'bergen':
        _drawMountainPattern(canvas, size, paint, strokePaint);
        break;
      case 'trondheim':
        _drawRiverPattern(canvas, size, paint, strokePaint);
        break;
      case 'stavanger':
        _drawWavePattern(canvas, size, paint, strokePaint);
        break;
    }
  }

  void _drawCityPattern(Canvas canvas, Size size, Paint fill, Paint stroke) {
    // Draw animated rectangles representing buildings
    for (int i = 0; i < 8; i++) {
      final x = (size.width / 8) * i + (animation * 20);
      final height = 40 + (math.sin(animation * 2 + i) * 20);
      final rect = Rect.fromLTWH(x, size.height - height, 30, height);
      canvas.drawRect(rect, fill);
      canvas.drawRect(rect, stroke);
    }
  }

  void _drawMountainPattern(
    Canvas canvas,
    Size size,
    Paint fill,
    Paint stroke,
  ) {
    // Draw animated mountain silhouettes
    final path = Path();
    path.moveTo(0, size.height);

    for (int i = 0; i <= 10; i++) {
      final x = (size.width / 10) * i;
      final y = size.height - (60 + math.sin(animation + i * 0.5) * 30);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawRiverPattern(Canvas canvas, Size size, Paint fill, Paint stroke) {
    // Draw flowing river-like curves
    final path = Path();
    path.moveTo(0, size.height * 0.7);

    for (double x = 0; x <= size.width; x += 20) {
      final y = size.height * 0.7 + math.sin((x / 50) + animation * 2) * 20;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, stroke);
  }

  void _drawWavePattern(Canvas canvas, Size size, Paint fill, Paint stroke) {
    // Draw ocean waves
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final yOffset = size.height * 0.8 + (i * 15);
      path.moveTo(0, yOffset);

      for (double x = 0; x <= size.width; x += 40) {
        final y = yOffset + math.sin((x / 30) + animation * 3 + i) * 10;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

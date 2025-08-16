import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class AiAssistantFab extends StatefulWidget {
  const AiAssistantFab({super.key});

  @override
  State<AiAssistantFab> createState() => _AiAssistantFabState();
}

class _AiAssistantFabState extends State<AiAssistantFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeInOut),
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing background circle
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.crystalBlue.withOpacity(0.2),
                          AppColors.emeraldGreen.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                ),
                // Main FAB
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.crystalBlue,
                        AppColors.emeraldGreen,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.crystalBlue.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: AppColors.emeraldGreen.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () => _openAiChat(context),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                // Small badge indicator
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.sunGold,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AppColors.backgroundDark : AppColors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.white,
                      size: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAiChat(BuildContext context) {
    // Add a small haptic feedback
    // HapticFeedback.lightImpact();
    
    // Navigate to AI chat screen
    context.pushNamed('ai-chat');
  }
}

/// Extended version with tooltip and enhanced interactions
class AiAssistantFabExtended extends StatefulWidget {
  final String? tooltip;
  final VoidCallback? onPressed;

  const AiAssistantFabExtended({
    super.key,
    this.tooltip,
    this.onPressed,
  });

  @override
  State<AiAssistantFabExtended> createState() => _AiAssistantFabExtendedState();
}

class _AiAssistantFabExtendedState extends State<AiAssistantFabExtended>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _setHovered(true),
            onExit: (_) => _setHovered(false),
            child: Tooltip(
              message: widget.tooltip ?? 'Ask AI Assistant',
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.crystalBlue.withOpacity(0.3 * _glowAnimation.value),
                      blurRadius: 20 * _glowAnimation.value,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onTap: widget.onPressed ?? () => _openAiChat(context),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.crystalBlue,
                            AppColors.emeraldGreen,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: AppColors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _setHovered(bool hovered) {
    if (_isHovered != hovered) {
      setState(() {
        _isHovered = hovered;
      });
      
      if (hovered) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }
  }

  void _openAiChat(BuildContext context) {
    context.pushNamed('ai-chat');
  }
}
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create staggered animations for each dot
    _dotAnimations = List.generate(3, (index) {
      return Tween<double>(
        begin: 0.4,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.2,
          0.6 + (index * 0.2),
          curve: Curves.easeInOut,
        ),
      ));
    });

    _animationController.repeat();
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(isDark),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.surfaceDark : AppColors.white)
                  .withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (isDark ? AppColors.outlineDark : AppColors.outline)
                    .withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppColors.shadowHeavy : AppColors.shadowLight)
                      .withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _dotAnimations[index],
                    builder: (context, child) {
                      return Container(
                        margin: EdgeInsets.only(
                          left: index > 0 ? 4 : 0,
                        ),
                        child: Opacity(
                          opacity: _dotAnimations[index].value,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.crystalBlue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  'AI is thinking...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 48), // Right margin for balance
      ],
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            AppColors.crystalBlue.withOpacity(0.8),
            AppColors.emeraldGreen.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.crystalBlue.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animationController.value * 2 * 3.14159,
            child: const Icon(
              Icons.psychology_rounded,
              color: AppColors.white,
              size: 20,
            ),
          );
        },
      ),
    );
  }
}
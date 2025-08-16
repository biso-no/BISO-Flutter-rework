import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SharePointSearchWidget extends StatefulWidget {
  const SharePointSearchWidget({super.key});

  @override
  State<SharePointSearchWidget> createState() => _SharePointSearchWidgetState();
}

class _SharePointSearchWidgetState extends State<SharePointSearchWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _animationController.repeat();
    
    // Simulate progressing through steps
    _startStepProgression();
  }

  void _startStepProgression() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _currentStep = 1);
      }
    });
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _currentStep = 2);
      }
    });
    
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => _currentStep = 3);
      }
    });
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 16),
                    _buildSearchProcess(theme),
                    const SizedBox(height: 16),
                    _buildContentPreview(theme, isDark),
                  ],
                ),
              ),
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
            AppColors.crystalBlue,
            AppColors.emeraldGreen,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.crystalBlue.withOpacity(0.3),
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
              Icons.search_rounded,
              color: AppColors.white,
              size: 20,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.crystalBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.search_rounded,
            color: AppColors.crystalBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SharePoint Search',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Searching for relevant documents...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.crystalBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _buildLoadingSpinner(),
      ],
    );
  }

  Widget _buildLoadingSpinner() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animationController.value * 2 * 3.14159,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  AppColors.crystalBlue,
                  AppColors.emeraldGreen,
                ],
              ),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: AppColors.white,
              size: 14,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchProcess(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.crystalBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.crystalBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_rounded,
                size: 16,
                color: AppColors.crystalBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Search Process',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.crystalBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._buildSearchSteps(theme),
        ],
      ),
    );
  }

  List<Widget> _buildSearchSteps(ThemeData theme) {
    final steps = [
      ('🔍', 'Analyzing your query'),
      ('🧠', 'Converting to vector embeddings'),
      ('📊', 'Searching Pinecone database'),
      ('📄', 'Fetching relevant documents'),
    ];

    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final (emoji, description) = entry.value;
      final isActive = index <= _currentStep;
      final isCompleted = index < _currentStep;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? AppColors.emeraldGreen 
                    : isActive 
                        ? AppColors.crystalBlue 
                        : AppColors.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              emoji,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: isActive ? 1.0 : 0.6,
                child: Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isActive 
                        ? AppColors.onSurface
                        : AppColors.outline,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ),
            if (isActive && !isCompleted)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.crystalBlue),
                ),
              )
            else if (isCompleted)
              Icon(
                Icons.check_rounded,
                size: 12,
                color: AppColors.emeraldGreen,
              ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildContentPreview(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.surfaceDark : AppColors.white).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview_rounded,
                size: 16,
                color: AppColors.outline,
              ),
              const SizedBox(width: 8),
              Text(
                'Content Preview',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Animated skeleton loading bars
          ...List.generate(3, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildSkeletonLine(
              width: [0.9, 0.7, 0.5][index],
              delay: Duration(milliseconds: index * 200),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSkeletonLine({required double width, required Duration delay}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Create shimmer effect
        final shimmerValue = (_animationController.value + delay.inMilliseconds / 1000) % 1.0;
        return Container(
          height: 12,
          width: MediaQuery.of(context).size.width * width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: [
                AppColors.outline.withOpacity(0.1),
                AppColors.outline.withOpacity(0.3),
                AppColors.outline.withOpacity(0.1),
              ],
              stops: [
                (shimmerValue - 0.3).clamp(0.0, 1.0),
                shimmerValue,
                (shimmerValue + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
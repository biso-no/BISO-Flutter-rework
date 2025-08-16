import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// A preview widget that shows anticipated tool patterns for future integrations
class FutureToolPreview extends StatefulWidget {
  final String toolName;
  final Map<String, dynamic>? args;
  final bool isDark;

  const FutureToolPreview({
    super.key,
    required this.toolName,
    this.args,
    this.isDark = false,
  });

  @override
  State<FutureToolPreview> createState() => _FutureToolPreviewState();
}

class _FutureToolPreviewState extends State<FutureToolPreview>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));

    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildToolPreview(context);
  }

  Widget _buildToolPreview(BuildContext context) {
    switch (widget.toolName) {
      case 'canvasIntegration':
        return _buildCanvasPreview(context);
      case 'studentLookup':
        return _buildStudentLookupPreview(context);
      case 'eventScheduler':
        return _buildEventSchedulerPreview(context);
      case 'bibliotekSearch':
        return _buildLibraryPreview(context);
      case 'timeTableLookup':
        return _buildTimeTablePreview(context);
      case 'roomBooking':
        return _buildRoomBookingPreview(context);
      default:
        return _buildGenericFutureToolPreview(context);
    }
  }

  Widget _buildCanvasPreview(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.crystalBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.crystalBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildToolIcon(Icons.school_rounded, AppColors.crystalBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Canvas Integration',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Accessing your courses and assignments...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.crystalBlue,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPulsingIndicator(),
            ],
          ),
          const SizedBox(height: 16),
          _buildShimmerPlaceholder('Recent assignments', 3),
          const SizedBox(height: 8),
          _buildShimmerPlaceholder('Upcoming deadlines', 2),
        ],
      ),
    );
  }

  Widget _buildStudentLookupPreview(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.emeraldGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.emeraldGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildToolIcon(Icons.people_rounded, AppColors.emeraldGreen),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student Directory',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Searching student database...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.emeraldGreen,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPulsingIndicator(),
            ],
          ),
          const SizedBox(height: 16),
          _buildShimmerPlaceholder('Student profiles', 4),
        ],
      ),
    );
  }

  Widget _buildEventSchedulerPreview(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warmGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warmGold.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildToolIcon(Icons.event_rounded, AppColors.warmGold),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Scheduler',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Finding available times...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.warmGold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPulsingIndicator(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDateCard('Today')),
              const SizedBox(width: 8),
              Expanded(child: _buildDateCard('Tomorrow')),
              const SizedBox(width: 8),
              Expanded(child: _buildDateCard('This Week')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryPreview(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.skyBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.skyBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildToolIcon(Icons.library_books_rounded, AppColors.skyBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BI Bibliotek Search',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Searching library catalog...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.skyBlue,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPulsingIndicator(),
            ],
          ),
          const SizedBox(height: 16),
          _buildShimmerPlaceholder('Available books', 3),
          const SizedBox(height: 8),
          _buildShimmerPlaceholder('Digital resources', 2),
        ],
      ),
    );
  }

  Widget _buildTimeTablePreview(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sunGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.sunGold.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildToolIcon(Icons.schedule_rounded, AppColors.sunGold),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timetable Lookup',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Checking your schedule...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.sunGold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPulsingIndicator(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTimeSlot('09:00')),
              const SizedBox(width: 8),
              Expanded(child: _buildTimeSlot('11:00')),
              const SizedBox(width: 8),
              Expanded(child: _buildTimeSlot('14:00')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomBookingPreview(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.richNavy.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.richNavy.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildToolIcon(Icons.meeting_room_rounded, AppColors.richNavy),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Room Booking',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Finding available rooms...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.richNavy,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPulsingIndicator(),
            ],
          ),
          const SizedBox(height: 16),
          _buildShimmerPlaceholder('Meeting rooms', 3),
        ],
      ),
    );
  }

  Widget _buildGenericFutureToolPreview(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.onSurfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.onSurfaceVariant.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          _buildToolIcon(Icons.extension_rounded, AppColors.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.toolName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Processing request...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _buildPulsingIndicator(),
        ],
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulsingIndicator() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _pulseAnimation.value,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.crystalBlue,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerPlaceholder(String label, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(count, (index) => _buildShimmerLine()),
      ],
    );
  }

  Widget _buildShimmerLine() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      height: 12,
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                begin: Alignment(_shimmerAnimation.value - 1, 0),
                end: Alignment(_shimmerAnimation.value, 0),
                colors: [
                  AppColors.onSurfaceVariant.withOpacity(0.1),
                  AppColors.onSurfaceVariant.withOpacity(0.3),
                  AppColors.onSurfaceVariant.withOpacity(0.1),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateCard(String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.warmGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.warmGold.withOpacity(0.2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.warmGold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimeSlot(String time) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.sunGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.sunGold.withOpacity(0.2),
        ),
      ),
      child: Text(
        time,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.sunGold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
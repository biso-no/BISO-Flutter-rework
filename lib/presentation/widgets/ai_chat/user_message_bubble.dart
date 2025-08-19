import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/ai_chat_models.dart';
import '../../../core/constants/app_colors.dart';

class UserMessageBubble extends StatefulWidget {
  final ChatMessage message;

  const UserMessageBubble({super.key, required this.message});

  @override
  State<UserMessageBubble> createState() => _UserMessageBubbleState();
}

class _UserMessageBubbleState extends State<UserMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
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

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 48), // Left margin for balance
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMessageBubble(theme, isDark),
                  const SizedBox(height: 4),
                  _buildTimestamp(theme),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildAvatar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [AppColors.crystalBlue, AppColors.skyBlue],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.crystalBlue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.person_rounded, color: AppColors.white, size: 20),
    );
  }

  Widget _buildMessageBubble(ThemeData theme, bool isDark) {
    final textContent = widget.message.textContent;

    if (textContent.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => _showInteractionFeedback(),
      onLongPress: () => _copyToClipboard(textContent),
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.crystalBlue, AppColors.defaultBlue],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.crystalBlue.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.white.withValues(alpha: 0.2),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            textContent,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.white,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimestamp(ThemeData theme) {
    if (widget.message.timestamp == null) {
      return const SizedBox.shrink();
    }

    final time = TimeOfDay.fromDateTime(widget.message.timestamp!);
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.onSurfaceVariant,
          fontSize: 11,
        ),
      ),
    );
  }

  void _showInteractionFeedback() {
    // Add a subtle scale animation on tap
    _animationController.reverse().then((_) {
      _animationController.forward();
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: AppColors.crystalBlue,
      ),
    );
  }
}

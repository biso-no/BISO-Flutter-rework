import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/ai_chat_models.dart';
import '../../../core/constants/app_colors.dart';
import 'tool_output_widget.dart';
import 'markdown_text.dart';

class AiMessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isStreaming;

  const AiMessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  @override
  State<AiMessageBubble> createState() => _AiMessageBubbleState();
}

class _AiMessageBubbleState extends State<AiMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

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
      child: SlideTransition(
        position: _slideAnimation,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(isDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageBubble(theme, isDark),
                  if (widget.message.toolParts.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ..._buildToolOutputs(theme, isDark),
                  ],
                  const SizedBox(height: 4),
                  _buildTimestamp(theme),
                ],
              ),
            ),
            const SizedBox(width: 48), // Right margin for balance
          ],
        ),
      ),
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
      child: const Icon(
        Icons.psychology_rounded,
        color: AppColors.white,
        size: 20,
      ),
    );
  }

  Widget _buildMessageBubble(ThemeData theme, bool isDark) {
    final textContent = widget.message.textContent;
    
    print('🎨 [AI_BUBBLE] Building bubble for message ${widget.message.id}');
    print('📝 [AI_BUBBLE] Text content: "$textContent" (length: ${textContent.length})');
    print('⏳ [AI_BUBBLE] Is streaming: ${widget.isStreaming}');
    print('🧩 [AI_BUBBLE] Message parts: ${widget.message.parts.length}');
    
    // Only hide bubble if there's no text content, no tool parts, and not streaming
    if (textContent.isEmpty && widget.message.toolParts.isEmpty && !widget.isStreaming) {
      print('👻 [AI_BUBBLE] Returning empty bubble - no content, no tools, and not streaming');
      return const SizedBox.shrink();
    }
    
    // If no text but has tool parts, show a placeholder message
    final hasToolParts = widget.message.toolParts.isNotEmpty;
    print('🔧 [AI_BUBBLE] Has tool parts: $hasToolParts (${widget.message.toolParts.length})');
    
    if (textContent.isEmpty && hasToolParts && !widget.isStreaming) {
      print('🔧 [AI_BUBBLE] Showing tool-only response');
    }

    return GestureDetector(
      onLongPress: () => _copyToClipboard(textContent),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (textContent.isNotEmpty)
                  MarkdownText(
                    text: textContent,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
                    ),
                  )
                else if (hasToolParts && !widget.isStreaming)
                  // Show placeholder when there are tools but no text response
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Found information using search tools:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: (isDark ? AppColors.onSurfaceDark : AppColors.onSurface)
                            .withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                if (widget.isStreaming && textContent.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 4),
                      _buildStreamingCursor(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreamingCursor() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: (_animationController.value * 2) % 1.0 > 0.5 ? 1.0 : 0.3,
          child: Container(
            width: 2,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.crystalBlue,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildToolOutputs(ThemeData theme, bool isDark) {
    return widget.message.toolParts.map((toolPart) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ToolOutputWidget(
          toolPart: toolPart,
          isDark: isDark,
        ),
      );
    }).toList();
  }

  Widget _buildTimestamp(ThemeData theme) {
    if (widget.message.timestamp == null) {
      return const SizedBox.shrink();
    }

    final time = TimeOfDay.fromDateTime(widget.message.timestamp!);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.onSurfaceVariant,
          fontSize: 11,
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Message copied to clipboard'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}
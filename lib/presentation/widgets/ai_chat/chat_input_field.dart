import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  final bool isDark;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
    this.isDark = false,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField>
    with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      
      if (hasText) {
        _scaleController.forward();
        _rotationController.forward();
      } else {
        _scaleController.reverse();
        _rotationController.reverse();
      }
    }
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _handleSend() {
    if (widget.controller.text.trim().isNotEmpty && widget.enabled) {
      widget.onSend();
      _scaleController.reverse();
      _rotationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      constraints: const BoxConstraints(
        minHeight: 52,
        maxHeight: 120,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildActionButton(
            icon: Icons.attach_file_rounded,
            onPressed: _handleAttachment,
            tooltip: 'Attach file',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTextField(theme),
          ),
          const SizedBox(width: 8),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildTextField(ThemeData theme) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: 'Ask me anything about BISO...',
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: widget.isDark 
              ? AppColors.mist.withOpacity(0.7)
              : AppColors.onSurfaceVariant.withOpacity(0.7),
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: false,
      ),
      style: theme.textTheme.bodyLarge?.copyWith(
        color: widget.isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
        height: 1.5,
      ),
      onSubmitted: (_) => _handleSend(),
    );
  }

  Widget _buildSendButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: RotationTransition(
            turns: _rotationAnimation,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: _hasText && widget.enabled
                    ? const LinearGradient(
                        colors: [
                          AppColors.crystalBlue,
                          AppColors.defaultBlue,
                        ],
                      )
                    : null,
                color: !_hasText || !widget.enabled
                    ? (widget.isDark ? AppColors.stoneGray : AppColors.outline)
                    : null,
                borderRadius: BorderRadius.circular(22),
                boxShadow: _hasText && widget.enabled
                    ? [
                        BoxShadow(
                          color: AppColors.crystalBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: _hasText && widget.enabled ? _handleSend : null,
                  child: Icon(
                    Icons.send_rounded,
                    color: _hasText && widget.enabled
                        ? AppColors.white
                        : (widget.isDark ? AppColors.mist : AppColors.onSurfaceVariant),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: (widget.isDark ? AppColors.stoneGray : AppColors.outline)
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Icon(
            icon,
            color: widget.isDark ? AppColors.mist : AppColors.onSurfaceVariant,
            size: 18,
          ),
        ),
      ),
    );
  }

  void _handleAttachment() {
    // TODO: Implement file attachment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File attachment coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
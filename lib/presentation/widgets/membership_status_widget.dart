import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/membership_model.dart';

class MembershipStatusWidget extends StatefulWidget {
  final MembershipModel? membership;
  final bool isVerified;
  final Color campusColor;
  final VoidCallback? onBuyMembership;

  const MembershipStatusWidget({
    super.key,
    this.membership,
    required this.isVerified,
    required this.campusColor,
    this.onBuyMembership,
  });

  @override
  State<MembershipStatusWidget> createState() => _MembershipStatusWidgetState();
}

class _MembershipStatusWidgetState extends State<MembershipStatusWidget>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Shimmer animation for verified badge
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    // Pulse animation for active membership
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.membership?.isActive == true) {
      _shimmerController.repeat();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final membership = widget.membership;

    if (membership == null) {
      return _buildNonMemberCard(theme);
    }

    if (membership.isActive) {
      return _buildActiveMembershipCard(theme, membership);
    } else {
      return _buildExpiredMembershipCard(theme, membership);
    }
  }

  Widget _buildNonMemberCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.card_membership_outlined,
                color: AppColors.gray600,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'BISO Membership',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Get access to exclusive events, discounts, and more',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.onBuyMembership,
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Buy Membership'),
                style: FilledButton.styleFrom(
                  backgroundColor: widget.campusColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveMembershipCard(
    ThemeData theme,
    MembershipModel membership,
  ) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Card(
            elevation: 8,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.campusColor.withValues(alpha: 0.1),
                    AppColors.defaultGold.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header with animated verification badge
                    Row(
                      children: [
                        _buildAnimatedBadge(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'BISO Member',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: widget.campusColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.verified,
                                    color: AppColors.green9,
                                    size: 20,
                                  ),
                                ],
                              ),
                              Text(
                                membership.displayName,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Membership details with anti-tampering elements
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.campusColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Valid Until',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                membership.expiryDate != null
                                    ? _formatDate(membership.expiryDate!)
                                    : 'No expiry',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Member Since',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                membership.createdAt != null
                                    ? _formatDate(membership.createdAt!)
                                    : 'Unknown',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Anti-tampering verification code
                          _buildVerificationCode(membership),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Benefits preview
                    _buildBenefitsPreview(theme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpiredMembershipCard(
    ThemeData theme,
    MembershipModel membership,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.orange9.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.schedule,
                color: AppColors.orange9,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Membership Expired',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${membership.displayName} membership expired${membership.expiryDate != null ? ' on ${_formatDate(membership.expiryDate!)}' : ''}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.onBuyMembership,
                icon: const Icon(Icons.refresh),
                label: const Text('Renew Membership'),
                style: FilledButton.styleFrom(
                  backgroundColor: widget.campusColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBadge() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.campusColor, AppColors.defaultGold],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Shimmer effect
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Transform.translate(
                    offset: Offset(_shimmerAnimation.value * 60, 0),
                    child: Container(
                      width: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Icon
              const Center(
                child: Icon(
                  Icons.card_membership,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerificationCode(MembershipModel membership) {
    // Generate a unique verification pattern based on membership data
    final verificationCode = _generateVerificationCode(membership);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.campusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.security, size: 16, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            'ID: $verificationCode',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: verificationCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Verification code copied'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Icon(
              Icons.copy,
              size: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsPreview(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.green9.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.green9.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.green9, size: 20),
              const SizedBox(width: 8),
              Text(
                'Member Benefits Active',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.green9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Event access • Expense reimbursements • Marketplace discounts • Priority support',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _generateVerificationCode(MembershipModel membership) {
    // Create a deterministic but hard-to-reverse verification code
    final dataString =
        '${membership.id}${membership.category}${membership.expiryDate?.millisecondsSinceEpoch ?? 0}';
    var hash = 0;

    for (int i = 0; i < dataString.length; i++) {
      hash = ((hash << 5) - hash + dataString.codeUnitAt(i)) & 0xffffffff;
    }

    // Convert to a readable format with letters and numbers
    final code = (hash.abs() % 100000000).toString().padLeft(8, '0');
    return '${code.substring(0, 4)}-${code.substring(4)}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

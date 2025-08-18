import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../providers/campus/campus_provider.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../../data/models/student_id_model.dart';
import '../../widgets/show_membership_purchase_modal.dart';

class StudentIdScreen extends ConsumerStatefulWidget {
  const StudentIdScreen({super.key});

  @override
  ConsumerState<StudentIdScreen> createState() => _StudentIdScreenState();
}

class _StudentIdScreenState extends ConsumerState<StudentIdScreen> {

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final studentRecord = authState.studentRecord;
    final hasStudentId = authState.hasStudentId;
    final isStudentVerified = authState.isStudentVerified;
    final isStudentMember = authState.isStudentMember;
    final hasValidMembership = authState.hasValidMembership;
    final membershipStatus = authState.membershipStatus;
    final selectedCampus = ref.watch(selectedCampusProvider);
    final campusColor = _getCampusColor(selectedCampus.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Verification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationUtils.safeGoBack(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Premium Header Card with Animation
            _PremiumHeaderCard(
              campusColor: campusColor,
              campusName: selectedCampus.name,
            ),

            const SizedBox(height: 24),

            if (authState.isLoading)
              _LoadingCard(campusColor: campusColor)
            else if (authState.error != null)
              _ErrorCard(
                error: authState.error!,
                onRetry: () => ref.read(authStateProvider.notifier).refreshProfile(),
                campusColor: campusColor,
              )
            else if (!hasStudentId)
              _RegisterStudentIdSection(
                onOAuthRegistration: () => _registerStudentIdOAuth(),
                campusColor: campusColor,
              )
            else
              _StudentStatusCard(
                studentRecord: studentRecord!,
                campusName: selectedCampus.name,
                campusColor: campusColor,
                isVerified: isStudentVerified,
                isMember: isStudentMember,
                hasValidMembership: hasValidMembership,
                membershipStatus: membershipStatus,
                expiryDate: authState.membershipVerification?.membership?.expiryDate,
                onCheckMembership: () => _checkMembershipStatus(),
                onPurchaseMembership: () => _purchaseMembership(),
                onRemove: () => _removeStudentId(),
              ),

            const SizedBox(height: 24),

            // Premium Benefits Section
            _PremiumBenefitsSection(
              campusColor: campusColor,
              hasValidMembership: hasValidMembership,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  

  Color _getCampusColor(String campusId) {
    switch (campusId) {
      case 'oslo':
        return AppColors.defaultBlue;
      case 'bergen':
        return AppColors.green9;
      case 'trondheim':
        return AppColors.purple9;
      case 'stavanger':
        return AppColors.orange9;
      default:
        return AppColors.gray400;
    }
  }

  void _registerStudentIdOAuth() {
    ref.read(authStateProvider.notifier).registerStudentIdViaOAuth();
  }

  void _checkMembershipStatus() {
    ref.read(authStateProvider.notifier).checkMembershipStatus();
  }

  void _purchaseMembership() {
    final authState = ref.read(authStateProvider);
    final studentNumber = authState.studentNumber;
    final selectedCampus = ref.read(selectedCampusProvider);
    final campusColor = _getCampusColor(selectedCampus.id);

    if (studentNumber == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please register your student ID first.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    showMembershipPurchaseModal(
      context,
      ref,
      studentId: studentNumber,
      campusColor: campusColor,
    );
  }

  void _removeStudentId() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Student ID'),
        content: const Text('Are you sure you want to remove your student ID? This will remove your verified status and access to student benefits.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authStateProvider.notifier).removeStudentId();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

// Premium UI Components

class _PremiumHeaderCard extends StatelessWidget {
  final Color campusColor;
  final String campusName;

  const _PremiumHeaderCard({
    required this.campusColor,
    required this.campusName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            campusColor,
            campusColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: campusColor.withValues(alpha: 0.3),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.verified_user,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Student Verification',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Verify your BI $campusName student status and unlock exclusive features, membership benefits, and campus-wide access.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final Color campusColor;

  const _LoadingCard({required this.campusColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            CircularProgressIndicator(color: campusColor),
            const SizedBox(height: 16),
            Text(
              'Loading student information...',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final Color campusColor;

  const _ErrorCard({
    required this.error,
    required this.onRetry,
    required this.campusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: campusColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterStudentIdSection extends StatelessWidget {
  final VoidCallback onOAuthRegistration;
  final Color campusColor;

  const _RegisterStudentIdSection({
    required this.onOAuthRegistration,
    required this.campusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Verify Your Student Status',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: campusColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Connect with your BI student account for instant verification and access to exclusive member features.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // OAuth Registration Card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    campusColor.withValues(alpha: 0.15),
                    campusColor.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: campusColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: campusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.verified_user,
                      color: campusColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sign In with BI Account',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: campusColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use your @bi.no email for secure, instant verification. This ensures your student ID belongs to you.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onOAuthRegistration,
                    icon: const Icon(Icons.login),
                    label: const Text('Connect BI Account'),
                    style: FilledButton.styleFrom(
                      backgroundColor: campusColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Security Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blue1.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.blue6.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: AppColors.blue9,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure Verification',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.blue9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your credentials are processed securely through BI\'s official authentication system. We never store your password.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.blue8,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Benefits Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.green1.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.green6.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.green9,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Unlock After Verification',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.green9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Check membership status\n• Purchase BISO membership\n• Access exclusive features\n• Expense reimbursements',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.green8,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentStatusCard extends StatelessWidget {
  final StudentIdModel studentRecord;
  final String campusName;
  final Color campusColor;
  final bool isVerified;
  final bool isMember;
  final bool hasValidMembership;
  final String membershipStatus;
  final DateTime? expiryDate;
  final VoidCallback onCheckMembership;
  final VoidCallback onPurchaseMembership;
  final VoidCallback onRemove;

  const _StudentStatusCard({
    required this.studentRecord,
    required this.campusName,
    required this.campusColor,
    required this.isVerified,
    required this.isMember,
    required this.hasValidMembership,
    required this.membershipStatus,
    required this.expiryDate,
    required this.onCheckMembership,
    required this.onPurchaseMembership,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String formatExpiryDate(DateTime date) {
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      final d = date.day.toString().padLeft(2, '0');
      final m = months[date.month - 1];
      final y = date.year.toString();
      return '$d $m $y';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              campusColor.withValues(alpha: 0.05),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Student ID Header
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        campusColor,
                        campusColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentRecord.studentNumber,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'BI $campusName',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  isVerified: isVerified,
                  hasValidMembership: hasValidMembership,
                  membershipStatus: membershipStatus,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Verification Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isVerified 
                  ? AppColors.green1.withValues(alpha: 0.5)
                  : AppColors.orange1.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isVerified 
                    ? AppColors.green6.withValues(alpha: 0.3)
                    : AppColors.orange6.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isVerified ? Icons.verified : Icons.pending,
                    color: isVerified ? AppColors.green9 : AppColors.orange9,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVerified ? 'Verified Student' : 'Verification Pending',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: isVerified ? AppColors.green9 : AppColors.orange9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isVerified 
                            ? 'Your student status has been confirmed'
                            : 'Please verify your student status to unlock features',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Membership Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasValidMembership 
                  ? AppColors.green1.withValues(alpha: 0.5)
                  : AppColors.gray100.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasValidMembership 
                    ? AppColors.green6.withValues(alpha: 0.3)
                    : AppColors.gray300.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasValidMembership ? Icons.card_membership : Icons.card_membership_outlined,
                    color: hasValidMembership ? AppColors.green9 : AppColors.gray400,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          membershipStatus,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: hasValidMembership ? AppColors.green9 : AppColors.gray600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hasValidMembership && expiryDate != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Valid until: ${formatExpiryDate(expiryDate!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        Text(
                          hasValidMembership 
                            ? 'Access to all premium features and events'
                            : 'Purchase membership to unlock exclusive benefits',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (isVerified && !hasValidMembership) ...[
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onPurchaseMembership,
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Purchase Membership'),
                      style: FilledButton.styleFrom(
                        backgroundColor: campusColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: onCheckMembership,
                    child: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ] else if (isVerified && hasValidMembership) ...[
              OutlinedButton.icon(
                onPressed: onCheckMembership,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Status'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: campusColor,
                  side: BorderSide(color: campusColor),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Remove Button
            TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              label: const Text('Remove Student ID', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isVerified;
  final bool hasValidMembership;
  final String membershipStatus;

  const _StatusBadge({
    required this.isVerified,
    required this.hasValidMembership,
    required this.membershipStatus,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    if (hasValidMembership) {
      backgroundColor = AppColors.green9;
      textColor = Colors.white;
      text = 'Member';
    } else if (isVerified) {
      backgroundColor = AppColors.blue9;
      textColor = Colors.white;
      text = 'Verified';
    } else {
      backgroundColor = AppColors.orange9;
      textColor = Colors.white;
      text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PremiumBenefitsSection extends StatelessWidget {
  final Color campusColor;
  final bool hasValidMembership;

  const _PremiumBenefitsSection({
    required this.campusColor,
    required this.hasValidMembership,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasValidMembership ? 'Your Member Benefits' : 'Unlock These Benefits',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: campusColor,
          ),
        ),

        const SizedBox(height: 16),

        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _BenefitItem(
                  icon: Icons.chat,
                  title: 'Exclusive Chat Channels',
                  description: 'Access to member-only discussion groups',
                  campusColor: campusColor,
                  isUnlocked: hasValidMembership,
                ),
                const SizedBox(height: 20),
                _BenefitItem(
                  icon: Icons.receipt_long,
                  title: 'Expense Reimbursement',
                  description: 'Submit and track your expense claims',
                  campusColor: campusColor,
                  isUnlocked: hasValidMembership,
                ),
                const SizedBox(height: 20),
                _BenefitItem(
                  icon: Icons.local_offer,
                  title: 'Member Discounts',
                  description: 'Exclusive deals on marketplace items',
                  campusColor: campusColor,
                  isUnlocked: hasValidMembership,
                ),
                const SizedBox(height: 20),
                _BenefitItem(
                  icon: Icons.event,
                  title: 'Priority Event Access',
                  description: 'Early registration for popular events',
                  campusColor: campusColor,
                  isUnlocked: hasValidMembership,
                ),
                const SizedBox(height: 20),
                _BenefitItem(
                  icon: Icons.workspace_premium,
                  title: 'Premium Features',
                  description: 'Advanced app features and tools',
                  campusColor: campusColor,
                  isUnlocked: hasValidMembership,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color campusColor;
  final bool isUnlocked;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.campusColor,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isUnlocked 
              ? campusColor.withValues(alpha: 0.15)
              : AppColors.gray100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isUnlocked ? campusColor : AppColors.gray400,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isUnlocked ? null : AppColors.gray600,
                    ),
                  ),
                  if (isUnlocked) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.check_circle,
                      color: AppColors.green9,
                      size: 16,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isUnlocked ? AppColors.onSurfaceVariant : AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/student_id_model.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../providers/campus/campus_provider.dart';

// Provider for student ID state
final studentIdProvider = StateNotifierProvider<StudentIdNotifier, StudentIdState>((ref) {
  return StudentIdNotifier();
});

class StudentIdState {
  final StudentIdModel? studentId;
  final bool isLoading;
  final String? error;
  final bool isVerified;

  const StudentIdState({
    this.studentId,
    this.isLoading = false,
    this.error,
    this.isVerified = false,
  });

  StudentIdState copyWith({
    StudentIdModel? studentId,
    bool? isLoading,
    String? error,
    bool? isVerified,
  }) {
    return StudentIdState(
      studentId: studentId ?? this.studentId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class StudentIdNotifier extends StateNotifier<StudentIdState> {
  StudentIdNotifier() : super(const StudentIdState());

  Future<void> loadStudentId(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Implement Appwrite integration
      // For now, simulate loading
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data - replace with actual Appwrite call
      final mockStudentId = StudentIdModel(
        id: 'student_1',
        userId: userId,
        studentNumber: 's123456',
        isVerified: false,
        createdAt: DateTime.now(),
      );
      
      state = state.copyWith(
        studentId: mockStudentId,
        isLoading: false,
        isVerified: mockStudentId.isVerified,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addStudentId(String studentNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Implement Appwrite integration
      await Future.delayed(const Duration(seconds: 2));
      
      final newStudentId = StudentIdModel(
        id: 'student_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user',
        studentNumber: studentNumber,
        isVerified: false,
        createdAt: DateTime.now(),
      );
      
      state = state.copyWith(
        studentId: newStudentId,
        isLoading: false,
        isVerified: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> requestVerification() async {
    if (state.studentId == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Implement verification request
      await Future.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(isLoading: false);
      
      // Show success message - this would normally be handled by UI
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> removeStudentId() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Implement removal
      await Future.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(
        studentId: null,
        isLoading: false,
        isVerified: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

class StudentIdScreen extends ConsumerStatefulWidget {
  const StudentIdScreen({super.key});

  @override
  ConsumerState<StudentIdScreen> createState() => _StudentIdScreenState();
}

class _StudentIdScreenState extends ConsumerState<StudentIdScreen> {
  final _studentNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load existing student ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).user;
      if (user != null) {
        ref.read(studentIdProvider.notifier).loadStudentId(user.id);
      }
    });
  }

  @override
  void dispose() {
    _studentNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentIdState = ref.watch(studentIdProvider);
    final selectedCampus = ref.watch(selectedCampusProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student ID'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              color: _getCampusColor(selectedCampus.id).withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _getCampusColor(selectedCampus.id),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Student Verification',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verify your student status to access exclusive features and benefits',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (studentIdState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (studentIdState.error != null)
              _ErrorCard(
                error: studentIdState.error!,
                onRetry: () {
                  final user = authState.user;
                  if (user != null) {
                    ref.read(studentIdProvider.notifier).loadStudentId(user.id);
                  }
                },
              )
            else if (studentIdState.studentId == null)
              _AddStudentIdForm(
                formKey: _formKey,
                controller: _studentNumberController,
                onSubmit: () => _addStudentId(),
                campusColor: _getCampusColor(selectedCampus.id),
              )
            else
              _StudentIdCard(
                studentId: studentIdState.studentId!,
                isVerified: studentIdState.isVerified,
                campusName: selectedCampus.name,
                campusColor: _getCampusColor(selectedCampus.id),
                onRequestVerification: () => _requestVerification(),
                onRemove: () => _removeStudentId(),
              ),

            const SizedBox(height: 24),

            // Benefits Section
            _BenefitsSection(campusColor: _getCampusColor(selectedCampus.id)),
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

  void _addStudentId() {
    if (_formKey.currentState!.validate()) {
      ref.read(studentIdProvider.notifier).addStudentId(_studentNumberController.text.trim());
    }
  }

  void _requestVerification() {
    ref.read(studentIdProvider.notifier).requestVerification();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification request submitted! You will receive an email with next steps.'),
        backgroundColor: AppColors.green9,
      ),
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
              ref.read(studentIdProvider.notifier).removeStudentId();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _AddStudentIdForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final Color campusColor;

  const _AddStudentIdForm({
    required this.formKey,
    required this.controller,
    required this.onSubmit,
    required this.campusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add Student Number',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.strongBlue,
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Student Number',
              hintText: 's123456',
              prefixIcon: const Icon(Icons.badge_outlined),
              helperText: 'Enter your BI student number (starts with "s")',
            ),
            textCapitalization: TextCapitalization.none,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Student number is required';
              }
              if (!value.toLowerCase().startsWith('s')) {
                return 'Student number should start with "s"';
              }
              if (value.length < 6) {
                return 'Student number is too short';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: onSubmit,
            icon: const Icon(Icons.add),
            label: const Text('Add Student ID'),
            style: FilledButton.styleFrom(
              backgroundColor: campusColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentIdCard extends StatelessWidget {
  final StudentIdModel studentId;
  final bool isVerified;
  final String campusName;
  final Color campusColor;
  final VoidCallback onRequestVerification;
  final VoidCallback onRemove;

  const _StudentIdCard({
    required this.studentId,
    required this.isVerified,
    required this.campusName,
    required this.campusColor,
    required this.onRequestVerification,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isVerified ? AppColors.green9 : AppColors.orange9,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isVerified ? Icons.verified : Icons.pending,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentId.studentNumber,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isVerified ? AppColors.green9 : AppColors.orange9).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isVerified ? 'Verified' : 'Pending',
                    style: TextStyle(
                      color: isVerified ? AppColors.green9 : AppColors.orange9,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            if (!isVerified) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.orange9.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.orange9, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Verification Pending',
                            style: TextStyle(
                              color: AppColors.orange9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your student status needs to be verified to access all features. Click below to request verification.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRequestVerification,
                      icon: const Icon(Icons.send),
                      label: const Text('Request Verification'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    tooltip: 'Remove Student ID',
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.green9.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.green9, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verified Student',
                            style: TextStyle(
                              color: AppColors.green9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'You have full access to student features and benefits.',
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

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  label: const Text('Remove', style: TextStyle(color: AppColors.error)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BenefitsSection extends StatelessWidget {
  final Color campusColor;

  const _BenefitsSection({required this.campusColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Student Benefits',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.strongBlue,
          ),
        ),

        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _BenefitItem(
                  icon: Icons.chat,
                  title: 'Student Chat',
                  description: 'Access to exclusive student chat channels',
                  campusColor: campusColor,
                ),
                const SizedBox(height: 16),
                _BenefitItem(
                  icon: Icons.receipt,
                  title: 'Expense Reimbursement',
                  description: 'Submit and track expense reimbursements',
                  campusColor: campusColor,
                ),
                const SizedBox(height: 16),
                _BenefitItem(
                  icon: Icons.local_offer,
                  title: 'Student Discounts',
                  description: 'Access to student-only marketplace deals',
                  campusColor: campusColor,
                ),
                const SizedBox(height: 16),
                _BenefitItem(
                  icon: Icons.event,
                  title: 'Priority Events',
                  description: 'Early access to popular events and workshops',
                  campusColor: campusColor,
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

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.campusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: campusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: campusColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: AppColors.error.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'Error Loading Student ID',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
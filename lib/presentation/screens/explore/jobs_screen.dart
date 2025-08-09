import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../generated/l10n/app_localizations.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  String _selectedType = 'all';

  final List<String> _jobTypes = [
    'all',
    'volunteer',
    'paid',
    'internship',
  ];

  // Mock data for demonstration
  final List<Map<String, dynamic>> _mockJobs = [
    {
      'id': '1',
      'title': 'Event Photography Volunteer',
      'department': 'Marketing Committee',
      'type': 'volunteer',
      'category': 'event_help',
      'timeCommitment': '3-4 hours/event',
      'isUrgent': true,
      'applicationDeadline': DateTime.now().add(const Duration(days: 7)),
      'description': 'Help capture memorable moments at our campus events.',
      'skills': ['Photography', 'Adobe Lightroom', 'Creative Eye'],
      'benefits': ['Portfolio building', 'Event access', 'Certificate'],
    },
    {
      'id': '2',
      'title': 'Social Media Manager',
      'department': 'Student Union',
      'type': 'paid',
      'category': 'marketing',
      'timeCommitment': '10 hours/week',
      'salary': 'NOK 200/hour',
      'isUrgent': false,
      'applicationDeadline': DateTime.now().add(const Duration(days: 14)),
      'description': 'Manage social media accounts and create engaging content.',
      'skills': ['Social Media', 'Content Creation', 'Canva'],
      'benefits': ['Flexible schedule', 'Experience', 'References'],
    },
    {
      'id': '3',
      'title': 'IT Support Intern',
      'department': 'IT Services',
      'type': 'internship',
      'category': 'tech',
      'timeCommitment': '20 hours/week',
      'salary': 'NOK 180/hour',
      'isUrgent': false,
      'applicationDeadline': DateTime.now().add(const Duration(days: 21)),
      'description': 'Assist with IT support tasks and system maintenance.',
      'skills': ['Windows/Mac Support', 'Network Basics', 'Problem Solving'],
      'benefits': ['Real experience', 'Training', 'Future job opportunity'],
    },
    {
      'id': '4',
      'title': 'Orientation Week Helper',
      'department': 'Student Services',
      'type': 'volunteer',
      'category': 'event_help',
      'timeCommitment': 'One week commitment',
      'isUrgent': true,
      'applicationDeadline': DateTime.now().add(const Duration(days: 3)),
      'description': 'Help new students navigate their first week at BI.',
      'skills': ['Communication', 'Leadership', 'Norwegian/English'],
      'benefits': ['Leadership experience', 'Network building', 'Fun'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final filteredJobs = _selectedType == 'all'
        ? _mockJobs
        : _mockJobs.where((job) => job['type'] == _selectedType).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.volunteer),
        leading: IconButton(
          onPressed: () {
            // Navigate back to home screen (explore tab)
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_border),
          ),
        ],
      ),
      body: Column(
        children: [
          // Type Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _jobTypes.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final type = _jobTypes[index];
                final isSelected = _selectedType == type;

                return FilterChip(
                  label: Text(_getTypeDisplayName(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  backgroundColor: Colors.transparent,
                  selectedColor: AppColors.subtleBlue,
                  checkmarkColor: AppColors.defaultBlue,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.defaultBlue : AppColors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.defaultBlue : AppColors.outline,
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Jobs List
          Expanded(
            child: filteredJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 64,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No opportunities found',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try changing your filter or check back later',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredJobs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      return _JobCard(
                        job: job,
                        onTap: () => _showJobDetails(context, job),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post Opportunity - Coming Soon')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Post Job'),
        backgroundColor: AppColors.purple9,
      ),
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'all': return 'All';
      case 'volunteer': return 'Volunteer';
      case 'paid': return 'Paid';
      case 'internship': return 'Internship';
      default: return type;
    }
  }

  void _showJobDetails(BuildContext context, Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _JobDetailSheet(
          job: job,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onTap;

  const _JobCard({
    required this.job,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Department Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getTypeColor(job['type']).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTypeIcon(job['type']),
                      color: _getTypeColor(job['type']),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Job Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                job['title'],
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (job['isUrgent'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'URGENT',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          job['department'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getTypeColor(job['type']).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getTypeDisplayName(job['type']),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _getTypeColor(job['type']),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              job['timeCommitment'],
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),

                        if (job['salary'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            job['salary'],
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Skills Tags
              if (job['skills'] != null) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (job['skills'] as List<String>).take(3).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        skill,
                        style: theme.textTheme.labelSmall,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],

              // Application Deadline
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Apply by ${DateFormat('MMM dd').format(job['applicationDeadline'])}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'View Details',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.defaultBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.defaultBlue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'volunteer': return 'Volunteer';
      case 'paid': return 'Paid';
      case 'internship': return 'Internship';
      default: return type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'volunteer': return AppColors.success;
      case 'paid': return AppColors.defaultBlue;
      case 'internship': return AppColors.purple9;
      default: return AppColors.onSurfaceVariant;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'volunteer': return Icons.volunteer_activism;
      case 'paid': return Icons.work;
      case 'internship': return Icons.school;
      default: return Icons.work_outline;
    }
  }
}

class _JobDetailSheet extends StatelessWidget {
  final Map<String, dynamic> job;
  final ScrollController scrollController;

  const _JobDetailSheet({
    required this.job,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  job['title'],
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  job['department'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.defaultBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                // Job Info Cards
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.access_time,
                        label: 'Time Commitment',
                        value: job['timeCommitment'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.schedule,
                        label: 'Deadline',
                        value: DateFormat('MMM dd, yyyy').format(job['applicationDeadline']),
                      ),
                    ),
                  ],
                ),

                if (job['salary'] != null) ...[
                  const SizedBox(height: 12),
                  _InfoCard(
                    icon: Icons.payments,
                    label: 'Compensation',
                    value: job['salary'],
                  ),
                ],

                const SizedBox(height: 24),

                // Description
                Text(
                  'About this role',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  job['description'],
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 24),

                // Required Skills
                if (job['skills'] != null) ...[
                  Text(
                    'Required Skills',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (job['skills'] as List<String>).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.subtleBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          skill,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.defaultBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Benefits
                if (job['benefits'] != null) ...[
                  Text(
                    'What you get',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...((job['benefits'] as List<String>).map((benefit) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              benefit,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  })),
                  const SizedBox(height: 24),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.bookmark_border),
                        label: const Text('Save'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Application - Coming Soon')),
                          );
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('Apply Now'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
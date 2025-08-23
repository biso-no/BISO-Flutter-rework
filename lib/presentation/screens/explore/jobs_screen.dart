import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../providers/campus/campus_provider.dart';
import '../../../data/services/job_service.dart';
import '../../../data/models/job_model.dart';
import '../../widgets/premium/premium_html_renderer.dart';

// Providers
final _jobServiceProvider = Provider<JobService>((ref) => JobService());
// NOTE: Replaced one-shot provider with widget-managed pagination

class JobsScreen extends ConsumerStatefulWidget {
  final String? openJobId;
  const JobsScreen({super.key, this.openJobId});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  String _selectedType = 'all';
  bool _pendingAutoOpen = true;

  // Paging state
  final ScrollController _scrollController = ScrollController();
  final List<JobModel> _jobs = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 20;
  String? _loadedForCampusId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _ensureInitialLoad(String? campusId) async {
    if (_loadedForCampusId == campusId && _jobs.isNotEmpty) return;
    _loadedForCampusId = campusId;
    _isLoading = true;
    _jobs.clear();
    _currentPage = 1;
    _hasMore = true;
    if (mounted) setState(() {});
    await _fetchPage(page: 1, replace: true);
  }

  Future<void> _fetchPage({required int page, bool replace = false}) async {
    final campusId = ref.read(filterCampusProvider).id;
    final service = ref.read(_jobServiceProvider);
    try {
      final items = await service.getLatestJobs(
        campusId: campusId,
        limit: _pageSize,
        page: page,
        includeExpired: false,
      );
      if (mounted) {
        setState(() {
          if (replace) {
            _jobs
              ..clear()
              ..addAll(items);
            _isLoading = false;
          } else {
            _jobs.addAll(items);
            _isLoadingMore = false;
          }
          _hasMore = items.length >= _pageSize;
        });
      }
      // Auto-open after first batch
      if (_pendingAutoOpen && widget.openJobId != null && _jobs.isNotEmpty) {
        final matches = _jobs
            .where((j) => j.id.toString() == widget.openJobId)
            .toList(growable: false);
        if (matches.isNotEmpty) {
          _pendingAutoOpen = false;
          final jobToOpen = matches.first;
          Future.microtask(() => _showJobDetails(context, jobToOpen));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _hasMore = false;
        });
      }
    }
  }

  Future<void> _reload() async {
    _pendingAutoOpen = true;
    await _fetchPage(page: 1, replace: true);
    _currentPage = 1;
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    _currentPage += 1;
    await _fetchPage(page: _currentPage);
  }

  final List<String> _jobTypes = ['all', 'volunteer', 'paid'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final campusId = ref.watch(filterCampusProvider).id;
    // Ensure initial load for current campus
    _ensureInitialLoad(campusId);

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
          // IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          // IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
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
                    color: isSelected
                        ? AppColors.defaultBlue
                        : AppColors.onSurfaceVariant,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.defaultBlue
                        : AppColors.outline,
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Jobs List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _reload,
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: (_selectedType == 'all'
                              ? _jobs
                              : _jobs
                                  .where((j) => j.type == _selectedType)
                                  .toList())
                          .length + (_isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final filtered = _selectedType == 'all'
                            ? _jobs
                            : _jobs
                                .where((j) => j.type == _selectedType)
                                .toList();
                        if (index >= filtered.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final job = filtered[index];
                        return _JobCard(
                          job: job,
                          onTap: () => _showJobDetails(context, job),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'all':
        return 'All';
      case 'volunteer':
        return 'Volunteer';
      case 'paid':
        return 'Paid';
      default:
        return type;
    }
  }

  void _showJobDetails(BuildContext context, JobModel job) {
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
        builder: (context, scrollController) =>
            _JobDetailSheet(job: job, scrollController: scrollController),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;

  const _JobCard({required this.job, required this.onTap});

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
                      color: _getTypeColor(job.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTypeIcon(job.type),
                      color: _getTypeColor(job.type),
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
                              child: job.title.toCompactHtml(
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                fontSize: 16,
                              ),
                            ),
                            if (job.isUrgent == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
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
                          job.department,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getTypeColor(
                                  job.type,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getTypeDisplayName(job.type),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _getTypeColor(job.type),
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
                              job.timeCommitment ?? '—',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),

                        if (job.salary != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            job.salary!,
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
              if (job.skills.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: job.skills.take(3).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(skill, style: theme.textTheme.labelSmall),
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
                    'Apply by ${DateFormat('MMM dd').format(job.applicationDeadline)}',
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
      case 'volunteer':
        return 'Volunteer';
      case 'paid':
        return 'Paid';
      default:
        return type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'volunteer':
        return AppColors.success;
      case 'paid':
        return AppColors.defaultBlue;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'volunteer':
        return Icons.volunteer_activism;
      case 'paid':
        return Icons.work;
      default:
        return Icons.work_outline;
    }
  }
}

class _JobDetailSheet extends StatelessWidget {
  final JobModel job;
  final ScrollController scrollController;

  const _JobDetailSheet({required this.job, required this.scrollController});

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
                job.title.toFullHtml(
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  fontSize: 20,
                ),

                const SizedBox(height: 8),

                Text(
                  job.department,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.defaultBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                // Job Info Cards
                Row(
                  children: [
                    // Expanded(
                    //   child: _InfoCard(
                    //     icon: Icons.access_time,
                    //     label: 'Time Commitment',
                    //     value: job.timeCommitment ?? '—',
                    //   ),
                    // ),
                    // const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.schedule,
                        label: 'Deadline',
                        value: DateFormat(
                          'MMM dd, yyyy',
                        ).format(job.applicationDeadline),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Action Buttons - Below time commitment and deadline
                Row(
                  children: [
                    // Expanded(
                    //   child: OutlinedButton.icon(
                    //     onPressed: () {},
                    //     icon: const Icon(Icons.bookmark_border),
                    //     label: const Text('Save'),
                    //   ),
                    // ),
                    // const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          //Open the URL in the browser
                          launchUrl(Uri.parse(job.url));
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('Apply Now'),
                      ),
                    ),
                  ],
                ),

                if (job.salary != null) ...[
                  const SizedBox(height: 12),
                  _InfoCard(
                    icon: Icons.payments,
                    label: 'Compensation',
                    value: job.salary!,
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
                job.description.toFullHtml(
                  style: theme.textTheme.bodyMedium,
                  fontSize: 16,
                ),

                const SizedBox(height: 24),

                // Required Skills
                if (job.skills.isNotEmpty) ...[
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
                    children: job.skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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
                if (job.benefits.isNotEmpty) ...[
                  Text(
                    'What you get',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(job.benefits.map((benefit) {
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

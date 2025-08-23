import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../../data/models/event_model.dart';
import '../../../data/services/event_service.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../providers/campus/campus_provider.dart';

// Provider for EventService
final eventServiceProvider = Provider<EventService>((ref) => EventService());

// Search term for events (server-backed)
final eventsSearchTermProvider = StateProvider<String?>((ref) => null);

// Provider for events list
final eventsProvider = FutureProvider.family<List<EventModel>, String?>(
  (ref, campusId) {
    final service = ref.watch(eventServiceProvider);
    final searchTerm = ref.watch(eventsSearchTermProvider);
    // Use function-backed fetch with pagination params; initial page 1
    return service.getWordPressEvents(
      campusId: campusId,
      limit: 50,
      includePast: false,
      search: searchTerm,
    );
  },
);

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Paging state
  final ScrollController _scrollController = ScrollController();
  final List<EventModel> _events = [];
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
    _searchController.dispose();
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
    if (_loadedForCampusId == campusId && _events.isNotEmpty) return;
    _loadedForCampusId = campusId;
    _isLoading = true;
    _events.clear();
    _currentPage = 1;
    _hasMore = true;
    if (mounted) setState(() {});
    await _fetchPage(page: 1, replace: true);
  }

  Future<void> _fetchPage({required int page, bool replace = false}) async {
    final campusId = ref.read(filterCampusProvider).id;
    final service = ref.read(eventServiceProvider);
    final searchTerm = ref.read(eventsSearchTermProvider);
    try {
      final items = await service.getFunctionEvents(
        campusId: campusId,
        limit: _pageSize,
        page: page,
        includePast: false,
        search: searchTerm,
      );
      if (mounted) {
        setState(() {
          if (replace) {
            _events
              ..clear()
              ..addAll(items);
            _isLoading = false;
          } else {
            _events.addAll(items);
            _isLoadingMore = false;
          }
          _hasMore = items.length >= _pageSize;
        });
      }
    } catch (_) {
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
    await _fetchPage(page: 1, replace: true);
    _currentPage = 1;
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    _currentPage += 1;
    await _fetchPage(page: _currentPage);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final campusId = ref.watch(filterCampusProvider).id;
    _ensureInitialLoad(campusId);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.eventsMessage),
        leading: NavigationUtils.buildBackButton(context),
        actions: [
          IconButton(
            onPressed: () {
              _promptSearch(context);
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1),

          // Events List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Builder(builder: (context) {
                    final filteredEvents = _applyClientSearch(_events);

                    if (filteredEvents.isEmpty) {
                      return _EmptyState(
                        icon: Icons.event_busy,
                        title: 'No Events Found',
                        subtitle: 'There are no events matching your criteria.',
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _reload,
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredEvents.length + (_isLoadingMore ? 1 : 0),
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index >= filteredEvents.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final event = filteredEvents[index];
                          return _EventCard(
                            event: event,
                            onTap: () {
                              _showEventDetails(context, event);
                            },
                          );
                        },
                      ),
                    );
                  }),
          ),
        ],
      ),
    );
  }

  List<EventModel> _applyClientSearch(List<EventModel> events) {
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isEmpty) return events;
    return events.where((event) {
      return event.title.toLowerCase().contains(searchQuery) ||
          event.description.toLowerCase().contains(searchQuery) ||
          event.organizerName.toLowerCase().contains(searchQuery);
    }).toList();
  }

  void _showEventDetails(BuildContext context, EventModel event) {
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
            _EventDetailSheet(event: event, scrollController: scrollController),
      ),
    );
  }

  Future<void> _promptSearch(BuildContext context) async {
    final current = ref.read(eventsSearchTermProvider);
    final controller = TextEditingController(text: current ?? _searchController.text);
    final result = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search events'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Type at least 2 characters',
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            if ((current ?? '').isNotEmpty)
              TextButton(
                onPressed: () => Navigator.of(context).pop(''),
                child: const Text('Clear'),
              ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Search'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (result == null) return; // cancelled

    final trimmed = result.trim();
    if (trimmed.isEmpty) {
      // clear search
      ref.read(eventsSearchTermProvider.notifier).state = null;
      _searchController.text = '';
    } else if (trimmed.length >= 2) {
      ref.read(eventsSearchTermProvider.notifier).state = trimmed;
      _searchController.text = trimmed; // keep local for client-side refine
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search must be at least 2 characters')),
      );
      return;
    }

    // reload with new search param
    await _reload();
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.onTap});

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
                  // Event Image or Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.subtleBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: event.images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              event.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.event,
                                    color: AppColors.defaultBlue,
                                  ),
                            ),
                          )
                        : const Icon(Icons.event, color: AppColors.defaultBlue),
                  ),

                  const SizedBox(width: 12),

                  // Event Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          event.organizerName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat(
                                'MMM dd, HH:mm',
                              ).format(event.startDate),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.venue,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        event.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(event.status),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(event.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              if (event.categories.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: event.categories.take(3).map((category) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(category, style: theme.textTheme.labelSmall),
                    );
                  }).toList(),
                ),
              ],

              if (event.price != null && event.price! > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'NOK ${event.price!.toStringAsFixed(0)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.defaultBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return AppColors.accentBlue;
      case 'ongoing':
        return AppColors.success;
      case 'completed':
        return AppColors.onSurfaceVariant;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'upcoming':
        return 'Upcoming';
      case 'ongoing':
        return 'Live';
      case 'completed':
        return 'Ended';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

class _EventDetailSheet extends StatelessWidget {
  final EventModel event;
  final ScrollController scrollController;

  const _EventDetailSheet({
    required this.event,
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
                  event.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Event Info Row
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 20,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat(
                        'EEEE, MMM dd, yyyy • HH:mm',
                      ).format(event.startDate),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 20,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.venue,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.group,
                      size: 20,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Organized by ${event.organizerName}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Description
                Text(
                  'About',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(event.description, style: theme.textTheme.bodyMedium),

                const SizedBox(height: 24),

                // Registration Info
                if (event.requiresRegistration) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.subtleBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registration Required',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.defaultBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (event.maxAttendees > 0)
                          Text(
                            '${event.currentAttendees}/${event.maxAttendees} registered',
                            style: theme.textTheme.bodySmall,
                          ),
                        if (event.registrationDeadline != null)
                          Text(
                            'Deadline: ${DateFormat('MMM dd, yyyy').format(event.registrationDeadline!)}',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final url = event.registrationUrl;
                          if (url != null && url.isNotEmpty) {
                            launchUrl(Uri.parse(url));
                          }
                        },
                        icon: const Icon(Icons.web),
                        label: const Text('View on Biso.no'),
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Removed old _ErrorState (not used with widget-managed pagination)

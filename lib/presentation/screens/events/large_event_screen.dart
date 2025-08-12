import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/large_event_model.dart';
import '../../../providers/campus/campus_provider.dart';
import '../../../providers/large_event/large_event_items_provider.dart';

class LargeEventScreen extends ConsumerWidget {
  final LargeEventModel event;
  const LargeEventScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campus = ref.watch(filterCampusProvider);
    final cfg = event.campusConfig(campus.id);
    final gradient = event.gradientColors;
    // final textColor = event.textColor; // reserved for future use in content blocks

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(event.name),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (event.backgroundImageUrl != null && event.backgroundImageUrl!.isNotEmpty)
                    Image.network(event.backgroundImageUrl!, fit: BoxFit.cover)
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradient,
                        ),
                      ),
                    ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event.logoUrl != null && event.logoUrl!.isNotEmpty)
                        Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Image.network(event.logoUrl!, fit: BoxFit.contain),
                        ),
                      if (event.logoUrl != null && event.logoUrl!.isNotEmpty)
                        const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(event.description),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _DatePills(from: event.startDate, to: event.endDate, color: event.primaryColor),

                  const SizedBox(height: 24),
                  if (cfg != null) _TicketingSection(cfg: cfg, accent: event.primaryColor),

                  const SizedBox(height: 24),
                  // Prefer subevents from collection; fallback to embedded schedule
                  Consumer(builder: (context, ref, _) {
                    final state = ref.watch(largeEventItemsProvider((eventId: event.id, campusId: campus.id)));
                    final hasItems = state.items.isNotEmpty;
                    final items = hasItems ? state.items : (cfg?.schedule ?? []);
                    if (items.isEmpty) return const SizedBox.shrink();
                    return _ScheduleList(items: items);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePills extends StatelessWidget {
  final DateTime from;
  final DateTime to;
  final Color color;
  const _DatePills({required this.from, required this.to, required this.color});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
          child: Text('${from.day}.${from.month}.${from.year}', style: style),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward, size: 16),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
          child: Text('${to.day}.${to.month}.${to.year}', style: style),
        ),
      ],
    );
  }
}

class _TicketingSection extends StatelessWidget {
  final LargeEventCampusConfig cfg;
  final Color accent;
  const _TicketingSection({required this.cfg, required this.accent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (cfg.ticketingModel) {
      case LargeEventTicketingModel.allAccess:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('All-Access Pass', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('One ticket grants access to all events on this campus.'),
                const SizedBox(height: 12),
                if (cfg.allAccessPassUrl != null)
                  FilledButton(
                    onPressed: () => launchUrl(Uri.parse(cfg.allAccessPassUrl!)),
                    style: FilledButton.styleFrom(backgroundColor: accent),
                    child: const Text('Buy Pass'),
                  ),
                if (cfg.ticketPortalUrl != null)
                  TextButton(
                    onPressed: () => launchUrl(Uri.parse(cfg.ticketPortalUrl!)),
                    child: const Text('Open Ticket Portal'),
                  ),
              ],
            ),
          ),
        );
      case LargeEventTicketingModel.perEvent:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Events & Tickets', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  for (final item in cfg.schedule)
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.event)),
                      title: Text(item.title),
                      subtitle: Text(_formatScheduleSubtitle(item)),
                      trailing: item.ticketUrl != null
                          ? FilledButton(
                              onPressed: () => launchUrl(Uri.parse(item.ticketUrl!)),
                              style: FilledButton.styleFrom(backgroundColor: accent),
                              child: const Text('Tickets'),
                            )
                          : null,
                    ),
                ],
              ),
            ),
          ],
        );
    }
  }

  String _formatScheduleSubtitle(LargeEventScheduleItem item) {
    final start = item.startTime;
    final end = item.endTime;
    final date = '${start.day}.${start.month}.${start.year}';
    final time = end != null ? '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}' : '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final loc = item.location != null ? ' • ${item.location}' : '';
    return '$date • $time$loc';
  }
}

class _ScheduleList extends StatelessWidget {
  final List<LargeEventScheduleItem> items;
  const _ScheduleList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Schedule', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final item in items)
          Card(
            child: ListTile(
              title: Text(item.title),
              subtitle: Text(item.subtitle ?? ''),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
      ],
    );
  }
}



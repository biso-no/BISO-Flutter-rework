import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

import '../../../core/constants/app_colors.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../providers/large_event/large_event_provider.dart';
import '../../../data/models/large_event_model.dart';
import '../../../providers/campus/campus_provider.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    Future<void> openDirections(String address) async {
      final encoded = Uri.encodeComponent(address);
      Uri uri;
      if (Platform.isIOS) {
        uri = Uri.parse('http://maps.apple.com/?q=$encoded');
      } else if (Platform.isAndroid) {
        uri = Uri.parse('geo:0,0?q=$encoded');
      } else {
        uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    String resolveCampusEmail(String campusId) {
      switch (campusId.toLowerCase()) {
        case '1':
        case 'oslo':
          return 'president.oslo@biso.no';
        case '2':
        case 'bergen':
          return 'president.bergen@biso.no';
        case '3':
        case 'trondheim':
          return 'president.trondheim@biso.no';
        case '4':
        case 'stavanger':
          return 'president.stavanger@biso.no';
        default:
          return 'contact@biso.no';
      }
    }

    Future<void> openEmail(String email) async {
      final uri = Uri(scheme: 'mailto', path: email);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.explore),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured Large Event banner
            Consumer(
              builder: (context, ref, _) {
                final LargeEventModel? event = ref.watch(
                  featuredLargeEventProvider,
                );
                if (event == null) return const SizedBox.shrink();
                return _LargeEventBanner(event: event);
              },
            ),

            const SizedBox(height: 16),
            Text(
              'Categories',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Main Categories Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _CategoryCard(
                  icon: Icons.event,
                  title: l10n.events,
                  subtitle: 'Campus events & activities',
                  color: AppColors.accentBlue,
                  onTap: () => context.go('/explore/events'),
                ),
                _CategoryCard(
                  icon: Icons.departure_board,
                  title: 'Departures',
                  subtitle: 'Realtime bus & metro',
                  color: AppColors.defaultBlue,
                  onTap: () => context.go('/explore/departures'),
                ),
                _CategoryCard(
                  icon: Icons.shopping_bag,
                  title: l10n.bisoShop,
                  subtitle: 'Buy & sell items',
                  color: AppColors.green9,
                  onTap: () => context.go('/explore/products'),
                ),
                _CategoryCard(
                  icon: Icons.groups,
                  title: l10n.clubsAndUnits,
                  subtitle: 'Student organizations',
                  color: AppColors.purple9,
                  onTap: () => context.go('/explore/units'),
                ),
                _CategoryCard(
                  icon: Icons.receipt_long,
                  title: l10n.expenses,
                  subtitle: 'Expense reimbursements',
                  color: AppColors.orange9,
                  onTap: () => context.go('/explore/expenses'),
                ),
                _CategoryCard(
                  icon: Icons.volunteer_activism,
                  title: l10n.volunteer,
                  subtitle: 'Volunteer opportunities',
                  color: AppColors.pink9,
                  onTap: () => context.go('/explore/volunteer'),
                ),
                _CategoryCard(
                  icon: Icons.chat,
                  title: 'AI Assistant',
                  subtitle: 'Get help & information',
                  color: AppColors.defaultGold,
                  onTap: () => context.go('/explore/ai-chat'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Quick Links Section
            Text(
              'Quick Links',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.subtleBlue,
                      child: Icon(
                        Icons.web,
                        color: AppColors.defaultBlue,
                      ),
                    ),
                    title: const Text('BISO.no'),
                    subtitle: const Text('Visit our website'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      launchUrl(Uri.parse('https://biso.no'));
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.subtleBlue,
                      child: Icon(
                        Icons.calendar_today,
                        color: AppColors.defaultBlue,
                      ),
                    ),
                    title: const Text('Academic Calendar'),
                    subtitle: const Text('View important dates'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      launchUrl(
                        Uri.parse(
                          'https://www.bi.no/en/study-at-bi/international-students/practical-info/academic-calendar/',
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.subtleBlue,
                      child: Icon(
                        Icons.library_books,
                        color: AppColors.defaultBlue,
                      ),
                    ),
                    title: const Text('Library Services'),
                    subtitle: const Text('Book rooms & resources'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      launchUrl(
                        Uri.parse('https://www.bi.no/en/research/library'),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.subtleBlue,
                      child: Icon(
                        Icons.support_agent,
                        color: AppColors.defaultBlue,
                      ),
                    ),
                    title: const Text('Student Support'),
                    subtitle: const Text('Get help & guidance'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Campus Information
            Text(
              'Campus Information',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Consumer(
              builder: (context, ref, _) {
                final campus = ref.watch(filterCampusProvider);
                final contactEmail = resolveCampusEmail(campus.id);
                const campusAddress = 'Nydalsveien 37, 0484 Oslo';

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppColors.defaultBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Oslo Campus',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(campusAddress),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => openDirections(campusAddress),
                              icon: const Icon(Icons.directions),
                              label: const Text('Directions'),
                            ),
                            TextButton.icon(
                              onPressed: () => openEmail(contactEmail),
                              icon: const Icon(Icons.mail),
                              label: const Text('Contact'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8), // Reduced from 12 to 8
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2), // Reduced from 4 to 2
              Expanded(
                child: Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LargeEventBanner extends StatelessWidget {
  final LargeEventModel event;
  const _LargeEventBanner({required this.event});

  @override
  Widget build(BuildContext context) {
    final gradient = event.gradientColors;
    return GestureDetector(
      onTap: () => context.push('/events/large/${event.slug}', extra: event),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: event.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: event.textColor.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../generated/l10n/app_localizations.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.explore),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  onTap: () {},
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
                      child: Icon(Icons.calendar_today, color: AppColors.defaultBlue),
                    ),
                    title: const Text('Academic Calendar'),
                    subtitle: const Text('View important dates'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.subtleBlue,
                      child: Icon(Icons.library_books, color: AppColors.defaultBlue),
                    ),
                    title: const Text('Library Services'),
                    subtitle: const Text('Book rooms & resources'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.subtleBlue,
                      child: Icon(Icons.support_agent, color: AppColors.defaultBlue),
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

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.defaultBlue),
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
                    const Text('Nydalsveien 37, 0484 Oslo'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.directions),
                          label: const Text('Directions'),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone),
                          label: const Text('Contact'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
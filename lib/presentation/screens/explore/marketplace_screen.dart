import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../generated/l10n/app_localizations.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedCategory = 'all';

  final List<String> _categories = [
    'all',
    'books',
    'electronics',
    'furniture',
    'clothes',
    'sports',
    'other',
  ];

  // Mock data for demonstration
  final List<Map<String, dynamic>> _mockProducts = [
    {
      'id': '1',
      'name': 'Marketing Textbook',
      'price': 450.0,
      'seller': 'Anna K.',
      'condition': 'Good',
      'category': 'books',
      'image': null,
    },
    {
      'id': '2',
      'name': 'MacBook Pro 13"',
      'price': 12000.0,
      'seller': 'Erik S.',
      'condition': 'Like New',
      'category': 'electronics',
      'image': null,
    },
    {
      'id': '3',
      'name': 'Desk Lamp',
      'price': 150.0,
      'seller': 'Maria L.',
      'condition': 'Good',
      'category': 'furniture',
      'image': null,
    },
    {
      'id': '4',
      'name': 'Business Suit',
      'price': 800.0,
      'seller': 'John D.',
      'condition': 'Like New',
      'category': 'clothes',
      'image': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final filteredProducts = _selectedCategory == 'all'
        ? _mockProducts
        : _mockProducts.where((p) => p['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.marketplace),
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
            icon: const Icon(Icons.favorite_border),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return FilterChip(
                  label: Text(_getCategoryDisplayName(category)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
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

          // Products Grid
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items found',
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
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _ProductCard(product: product);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sell Item - Coming Soon')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Sell Item'),
        backgroundColor: AppColors.green9,
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'all': return 'All';
      case 'books': return 'Books';
      case 'electronics': return 'Electronics';
      case 'furniture': return 'Furniture';
      case 'clothes': return 'Clothes';
      case 'sports': return 'Sports';
      case 'other': return 'Other';
      default: return category;
    }
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('View ${product['name']} - Coming Soon')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: product['image'] != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          product['image'],
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        _getCategoryIcon(product['category']),
                        size: 48,
                        color: AppColors.onSurfaceVariant,
                      ),
              ),
            ),

            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    Text(
                      'NOK ${product['price'].toStringAsFixed(0)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.defaultBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product['seller'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getConditionColor(product['condition']).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product['condition'],
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getConditionColor(product['condition']),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'books': return Icons.book;
      case 'electronics': return Icons.devices;
      case 'furniture': return Icons.chair;
      case 'clothes': return Icons.checkroom;
      case 'sports': return Icons.sports;
      default: return Icons.shopping_bag;
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'New': return AppColors.success;
      case 'Like New': return AppColors.accentBlue;
      case 'Good': return AppColors.defaultGold;
      case 'Fair': return AppColors.orange9;
      case 'Poor': return AppColors.error;
      default: return AppColors.onSurfaceVariant;
    }
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../../providers/campus/campus_provider.dart';
import '../../../providers/auth/auth_provider.dart';

final _productServiceProvider = Provider<ProductService>(
  (ref) => ProductService(),
);

final productsProvider = FutureProvider.autoDispose
    .family<List<ProductModel>, _ProductQuery>((ref, query) async {
      final service = ref.watch(_productServiceProvider);

      if (query.showFavorites && query.userId != null) {
        return service.getUserFavoriteProducts(
          userId: query.userId!,
          campusId: query.campusId,
          category: query.category,
          limit: 50,
        );
      } else {
        return service.listProducts(
          campusId: query.campusId,
          category: query.category,
          status: query.status,
          search: query.search,
          limit: 50,
        );
      }
    });

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String _selectedCategory = 'all';
  String? _search;
  bool _showFavorites = false;
  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'all',
    'books',
    'electronics',
    'furniture',
    'clothes',
    'sports',
    'other',
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _search = value.trim().isEmpty ? null : value.trim();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final campus = ref.watch(filterCampusProvider);
    final auth = ref.watch(authStateProvider);

    final query = _ProductQuery(
      campusId: campus.id,
      category: _selectedCategory,
      status: 'available',
      search: _search,
      showFavorites: _showFavorites,
      userId: auth.isAuthenticated ? auth.user?.id : null,
    );
    final productsAsync = ref.watch(productsProvider(query));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.marketplace),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoalBlack),
        ),
        actions: [
          if (auth.isAuthenticated)
            IconButton(
              onPressed: () {
                setState(() {
                  _showFavorites = !_showFavorites;
                  if (_showFavorites) {
                    // Clear search when switching to favorites
                    _searchController.clear();
                    _search = null;
                  }
                });
              },
              icon: Icon(
                _showFavorites ? Icons.favorite : Icons.favorite_border,
                color: _showFavorites
                    ? AppColors.error
                    : AppColors.charcoalBlack,
              ),
              tooltip: _showFavorites
                  ? 'Show all products'
                  : 'Show favorites only',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _showFavorites ? null : _onSearchChanged,
              enabled: !_showFavorites,
              decoration: InputDecoration(
                hintText: _showFavorites
                    ? 'Search disabled in favorites'
                    : 'Search marketplace',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.onSurfaceVariant,
                ),
                suffixIcon: _search != null
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _search = null);
                        },
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.onSurfaceVariant,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.gray50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.defaultBlue,
                    width: 2,
                  ),
                ),
              ),
              textInputAction: TextInputAction.search,
            ),
          ),

          // Category Filter – premium pill row
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.subtleBlue : Colors.white,
                      border: Border.all(
                        color: selected
                            ? AppColors.defaultBlue
                            : AppColors.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        _getCategoryDisplayName(cat),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: selected
                              ? AppColors.defaultBlue
                              : AppColors.charcoalBlack,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemCount: _categories.length,
            ),
          ),

          const Divider(height: 1),

          // Products Grid
          Expanded(
            child: productsAsync.when(
              data: (products) => products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showFavorites
                                ? Icons.favorite_border
                                : Icons.shopping_bag_outlined,
                            size: 64,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _showFavorites
                                ? 'No favorites yet'
                                : 'No items found',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _showFavorites
                                ? 'Heart items you like to see them here!'
                                : 'Try changing your filter or check back later',
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.72,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) =>
                          _PremiumProductCard(product: products[index]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text('Failed to load', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      e.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => ref.invalidate(productsProvider(query)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/explore/products/new'),
        icon: const Icon(Icons.add),
        label: const Text('Sell Item'),
        backgroundColor: AppColors.green9,
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'all':
        return 'All';
      case 'books':
        return 'Books';
      case 'electronics':
        return 'Electronics';
      case 'furniture':
        return 'Furniture';
      case 'clothes':
        return 'Clothes';
      case 'sports':
        return 'Sports';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }
}

class _PremiumProductCard extends ConsumerStatefulWidget {
  final ProductModel product;

  const _PremiumProductCard({required this.product});

  @override
  ConsumerState<_PremiumProductCard> createState() =>
      _PremiumProductCardState();
}

class _PremiumProductCardState extends ConsumerState<_PremiumProductCard> {
  bool _isFavorited = false;
  bool _favoriteLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final auth = ref.read(authStateProvider);
    if (auth.isAuthenticated && auth.user != null) {
      try {
        final service = ProductService();
        final isFavorited = await service.isFavorited(
          userId: auth.user!.id,
          productId: widget.product.id,
        );
        if (mounted) {
          setState(() {
            _isFavorited = isFavorited;
          });
        }
      } catch (e) {
        // Silently fail - favorite status is not critical
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final auth = ref.read(authStateProvider);
    if (!auth.isAuthenticated || auth.user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to save favorites')),
        );
      }
      return;
    }

    if (_favoriteLoading) return;

    if (mounted) {
      setState(() => _favoriteLoading = true);
    }

    try {
      final service = ProductService();
      final newState = await service.toggleFavorite(
        userId: auth.user!.id,
        productId: widget.product.id,
      );

      if (mounted) {
        setState(() {
          _isFavorited = newState;
          _favoriteLoading = false;
        });

        // Show subtle feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newState ? 'Added to favorites' : 'Removed from favorites',
            ),
            duration: const Duration(milliseconds: 800),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _favoriteLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update favorite: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authStateProvider);

    return InkWell(
      onTap: () => context.go('/explore/products/${widget.product.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 16,
              offset: Offset(0, 10),
            ),
          ],
          border: Border.all(color: AppColors.gray100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay badges
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: widget.product.images.isNotEmpty
                          ? Image.network(
                              widget.product.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: AppColors.gray100,
                                child: const Icon(Icons.image_outlined),
                              ),
                            )
                          : Container(
                              color: AppColors.gray100,
                              child: Icon(
                                _getCategoryIcon(widget.product.category),
                                size: 48,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                  // Price pill
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'NOK ${widget.product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // Functional favorite icon
                  if (auth.isAuthenticated)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: _toggleFavorite,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadowLight,
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: _favoriteLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.defaultBlue,
                                  ),
                                )
                              : Icon(
                                  _isFavorited
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: _isFavorited
                                      ? AppColors.error
                                      : AppColors.defaultBlue,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info - flexible content area
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.product.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.sellerName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getConditionColor(
                              widget.product.condition,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            widget.product.displayCondition,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getConditionColor(
                                widget.product.condition,
                              ),
                              fontWeight: FontWeight.w600,
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
      case 'books':
        return Icons.book;
      case 'electronics':
        return Icons.devices;
      case 'furniture':
        return Icons.chair;
      case 'clothes':
        return Icons.checkroom;
      case 'sports':
        return Icons.sports;
      default:
        return Icons.shopping_bag;
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'new':
        return AppColors.success;
      case 'like_new':
        return AppColors.accentBlue;
      case 'good':
        return AppColors.defaultGold;
      case 'fair':
        return AppColors.orange9;
      case 'poor':
        return AppColors.error;
      default:
        return AppColors.onSurfaceVariant;
    }
  }
}

class _ProductQuery {
  final String campusId;
  final String? category;
  final String? status;
  final String? search;
  final bool showFavorites;
  final String? userId;

  const _ProductQuery({
    required this.campusId,
    this.category,
    this.status,
    this.search,
    this.showFavorites = false,
    this.userId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ProductQuery &&
        other.campusId == campusId &&
        other.category == category &&
        other.status == status &&
        other.search == search &&
        other.showFavorites == showFavorites &&
        other.userId == userId;
  }

  @override
  int get hashCode =>
      Object.hash(campusId, category, status, search, showFavorites, userId);
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../../data/services/chat_service.dart';
import '../../../providers/campus/campus_provider.dart';
import '../../../providers/auth/auth_provider.dart';
import '../chat/chat_conversation_screen.dart';

final _productServiceProvider = Provider<ProductService>((ref) => ProductService());
final _chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final productsProvider = FutureProvider.autoDispose.family<List<ProductModel>, _ProductQuery>((ref, query) async {
  final service = ref.watch(_productServiceProvider);
  return service.listProducts(
    campusId: query.campusId,
    category: query.category,
    status: query.status,
    search: query.search,
    limit: 50,
  );
});

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String _selectedCategory = 'all';
  String? _search;

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
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoalBlack),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final textController = TextEditingController(text: _search ?? '');
              await showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Search marketplace', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          hintText: 'Try "MacBook", "Textbook", "Lamp"',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: AppColors.gray50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.outlineVariant),
                          ),
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => Navigator.pop(context),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Apply'),
                        ),
                      )
                    ],
                  ),
                ),
              );
              setState(() => _search = textController.text.trim().isEmpty ? null : textController.text.trim());
            },
            icon: const Icon(Icons.search, color: AppColors.charcoalBlack),
          ),
          if (auth.isAuthenticated)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border, color: AppColors.charcoalBlack),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search hint row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _search == null || _search!.isEmpty ? 'Search marketplace' : 'Results for "$_search"',
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  if (_search != null)
                    TextButton(
                      onPressed: () => setState(() => _search = null),
                      child: const Text('Clear'),
                    )
                ],
              ),
            ),
          ),

          // Category Filter – premium pill row
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.subtleBlue : Colors.white,
                      border: Border.all(color: selected ? AppColors.defaultBlue : AppColors.outlineVariant),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      _getCategoryDisplayName(cat),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: selected ? AppColors.defaultBlue : AppColors.charcoalBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
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
                          Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text('No items found', style: theme.textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text('Try changing your filter or check back later', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) => _PremiumProductCard(
                        product: products[index],
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    const SizedBox(height: 8),
                    Text('Failed to load', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(e.toString(), style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
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

  void _openMarketplaceChat(BuildContext context, ProductModel product) async {
    final auth = ref.read(authStateProvider);
    
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to message sellers')),
      );
      return;
    }

    if (auth.user!.id == product.sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot message yourself')),
      );
      return;
    }

    // Show dialog to compose initial message
    final messageController = TextEditingController(
      text: 'Hi! I\'m interested in your ${product.name}. Is it still available?',
    );

    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 48,
                child: product.images.isNotEmpty
                    ? Image.network(product.images.first, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.gray100,
                        child: const Icon(Icons.shopping_bag),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Message ${product.sellerName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            hintText: 'Write your message...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send Message'),
          ),
        ],
      ),
    );

    if (shouldSend == true && messageController.text.trim().isNotEmpty) {
      // Show loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      try {
        final chatService = ref.read(_chatServiceProvider);
        final chat = await chatService.createMarketplaceChat(
          buyerId: auth.user!.id,
          buyerName: auth.user!.name,
          sellerId: product.sellerId,
          sellerName: product.sellerName,
          productId: product.id,
          productName: product.name,
          productImageUrl: product.images.isNotEmpty ? product.images.first : '',
          productPrice: product.price,
          userMessage: messageController.text.trim(),
        );

        // Dismiss loading
        if (context.mounted) Navigator.pop(context);

        // Navigate to chat
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatConversationScreen(chat: chat),
            ),
          );
        }
      } catch (e) {
        // Dismiss loading
        if (context.mounted) Navigator.pop(context);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create chat: $e')),
          );
        }
      }
    }

    messageController.dispose();
  }
}

class _PremiumProductCard extends StatelessWidget {
  final ProductModel product;

  const _PremiumProductCard({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.go('/explore/products/${product.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: AppColors.shadowLight, blurRadius: 16, offset: Offset(0, 10)),
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
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: product.images.isNotEmpty
                          ? Image.network(
                              product.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: AppColors.gray100, child: const Icon(Icons.image_outlined)),
                            )
                          : Container(
                              color: AppColors.gray100,
                              child: Icon(_getCategoryIcon(product.category), size: 48, color: AppColors.onSurfaceVariant),
                            ),
                    ),
                  ),
                  // Price pill
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'NOK ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  // Favorite icon placeholder
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 12)],
                      ),
                      child: const Icon(Icons.favorite_border, color: AppColors.defaultBlue, size: 20),
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
                    product.name,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.sellerName,
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getConditionColor(product.condition).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          product.displayCondition,
                          style: theme.textTheme.labelSmall?.copyWith(color: _getConditionColor(product.condition), fontWeight: FontWeight.w600),
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
      case 'new': return AppColors.success;
      case 'like_new': return AppColors.accentBlue;
      case 'good': return AppColors.defaultGold;
      case 'fair': return AppColors.orange9;
      case 'poor': return AppColors.error;
      default: return AppColors.onSurfaceVariant;
    }
  }
}

class _ProductQuery {
  final String campusId;
  final String? category;
  final String? status;
  final String? search;
  const _ProductQuery({required this.campusId, this.category, this.status, this.search});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ProductQuery &&
        other.campusId == campusId &&
        other.category == category &&
        other.status == status &&
        other.search == search;
  }

  @override
  int get hashCode => Object.hash(campusId, category, status, search);
}
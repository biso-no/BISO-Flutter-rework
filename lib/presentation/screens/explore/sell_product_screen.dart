import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../providers/campus/campus_provider.dart';
import '../../../generated/l10n/app_localizations.dart';

class SellProductScreen extends ConsumerStatefulWidget {
  const SellProductScreen({super.key});

  @override
  ConsumerState<SellProductScreen> createState() => _SellProductScreenState();
}

class _PremiumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const _PremiumField({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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
          borderSide: const BorderSide(color: AppColors.defaultBlue),
        ),
      ),
    );
  }
}

class _PremiumPillSelector extends StatelessWidget {
  final String? value;
  final String label;
  final List<String> options;
  final String Function(String) display;
  final bool allowNull;
  final void Function(String) onChanged;
  const _PremiumPillSelector({
    required this.value,
    required this.label,
    required this.options,
    required this.display,
    required this.onChanged,
    this.allowNull = false,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (allowNull)
              _pill(
                context,
                selected: value == null,
                text: 'None',
                onTap: () => onChanged(''),
              ),
            ...options.map(
              (o) => _pill(
                context,
                selected: value == o,
                text: display(o),
                onTap: () => onChanged(o),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pill(
    BuildContext context, {
    required bool selected,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.subtleBlue : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.defaultBlue : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? AppColors.defaultBlue : AppColors.charcoalBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SellProductScreenState extends ConsumerState<SellProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactInfoController = TextEditingController();

  final List<XFile> _images = [];
  bool _submitting = false;

  final String _currency = 'NOK';
  String _category = 'books';
  String _condition = 'good';
  bool _isNegotiable = false;
  String? _contactMethod; // 'message' | 'phone' | 'email'

  final _categories = const [
    'books',
    'electronics',
    'furniture',
    'clothes',
    'sports',
    'other',
  ];
  final _conditions = const ['new', 'like_new', 'good', 'fair', 'poor'];
  final _contactMethods = const ['message', 'phone', 'email'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStateProvider);
    final _ = ref.watch(
      filterCampusProvider,
    ); // keep reactive to campus changes

    if (!auth.isAuthenticated || auth.user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sellItem)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.pleaseSignInToSellItems,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/auth/login'),
                  child: Text(l10n.login),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.sellItem),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _handleCancel,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.publish),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Images picker
            _buildImagesPicker(theme),

            const SizedBox(height: 16),

            _PremiumField(
              controller: _nameController,
              label: l10n.titleLabel,
              hint: l10n.exampleMacbook,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.titleIsRequired : null,
            ),

            const SizedBox(height: 12),

            _PremiumField(
              controller: _descriptionController,
              label: l10n.descriptionLabel,
              maxLines: 5,
              validator: (v) => (v == null || v.trim().length < 10)
                  ? l10n.pleaseAddMoreDetail
                  : null,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _PremiumField(
                    controller: _priceController,
                    label: l10n.priceNok,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return l10n.requiredField;
                      final num? val = num.tryParse(v.replaceAll(',', '.'));
                      if (val == null || val <= 0) {
                        return l10n.enterValidAmount;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _PremiumPillSelector(
                    value: _category,
                    label: l10n.categoryLabel,
                    options: _categories,
                    display: _categoryLabel,
                    onChanged: (v) => setState(() => _category = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PremiumPillSelector(
                    value: _condition,
                    label: l10n.conditionLabel,
                    options: _conditions,
                    display: _conditionLabel,
                    onChanged: (v) => setState(() => _condition = v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _isNegotiable,
              onChanged: (v) => setState(() => _isNegotiable = v),
              title: Text(l10n.priceNegotiable),
            ),

            const Divider(height: 24),

            _PremiumPillSelector(
              value: _contactMethod,
              label: l10n.preferredContactOptional,
              options: _contactMethods,
              display: _contactLabel,
              onChanged: (v) => setState(() => _contactMethod = v),
              allowNull: true,
            ),

            const SizedBox(height: 12),

            _PremiumField(
              controller: _contactInfoController,
              label: l10n.contactInfoOptional,
            ),

            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: const Icon(Icons.publish),
              label: Text(l10n.publish),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesPicker(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.photos, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._images.map(
              (x) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(x.path),
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () => setState(() => _images.remove(x)),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: _pickImages,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: const Center(child: Icon(Icons.add_a_photo)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final result = await picker.pickMultiImage(imageQuality: 85);
    if (result.isNotEmpty) {
      setState(() {
        _images.addAll(result);
        if (_images.length > 6) {
          _images.removeRange(6, _images.length);
        }
      });
    }
  }

  bool _hasChanges() {
    return _images.isNotEmpty ||
        _nameController.text.trim().isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty ||
        _priceController.text.trim().isNotEmpty ||
        _contactInfoController.text.trim().isNotEmpty ||
        _contactMethod != null ||
        _isNegotiable ||
        _category != 'books' ||
        _condition != 'good';
  }

  Future<void> _handleCancel() async {
    if (!_hasChanges()) {
      context.go('/explore/products');
      return;
    }
    final discard = await _showDiscardDialog();
    if (!mounted || !discard) return;
    context.go('/explore/products');
  }

  Future<bool> _showDiscardDialog() async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.discardChanges),
        content: Text(l10n.unsavedChangesWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.keepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.discard),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    return result ?? false;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseAddAtLeastOnePhoto)),
      );
      return;
    }

    final auth = ref.read(authStateProvider);
    final campus = ref.read(filterCampusProvider);
    final user = auth.user!;

    setState(() => _submitting = true);

    try {
      final price = double.parse(_priceController.text.replaceAll(',', '.'));
      final product = ProductModel(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        currency: _currency,
        sellerId: user.id,
        sellerName: user.name,
        sellerAvatar: user.avatarUrl,
        campusId: campus.id,
        category: _category,
        images: const [],
        condition: _condition,
        status: 'available',
        isNegotiable: _isNegotiable,
        contactMethod: _contactMethod,
        contactInfo: _contactInfoController.text.trim().isEmpty
            ? null
            : _contactInfoController.text.trim(),
      );

      final service = ProductService();
      final createdProduct = await service.createProduct(
        product: product,
        imagePaths: _images.map((x) => x.path).toList(),
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.itemNowLive)));

      // Navigate directly to the new product details screen
      context.go('/explore/products/${createdProduct.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.failedToPublish(e.toString()))));
    }
  }

  String _categoryLabel(String c) {
    final l10n = AppLocalizations.of(context);
    switch (c) {
      case 'books':
        return l10n.categoryBooks;
      case 'electronics':
        return l10n.categoryElectronics;
      case 'furniture':
        return l10n.categoryFurniture;
      case 'clothes':
        return l10n.categoryClothes;
      case 'sports':
        return l10n.categorySports;
      default:
        return l10n.categoryOther;
    }
  }

  String _conditionLabel(String c) {
    final l10n = AppLocalizations.of(context);
    switch (c) {
      case 'new':
        return l10n.conditionBrandNew;
      case 'like_new':
        return l10n.conditionLikeNew;
      case 'good':
        return l10n.conditionGood;
      case 'fair':
        return l10n.conditionFair;
      case 'poor':
        return l10n.conditionPoor;
      default:
        return c;
    }
  }

  String _contactLabel(String m) {
    final l10n = AppLocalizations.of(context);
    switch (m) {
      case 'message':
        return l10n.inAppMessage;
      case 'phone':
        return l10n.phone;
      case 'email':
        return l10n.email;
      default:
        return m;
    }
  }
}

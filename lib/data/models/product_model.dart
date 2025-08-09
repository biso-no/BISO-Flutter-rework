import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String sellerId;
  final String sellerName;
  final String? sellerAvatar;
  final String campusId;
  final String category;
  final List<String> images;
  final String condition; // 'new', 'like_new', 'good', 'fair', 'poor'
  final String status; // 'available', 'sold', 'reserved', 'inactive'
  final bool isNegotiable;
  final String? contactMethod; // 'message', 'phone', 'email'
  final String? contactInfo;
  final Map<String, dynamic> metadata; // Additional product-specific data
  final int viewCount;
  final int favoriteCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'NOK',
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatar,
    required this.campusId,
    required this.category,
    this.images = const [],
    this.condition = 'good',
    this.status = 'available',
    this.isNegotiable = false,
    this.contactMethod,
    this.contactInfo,
    this.metadata = const {},
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['\$id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'NOK',
      sellerId: map['seller_id'] ?? '',
      sellerName: map['seller_name'] ?? '',
      sellerAvatar: map['seller_avatar'],
      campusId: map['campus_id'] ?? '',
      category: map['category'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      condition: map['condition'] ?? 'good',
      status: map['status'] ?? 'available',
      isNegotiable: map['is_negotiable'] ?? false,
      contactMethod: map['contact_method'],
      contactInfo: map['contact_info'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      viewCount: map['view_count'] ?? 0,
      favoriteCount: map['favorite_count'] ?? 0,
      createdAt: map['\$createdAt'] != null ? DateTime.parse(map['\$createdAt']) : null,
      updatedAt: map['\$updatedAt'] != null ? DateTime.parse(map['\$updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'seller_avatar': sellerAvatar,
      'campus_id': campusId,
      'category': category,
      'images': images,
      'condition': condition,
      'status': status,
      'is_negotiable': isNegotiable,
      'contact_method': contactMethod,
      'contact_info': contactInfo,
      'metadata': metadata,
      'view_count': viewCount,
      'favorite_count': favoriteCount,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? currency,
    String? sellerId,
    String? sellerName,
    String? sellerAvatar,
    String? campusId,
    String? category,
    List<String>? images,
    String? condition,
    String? status,
    bool? isNegotiable,
    String? contactMethod,
    String? contactInfo,
    Map<String, dynamic>? metadata,
    int? viewCount,
    int? favoriteCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerAvatar: sellerAvatar ?? this.sellerAvatar,
      campusId: campusId ?? this.campusId,
      category: category ?? this.category,
      images: images ?? this.images,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      contactMethod: contactMethod ?? this.contactMethod,
      contactInfo: contactInfo ?? this.contactInfo,
      metadata: metadata ?? this.metadata,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAvailable => status == 'available';
  bool get isSold => status == 'sold';
  bool get isReserved => status == 'reserved';
  String get formattedPrice => '${price.toStringAsFixed(0)} $currency';
  String get displayCondition {
    switch (condition) {
      case 'new': return 'Brand New';
      case 'like_new': return 'Like New';
      case 'good': return 'Good';
      case 'fair': return 'Fair';
      case 'poor': return 'Poor';
      default: return condition;
    }
  }

  @override
  List<Object?> get props => [
    id, name, description, price, currency, sellerId, sellerName,
    sellerAvatar, campusId, category, images, condition, status,
    isNegotiable, contactMethod, contactInfo, metadata, viewCount,
    favoriteCount, createdAt, updatedAt,
  ];
}
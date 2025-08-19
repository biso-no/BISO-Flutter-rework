import 'package:equatable/equatable.dart';

class WebshopProduct extends Equatable {
  final int id;
  final String name;
  final String? campusLabel;
  final String? departmentLabel;
  final List<String> images;
  final String price; // Woo returns price as string
  final String salePrice;
  final String? description;
  final String? url;

  const WebshopProduct({
    required this.id,
    required this.name,
    required this.images,
    required this.price,
    required this.salePrice,
    this.campusLabel,
    this.departmentLabel,
    this.description,
    this.url,
  });

  factory WebshopProduct.fromFunctionMap(Map<String, dynamic> map) {
    return WebshopProduct(
      id: (map['id'] ?? 0) as int,
      name: (map['name'] ?? '') as String,
      images: List<String>.from(map['images'] ?? const <String>[]),
      price: (map['price'] ?? '') as String,
      salePrice: (map['sale_price'] ?? '') as String,
      campusLabel: (map['campus'] != null && map['campus'] is Map<String, dynamic>)
          ? (map['campus']['label'] as String?)
          : null,
      departmentLabel: (map['department'] != null && map['department'] is Map<String, dynamic>)
          ? (map['department']['label'] as String?)
          : null,
      description: map['description'] as String?,
      url: map['url'] as String?,
    );
  }

  bool get hasSale => salePrice.isNotEmpty && salePrice != '0';

  @override
  List<Object?> get props => [id, name, images, price, salePrice, campusLabel, departmentLabel, url];
}



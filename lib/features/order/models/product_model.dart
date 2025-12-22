enum ProductType { drink, food }

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final ProductType type;
  final bool isAvailable;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.type,
    this.isAvailable = true,
  });

  /// Factory constructor to create a Product from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'],
      type: json['type'] == 'food' ? ProductType.food : ProductType.drink,
      isAvailable: json['is_available'] ?? true,
    );
  }

  /// Convert Product model to Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'type': type == ProductType.food ? 'food' : 'drink',
      'is_available': isAvailable,
    };
  }
}

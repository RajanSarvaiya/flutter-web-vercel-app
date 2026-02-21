class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final String category;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final double rating;
  final int reviewCount;
  final bool isNew;
  final bool isBestSeller;
  final bool isFeatured;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.category,
    required this.images,
    required this.sizes,
    required this.colors,
    this.rating = 4.0,
    this.reviewCount = 0,
    this.isNew = false,
    this.isBestSeller = false,
    this.isFeatured = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get discountPercent =>
      originalPrice > price
          ? ((1 - price / originalPrice) * 100).round()
          : 0;

  bool get hasDiscount => discountPercent > 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'originalPrice': originalPrice,
        'category': category,
        'images': images,
        'sizes': sizes,
        'colors': colors,
        'rating': rating,
        'reviewCount': reviewCount,
        'isNew': isNew,
        'isBestSeller': isBestSeller,
        'isFeatured': isFeatured,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        originalPrice: (json['originalPrice'] as num).toDouble(),
        category: json['category'] as String,
        images: List<String>.from(json['images'] as List),
        sizes: List<String>.from(json['sizes'] as List),
        colors: List<String>.from(json['colors'] as List),
        rating: (json['rating'] as num?)?.toDouble() ?? 4.0,
        reviewCount: json['reviewCount'] as int? ?? 0,
        isNew: json['isNew'] as bool? ?? false,
        isBestSeller: json['isBestSeller'] as bool? ?? false,
        isFeatured: json['isFeatured'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );
}

class CartItem {
  final Product product;
  final String selectedSize;
  final String selectedColor;
  int quantity;

  CartItem({
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    this.quantity = 1,
  });

  double get total => product.price * quantity;
}

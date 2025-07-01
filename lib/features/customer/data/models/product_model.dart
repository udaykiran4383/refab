class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;
  final double? rating;
  final int stockQuantity;
  final List<String> images;
  final Map<String, dynamic>? materialsUsed;
  final double? environmentalImpact;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isAvailable,
    this.rating,
    required this.stockQuantity,
    required this.images,
    this.materialsUsed,
    this.environmentalImpact,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      category: json['category'],
      isAvailable: json['isAvailable'] ?? true,
      rating: json['rating']?.toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      materialsUsed: json['materialsUsed'],
      environmentalImpact: json['environmentalImpact']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
      'rating': rating,
      'stockQuantity': stockQuantity,
      'images': images,
      'materialsUsed': materialsUsed,
      'environmentalImpact': environmentalImpact,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isAvailable,
    double? rating,
    int? stockQuantity,
    List<String>? images,
    Map<String, dynamic>? materialsUsed,
    double? environmentalImpact,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      images: images ?? this.images,
      materialsUsed: materialsUsed ?? this.materialsUsed,
      environmentalImpact: environmentalImpact ?? this.environmentalImpact,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isInStock => stockQuantity > 0;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 5;
  String get formattedPrice => '₹${price.toStringAsFixed(2)}';
  String get mainImage => images.isNotEmpty ? images.first : imageUrl;
} 